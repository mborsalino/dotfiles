#!/usr/bin/env bash
#
# tmux-which-key-learn.sh
# -----------------------
# Runtime pass-through wrapper for entries in the tmux-which-key
# plugin (alexwforsythe/tmux-which-key). Every menu pick gets
# a short teaching flash: the tmux command being run plus the
# direct keybinding(s) that would have executed the same command
# without the menu.
#
# Why this exists
# ===============
# tmux-which-key is a solid launcher — a searchable popup of common
# tmux actions — but a poor teacher. Picking "Split horizontal" runs
# `split-window -h`, but the menu never reveals that `prefix + |`
# already does the same thing. You stay on the menu forever and
# never build muscle memory for the actual shortcut. This wrapper
# closes that gap without requiring any manual annotation: the
# lookup happens at invocation time against the LIVE tmux server,
# so rebinding a key is reflected immediately in the next flash.
#
# Full dispatch chain
# ===================
# When the user picks a wrapped menu entry, these levels of parsing
# happen (each unescapes once):
#
#     1. tmux reads the chosen menu entry and runs its command,
#        which is `run-shell "$HOME/bin/tmux-which-key-learn.sh
#        \"<RAW>\""`. Tmux's double-quoted arg parser unescapes the
#        inner \\" -> " etc., producing the string it hands to sh.
#     2. sh runs: $HOME/bin/tmux-which-key-learn.sh "<RAW>"
#        Because <RAW> is shell-double-quoted, variables would be
#        expanded and $ / ` / \ / " need prior escaping (done by the
#        wrap script at build time). Everything else passes through
#        verbatim — in particular #{pane_current_path} etc. which
#        tmux already expanded one level up.
#     3. This script receives <RAW> as positional arg $1 (=$*).
#     4. It queries `tmux list-keys` for any binding whose
#        (normalized, alias-expanded) command equals <RAW>.
#     5. `tmux display-message -d <ms>` flashes the status line:
#
#            ran: split-window -h   (shortcut: prefix + |)
#
#        or when several keys map to the same command:
#
#            ran: copy-mode   (shortcut: prefix + Enter | prefix + Escape | prefix + [)
#
#        or with no match (e.g. multi-step menu navigation):
#
#            ran: split-window -h
#
#     6. `eval tmux $cmd` executes the real thing. eval is used so
#        that tmux command arguments quoted inside $cmd are re-parsed
#        by sh the way tmux intended — important for entries like
#        command-prompt whose arg is itself a tmux command.
#
# Why double quotes around <RAW> rather than single
# =================================================
# tmux-which-key emits each menu variable as
# `set -g @wk_menu_* '...'` — a SINGLE-quoted outer tmux string with
# no escape mechanism. If our wrap used single quotes around <RAW>,
# the first one would prematurely terminate that outer string and
# break every entry after it. Double quotes in sh preserve the
# content except for $, `, \ and "; we escape those four at wrap
# time and tmux is happy.
#
# Installation (one-time)
# =======================
# 1. Ensure `~/bin` is in PATH (or use an absolute path in the
#    YAML).
# 2. Enable the XDG-ed config path for the plugin in
#    ~/.tmux.conf.local so the YAML lives somewhere yadm tracks:
#       set -g @tmux-which-key-xdg-enable 1
# 3. Regenerate the YAML with every command wrapped by running the
#    companion tool:
#       python3 ~/bin/tmux-which-key-wrap-yaml.py  \
#           < ~/.config/tmux/plugins/tmux-which-key/config.yaml \
#           > /tmp/config.wrapped.yaml
#       cp /tmp/config.wrapped.yaml \
#          ~/.config/tmux/plugins/tmux-which-key/config.yaml
# 4. Rebuild the menu (regenerates init.tmux and reloads vars):
#       ~/.tmux/plugins/tmux-which-key/plugin.sh.tmux
#
# See ~/bin/tmux-which-key-wrap-yaml.py for the escape-chain details
# and why the YAML source has ugly 4-backslash sequences.
#
# Matching caveats
# ================
# * The command from the menu is normalised before lookup: trimmed,
#   stripped of the `-c '#{pane_current_path}'` decoration oh-my-tmux
#   inlines, and its first word is expanded from the short alias to
#   the canonical form via `tmux list-commands` (e.g. `neww` ->
#   `new-window`). Without this, `list-keys` reports the long form
#   while the menu entry uses the short form and literal compares
#   always miss.
# * All matches are reported, joined by " | ". A single command
#   often has several bindings (Enter + Escape + [ all enter
#   copy-mode, for example) and seeing them all is more useful
#   than picking one.
# * Menu navigation entries that run multi-step chains ending in
#   `show-wk-menu #{...}` will typically show no shortcut — they
#   are not a single canonical tmux command.
#
# ---------------------------------------------------------------

