# git-fzf.bash -- fzf-powered tab completions for git diff, sdiff, and add
#
# Overview:
#   Provides smart file autocompletion for common git commands using fzf
#   for interactive fuzzy matching. Falls back to default git completion
#   if fzf is not available.
#
# Behavior:
#   git diff <Tab>           -> unstaged modified files
#   git diff --cached <Tab>  -> staged files
#   git sdiff <Tab>          -> unstaged modified files (side-by-side alias)
#   git sdiff --cached <Tab> -> staged files
#   git add <Tab>            -> untracked + unstaged files
#
# fzf display:
#   Shows filenames for fuzzy matching, inserts full path (relative to cwd).
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
# _git_fzf_get_files: returns the list of relevant files for a given command
#
# Arguments:
#   $1 -- git subcommand (diff, sdiff, add)
#
# How it decides which files to show:
#   - diff/sdiff: unstaged modified files (status codes in column 2)
#   - diff/sdiff --cached: staged files (status codes in column 1)
#   - add: untracked (??) and unstaged modified files
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
# ---------------------------------------------------------------------------
_git_fzf_get_files() {
    local cmd="$1"

    case "$cmd" in
        diff|sdiff)
            if [[ " ${COMP_WORDS[*]} " == *" --cached "* ]] || \
               [[ " ${COMP_WORDS[*]} " == *" --staged "* ]]; then
                # Staged files: status code in column 1 (non-space, non-?)
                git status --porcelain --no-renames 2>/dev/null \
                    | grep '^[MADRC]' \
                    | cut -c4-
            else
                # Unstaged modified files: status code in column 2
                # Also catches MM (modified in both staging and working tree)
                git status --porcelain --no-renames 2>/dev/null \
                    | grep '^ [MADRC]\|^MM' \
                    | cut -c4-
            fi
            ;;
        add)
            # Untracked (??) and unstaged modifications (column 2)
            git status --porcelain --no-renames 2>/dev/null \
                | grep '^ [MADRC]\|^??' \
                | cut -c4-
            ;;
    esac
}

# ---------------------------------------------------------------------------
# _git_fzf_complete: core completion logic
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
    local cmd="$1"
    local cur="${COMP_WORDS[COMP_CWORD]}"

    # Get the relevant file list; bail if empty
    local files
    files=$(_git_fzf_get_files "$cmd")
    [[ -z "$files" ]] && return 1

    # Run fzf for interactive selection
    local selected
    selected=$(echo "$files" | fzf \
        --height=40% \
        --reverse \
        --prompt="$cmd > " \
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
# _git_fzf_dispatch: main entry point for git tab completion
#
# Routes to fzf-powered completion for diff/sdiff/add.
# Falls back to default git completion for everything else, and also
# when:
#   - fzf is not installed
#   - the current word is a flag (e.g. --cached, --stat)
#   - no diff-able/addable files exist
# ---------------------------------------------------------------------------
_git_fzf_dispatch() {
    local subcmd="${COMP_WORDS[1]}"
    local cur="${COMP_WORDS[COMP_CWORD]}"

    # If fzf is not available, always use default completion
    if ! command -v fzf &>/dev/null; then
        _git_fzf_fallback
        return
    fi

    # For diff/sdiff/add: use fzf (unless completing a flag).
    # For everything else: fall back to default git completion.
    case "$subcmd" in
        diff|sdiff|add)
            [[ "$cur" == -* ]] && { _git_fzf_fallback; return; }
            _git_fzf_complete "$subcmd" || _git_fzf_fallback
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
