# git-fzf.bash -- fzf-powered tab completions for git file-taking commands
#
# Overview:
#   Provides smart file autocompletion for common git commands using fzf
#   for interactive fuzzy matching. Falls back to default git completion
#   if fzf is not available.
#
# Behavior:
#   git diff <Tab>              -> unstaged modified files
#   git diff --cached <Tab>     -> staged files
#   git sdiff <Tab>             -> unstaged modified files (side-by-side alias)
#   git sdiff --cached <Tab>    -> staged files
#   git add <Tab>               -> untracked + unstaged files
#   git reset <Tab>             -> staged files (unstage)
#   git restore <Tab>           -> unstaged modified files (discard edits)
#   git restore --staged <Tab>  -> staged files (unstage)
#   git checkout -- <Tab>       -> unstaged modified files (legacy restore)
#
#   Ref-operating invocations (git reset --hard, git checkout <branch>,
#   git restore --source=...) fall through to default git completion.
#
# fzf display:
#   Shows filenames for fuzzy matching, inserts full path (relative to cwd,
#   with ../ prefixes for files outside the current subtree).
#
# Fallback:
#   If fzf is not in PATH, falls through to default git completion.
#   If no matching files exist, does nothing (no error).
#
# Terminal state (re-trigger prevention):
#   When fzf runs inside a bash completion function, it takes over the
#   terminal for its TUI. On exit, fzf may leave escape sequences in
#   readline's input buffer. Readline can misinterpret these as keystrokes
#   -- including Tab -- causing an immediate re-trigger of the completion
#   function (the "ghost Tab" problem).
#
#   fzf's own completion framework (completion.bash) solves this with:
#     printf '\e[5n'                          -- Device Status Report request
#     bind '"\e[0n": redraw-current-line'     -- handle the terminal response
#
#   The terminal responds to \e[5n with \e[0n ("device OK"). By binding
#   \e[0n to redraw-current-line, readline consumes the response harmlessly
#   instead of interpreting it as input. This effectively flushes any
#   leftover escape sequences from fzf's TUI.
#
#   We replicate this technique here. See _git_fzf_complete for details.
#
# Installation:
#   Source this file from ~/.bashrc, e.g.:
#     for f in ~/.config/bash/completions/*.bash; do source "$f"; done
#
# Dependencies:
#   - git
#   - fzf (optional -- graceful fallback without it)

# ---------------------------------------------------------------------------
# File-set helpers
#
# git status --porcelain format reminder:
#   Column 1 = staging area status, Column 2 = working tree status
#   XY  meaning
#   M   modified
#   A   added
#   D   deleted
#   R   renamed
#   C   copied
#   ?   untracked
#   e.g. " M foo.py" = unstaged modification
#        "M  foo.py" = staged modification
#        "?? foo.py" = untracked file
#
# All helpers output repo-root-relative paths; _git_fzf_cwd_relative
# translates them to cwd-relative paths (with ../ prefixes as needed).
# ---------------------------------------------------------------------------

# Rewrite a stream of repo-root-relative paths as cwd-relative paths.
# Paths outside the current subtree gain ../ prefixes.
_git_fzf_cwd_relative() {
    local root
    root=$(git rev-parse --show-toplevel 2>/dev/null)
    [[ -z "$root" ]] && return 0
    while IFS= read -r f; do
        [[ -z "$f" ]] && continue
        realpath --relative-to=. "$root/$f"
    done
}

# Unstaged working-tree modifications (column 2 has a change).
_git_fzf_unstaged_files() {
    git status --porcelain --no-renames 2>/dev/null \
        | grep '^ [MADRC]\|^MM' \
        | cut -c4- \
        | _git_fzf_cwd_relative
}

# Staged changes (column 1 has a change).
_git_fzf_staged_files() {
    git status --porcelain --no-renames 2>/dev/null \
        | grep '^[MADRC]' \
        | cut -c4- \
        | _git_fzf_cwd_relative
}

# Unstaged modifications plus untracked files (the set `git add` accepts).
_git_fzf_addable_files() {
    git status --porcelain --no-renames 2>/dev/null \
        | grep '^ [MADRC]\|^??' \
        | cut -c4- \
        | _git_fzf_cwd_relative
}