set -eu

# Collect the full command (as a single string) that the YAML asked us
# to wrap. Quoting at the call site should keep it in "$*" verbatim.
cmd="$*"

if [ -z "$cmd" ]; then
    tmux display-message "tmux-which-key-learn: called with empty command"
    exit 1
fi

# Normaliser: strip whitespace and the oh-my-tmux "retain current path"
# decoration that makes otherwise-identical commands fail to compare.
normalize() {
    printf '%s' "$1" \
        | sed -E "s/ -c [\"']?#\{pane_current_path\}[\"']?//g" \
        | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//'
}

# tmux ships short aliases for many commands (`neww` == `new-window`,
# `splitw` == `split-window`, `selectp` == `select-pane`, ...). The
# plugin YAML usually uses the short forms, but `tmux list-keys`
# prints the canonical (long) name — so a literal compare misses.
# Parse `tmux list-commands` once to build an alias->canonical map,
# and expand the first word of a command through it before matching.
#
# Format of the list: "canonical (alias) [-flags] ..."  — we only
# care about the first two tokens.
expand_alias() {
    local cmd=$1
    local first=${cmd%% *}
    local rest=${cmd#"$first"}
    local canonical
    canonical=$(tmux list-commands 2>/dev/null \
        | sed -nE "s/^([a-z-]+) \(${first}\).*/\1/p" \
        | head -1)
    if [ -n "$canonical" ]; then
        printf '%s%s' "$canonical" "$rest"
    else
        printf '%s' "$cmd"
    fi
}

needle=$(expand_alias "$(normalize "$cmd")")

# Scan list-keys for any binding whose command matches the needle.
# list-keys output is always: `bind-key [-flags] -T <table> <key> <cmd...>`.
# We use awk for safe field walking since the command part can contain
# spaces and quotes. All matches are printed so the caller can join them
# — it's common to have multiple keys (e.g. Enter, Escape, [) bound to
# the same command, and showing all of them is more informative.
shortcut=$(tmux list-keys 2>/dev/null | awk -v needle="$needle" '
    $1 == "bind-key" {
        i = 2
        table = "root"
        # Skip over flags: -r, -n, -N "note", -T <table>
        while (i <= NF && substr($i, 1, 1) == "-") {
            if ($i == "-T") { table = $(i+1); i += 2; continue }
            if ($i == "-N") { i += 2; continue }   # -N has a quoted arg
            i++
        }
        if (i > NF) next
        key = $i
        cmd = ""
        for (j = i + 1; j <= NF; j++) cmd = (cmd == "") ? $j : cmd " " $j

        # Normalise like the shell side does
        sub(/^[[:space:]]+/, "", cmd); sub(/[[:space:]]+$/, "", cmd)
        gsub(/ -c "#\{pane_current_path\}"/, "", cmd)
        gsub(/ -c '"'"'#\{pane_current_path\}'"'"'/, "", cmd)
        gsub(/ -c #\{pane_current_path\}/, "", cmd)

        if (cmd == needle) {
            print table " + " key
        }
    }
' | paste -sd '|' - | sed 's/|/ | /g')

# Flash the hint line. We use a longer display-time so there is enough
# time to actually read it; the command still fires immediately after.
if [ -n "$shortcut" ]; then
    tmux display-message -d 3500 "ran: $cmd   (shortcut: $shortcut)"
else
    tmux display-message -d 2500 "ran: $cmd"
fi

# Execute the originally-requested command. `eval tmux` so that any
# tmux command arguments quoted inside "$cmd" are parsed as tmux
# intended, not mashed together.
eval tmux "$cmd"
