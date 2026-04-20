#!/usr/bin/env bash
#
# tmux-extrakto-copy-osc52.sh
# ===========================
# Clipboard hook for the extrakto tmux plugin (laktak/extrakto) that
# copies the selected text to the SYSTEM CLIPBOARD via an OSC 52
# terminal escape sequence — and, as a bonus, saves it to a tmux
# paste buffer so `prefix + b` can still find it later.
#
# The filename follows the convention `tmux-<plugin>-<function>.sh`
# so it is immediately obvious from `ls ~/bin` which tmux plugin
# and role a helper belongs to.
#
# -----------------------------------------------------------------
# Problem this solves
# -----------------------------------------------------------------
# Extrakto's default clipboard path autodetects one of
# xclip / xsel / wl-copy / pbcopy / clip.exe. On minimal remote
# servers (plain Rocky 8, RHEL, SLES, stripped-down Ubuntus, ...)
# none of those are installed, so extrakto's post-selection step
# fails with:
#
#     'tmux show-buffer|xclip -i -selection clipboard >/dev/null' returned 127
#
# Exit code 127 is "command not found". Installing xclip on every
# remote is impractical and forwarding X just to copy a line of
# text is heavy.
#
# -----------------------------------------------------------------
# Why OSC 52 is the right answer
# -----------------------------------------------------------------
# OSC 52 is a terminal control sequence (`ESC ] 52 ; c ; <base64> BEL`)
# that asks the TERMINAL EMULATOR to copy the given text to the
# system clipboard. The text flows through tmux and SSH transparently
# because it's just bytes. The terminal at the OUTER end (Windows
# Terminal, WezTerm, Ghostty, Alacritty, iTerm2, Kitty, ...) is the
# one doing the actual clipboard write — no host-side clipboard tool
# needed on any machine along the chain.
#
# tmux's `set -g set-clipboard on` makes tmux FORWARD OSC 52 escapes
# that it sees in a pane's output up to its client. That setting is
# already on in ~/.tmux.conf.local, so this script only needs to
# emit the escape from inside a pane and tmux does the rest.
#
# -----------------------------------------------------------------
# What the script does (step by step)
# -----------------------------------------------------------------
#  1. Read selected text from stdin (extrakto pipes it in).
#  2. Save the raw text into a tmux paste buffer via
#     `tmux load-buffer -`. This populates `prefix + b` so the
#     selection is also available through tmux's internal buffer
#     history. This step is best-effort: if we happen to be run
#     outside tmux the command is skipped.
#  3. Base64-encode the text (single line, no wraps) — OSC 52
#     mandates base64 encoding so binary-safe bytes pass through.
#  4. Emit the OSC 52 escape (`ESC ] 52 ; c ; <base64> BEL`) to
#     /dev/tty. /dev/tty is the controlling terminal of this
#     process, which inside tmux is the pane's pty. tmux reads
#     that pty, sees OSC 52, and with set-clipboard=on forwards
#     it up to the outer terminal emulator — which finally sets
#     the OS clipboard.
#
# -----------------------------------------------------------------
# Why the tmux config still needs `set -g set-clipboard on`
# -----------------------------------------------------------------
# Without that option, tmux SWALLOWS OSC 52 escapes coming from
# panes instead of forwarding them. The script would emit the
# sequence but tmux would drop it; nothing would reach the
# terminal emulator. The full clipboard path is:
#
#     this script  --(OSC 52 -> /dev/tty)-->  tmux pane
#                                                v
#                                    tmux (set-clipboard=on)
#                                                v
#                               outer terminal emulator
#                                                v
#                                    system clipboard
#
# -----------------------------------------------------------------
# Wiring into extrakto
# -----------------------------------------------------------------
# In ~/.tmux.conf.local:
#
#     set -g @extrakto_clip_tool '$HOME/bin/tmux-extrakto-copy-osc52.sh'
#     set -g @extrakto_clip_tool_run 'fg'
#
# `_run fg` runs the tool synchronously so the OSC 52 escape is
# written before extrakto closes the popup. With `bg` the escape
# may race with popup teardown and get lost.
#
# -----------------------------------------------------------------
# Caveats
# -----------------------------------------------------------------
# * Payload size: most terminals accept OSC 52 payloads up to
#   ~100KB. For typical extrakto selections (URLs, paths, output
#   fragments) this is far more than needed.
# * `base64 -w 0`: the `-w 0` flag (no line wrap) is GNU coreutils
#   specific. macOS/BSD uses `-b 0`. We fall through to `tr -d
#   '\n'` to stay portable.
# * Works only inside tmux: /dev/tty inside a naked shell would
#   not go through tmux's set-clipboard forwarding. If you run
#   this from outside tmux, the OSC 52 is still emitted to the
#   host terminal — which may or may not handle it.

set -eu

# --- Step 1: slurp stdin into a variable ---
# We keep the text around so we can both save to a tmux buffer
# AND base64-encode it for OSC 52. Using a variable rather than
# a tee + process-substitution pipeline keeps the script POSIX-sh
# friendly (though we use #!/usr/bin/env bash for robustness).
payload="$(cat)"

# --- Step 2: save to a tmux paste buffer (best-effort) ---
# Without this, the user loses "copied text is also in prefix+b".
# `load-buffer -` reads from stdin; we re-feed payload via printf
# to avoid an extra cat.
#
# 2>/dev/null suppresses noise if we're outside tmux (unlikely
# but possible). || true swallows a non-zero exit in that case.
printf '%s' "$payload" | tmux load-buffer - 2>/dev/null || true

# --- Step 3: base64-encode in a single line ---
# `base64 -w 0` is GNU (disables wrap); macOS needs `-b 0` but
# `tr -d '\n'` is the lowest-common-denominator way to flatten.
encoded="$(printf '%s' "$payload" | base64 | tr -d '\n')"

# --- Step 4: emit OSC 52 to the controlling terminal ---
# Escape breakdown:
#     \033 = ESC
#     ]    = OSC (Operating System Command) introducer
#     52   = OSC number "set clipboard"
#     ;c;  = target selection 'c' (clipboard; 'p' would be the
#            primary X selection)
#     %s   = the base64 payload
#     \a   = BEL = ST (string terminator) that ends the escape
#
# Prefer /dev/tty (the controlling terminal of this process) so the
# escape is seen by tmux even if stdout has been captured. When the
# script is run without a controlling tty (CI, background hook, or
# a broken popup), fall back to stdout so at least something is
# attempted and the tmux-buffer save above still took effect.
if { : > /dev/tty; } 2>/dev/null; then
    printf '\033]52;c;%s\a' "$encoded" > /dev/tty
else
    # No controlling tty; fall back to stdout so at least the escape
    # is emitted somewhere and the tmux-buffer save stands alone.
    printf '\033]52;c;%s\a' "$encoded"
fi