# ---------------------------------------------------------------------------
# _git_fzf_complete: core completion logic
#
# Arguments:
#   $1 -- prompt label shown in fzf (e.g. "diff", "restore --staged")
#   $2 -- name of a file-set function to call (e.g. _git_fzf_staged_files)
#
# Gets the relevant file list, pipes through fzf for fuzzy selection.
# On success, sets COMPREPLY with the selected path.
#
# fzf flags:
#   --height=40%        don't take over the full terminal
#   --reverse           show list top-down
#   --prompt            show which command we're completing for
#   --query             pre-fill with what the user has typed so far
#   --select-1          auto-select if only one match
#   --exit-0            exit cleanly if no matches
#   --delimiter='/'     split path into segments
#   --with-nth='-1'     display only the filename (last segment) for matching
#   --preview='echo {}' show the full path in the preview area
#
# Note: Do NOT add `< /dev/tty` here — it would replace the piped file
# list with terminal input, causing fzf to fall back to FZF_DEFAULT_COMMAND
# (showing all files). fzf automatically uses /dev/tty for keyboard input
# when stdin is a pipe.
#
# COMPREPLY is the bash array that holds completion results.
# ---------------------------------------------------------------------------
_git_fzf_complete() {
    local prompt="$1"
    local files_fn="$2"
    local cur="${COMP_WORDS[COMP_CWORD]}"

    # Get the relevant file list; bail if empty
    local files
    files=$("$files_fn")
    [[ -z "$files" ]] && return 1

    # Run fzf for interactive selection
    local selected
    selected=$(echo "$files" | fzf \
        --height=40% \
        --reverse \
        --prompt="$prompt > " \
        --query="$cur" \
        --select-1 \
        --exit-0 \
        --delimiter='/' \
        --with-nth='-1' \
        --preview='echo {}' \
    )

    if [[ -n "$selected" ]]; then
        COMPREPLY=("$selected")
    else
        # User cancelled (Esc/Ctrl-C). Set empty string (not empty array!)
        # to prevent bash -o default from doing filesystem completion.
        COMPREPLY=("")
    fi

    # CRITICAL: Flush terminal input buffer to prevent the "ghost Tab"
    # problem. Without this, leftover escape sequences from fzf's TUI
    # cause readline to immediately re-trigger completion.
    # This is the same technique used by fzf's own completion.bash.
    # See file header for a detailed explanation.
    bind '"\e[0n": redraw-current-line' 2>/dev/null
    printf '\e[5n'

    return 0
}

# ---------------------------------------------------------------------------
# _git_fzf_fallback: try to invoke default git completion
#
# Looks for the standard git completion functions that may have been
# loaded by the system (from /usr/share/bash-completion/ or similar).
# If none are found, does nothing (bash will fall back to filename
# completion via -o default -o bashdefault on the complete registration).
# ---------------------------------------------------------------------------
_git_fzf_fallback() {
    if declare -f __git_wrap__git_main &>/dev/null; then
        __git_wrap__git_main
    elif declare -f _git &>/dev/null; then
        _git
    fi
}

# ---------------------------------------------------------------------------
# _git_fzf_has_word: true if $1 appears as a prior word on the command line
# (not the word currently being typed).
# ---------------------------------------------------------------------------
_git_fzf_has_word() {
    local target="$1" i
    for ((i=0; i<COMP_CWORD; i++)); do
        [[ "${COMP_WORDS[i]}" == "$target" ]] && return 0
    done
    return 1
}

# ---------------------------------------------------------------------------
# _git_fzf_has_word_prefix: true if any prior word starts with $1.
# Used to catch --long=VALUE forms where has_word's exact match misses.
# ---------------------------------------------------------------------------
_git_fzf_has_word_prefix() {
    local prefix="$1" i
    for ((i=0; i<COMP_CWORD; i++)); do
        [[ "${COMP_WORDS[i]}" == "$prefix"* ]] && return 0
    done
    return 1
}

# ---------------------------------------------------------------------------
# _git_fzf_reset_is_file_mode: heuristic for `git reset`
#
# `git reset <file>` unstages (file mode). `git reset --hard`, `git reset
# HEAD~1`, `git reset <sha>` etc. are ref-operations and should fall
# through to default completion. Assume file mode unless we see something
# that's clearly a ref op.
# ---------------------------------------------------------------------------
_git_fzf_reset_is_file_mode() {
    local i w
    for ((i=2; i<COMP_CWORD; i++)); do
        w="${COMP_WORDS[i]}"
        case "$w" in
            --)                                      return 0 ;;  # after -- everything is files
            --hard|--soft|--mixed|--merge|--keep)    return 1 ;;
            --patch|-p|-N)                           return 1 ;;
            HEAD|HEAD~*|HEAD^*|-)                    return 1 ;;
            *@*|*~*|*^*)                             return 1 ;;  # ref-ish syntax
        esac
        # Bare hex string (>=7 chars) looks like a SHA
        [[ "$w" =~ ^[0-9a-f]{7,40}$ ]] && return 1
    done
    return 0
}

# ---------------------------------------------------------------------------
# _git_fzf_dispatch: main entry point for git tab completion
#
# Routes to fzf-powered completion for file-taking subcommands. Falls
# back to default git completion otherwise, including when:
#   - fzf is not installed
#   - the current word is a flag (e.g. --cached, --stat)
#   - the invocation looks ref-operating rather than file-operating
#   - no relevant files exist
# ---------------------------------------------------------------------------
_git_fzf_dispatch() {
    local subcmd="${COMP_WORDS[1]}"
    local cur="${COMP_WORDS[COMP_CWORD]}"

    if ! command -v fzf &>/dev/null; then
        _git_fzf_fallback
        return
    fi

    # If the user is completing a flag, defer to default git completion.
    [[ "$cur" == -* ]] && { _git_fzf_fallback; return; }

    case "$subcmd" in
        diff|sdiff)
            if _git_fzf_has_word --cached || _git_fzf_has_word --staged; then
                _git_fzf_complete "$subcmd --cached" _git_fzf_staged_files || _git_fzf_fallback
            else
                _git_fzf_complete "$subcmd" _git_fzf_unstaged_files || _git_fzf_fallback
            fi
            ;;
        add)
            _git_fzf_complete add _git_fzf_addable_files || _git_fzf_fallback
            ;;
        reset)
            if _git_fzf_reset_is_file_mode; then
                _git_fzf_complete reset _git_fzf_staged_files || _git_fzf_fallback
            else
                _git_fzf_fallback
            fi
            ;;
        restore)
            if _git_fzf_has_word --staged || _git_fzf_has_word -S; then
                _git_fzf_complete "restore --staged" _git_fzf_staged_files || _git_fzf_fallback
            elif _git_fzf_has_word_prefix --source || _git_fzf_has_word -s; then
                # --source implies restoring from a ref; let default completion handle it.
                _git_fzf_fallback
            else
                _git_fzf_complete restore _git_fzf_unstaged_files || _git_fzf_fallback
            fi
            ;;
        checkout)
            # checkout is only unambiguously file-mode when `--` is typed
            # *immediately* after the subcommand (COMP_WORDS[2] == "--").
            # Any other shape (git checkout <ref> -- <file>, bare
            # git checkout <tab>) is ref-ish -- defer to default completion.
            if [[ "${COMP_WORDS[2]}" == "--" ]]; then
                _git_fzf_complete "checkout --" _git_fzf_unstaged_files || _git_fzf_fallback
            else
                _git_fzf_fallback
            fi
            ;;
        *)
            _git_fzf_fallback
            ;;
    esac
}

# ---------------------------------------------------------------------------
# Register our dispatcher as the completion handler for git.
#
#   -o default      fall back to default (filename) completion if COMPREPLY
#                   is empty
#   -o bashdefault  fall back to bash built-in completion if default also
#                   fails
#   -F              use a function (not a command) for completion
#
# Note: this overrides any previously registered git completion. The
# fallback logic above ensures we still delegate to it when appropriate.
# ---------------------------------------------------------------------------
complete -o default -o bashdefault -F _git_fzf_dispatch git
