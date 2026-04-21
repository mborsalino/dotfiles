#!/usr/bin/env python3
"""
tmux-which-key-wrap-yaml.py
===========================
Rewrite every `command:` line in a tmux-which-key config.yaml so it
dispatches through the learn-wrapper at `~/bin/tmux-which-key-learn.sh`.
Picking an item from the menu then flashes the executed tmux command
along with its direct keybinding (if any), turning the menu into a
teaching aid instead of a permanent crutch.

Usage
-----
    python3 ~/bin/tmux-which-key-wrap-yaml.py  \\
        < ~/.config/tmux/plugins/tmux-which-key/config.yaml \\
        > /tmp/config.wrapped.yaml

    # review the diff, then overwrite the real config:
    cp /tmp/config.wrapped.yaml \\
       ~/.config/tmux/plugins/tmux-which-key/config.yaml
    # force a menu rebuild so init.tmux regenerates:
    ~/.tmux/plugins/tmux-which-key/plugin.sh.tmux

The transform is idempotent: rerunning it on an already-wrapped
file is a no-op because wrapped commands are detected by the
substring "tmux-which-key-learn.sh".

The `macros:` top-level block is skipped entirely — each entry there
is a multi-step action, and wrapping every step would flood the
status line with messages.

Why the escape chain is three layers deep
-----------------------------------------
Picking a menu item has this parse path, each level unescaping once:

    [ YAML value ]  --(pyyaml double-quoted)-->  [ Python string ]
                                                         |
                                       build.py passes the string
                                       through add_quotes() which
                                       wraps it in double quotes
                                       and does s.replace('"', '\\"')
                                       — NO backslash escaping.
                                                         v
    [ init.tmux token ]  --(tmux arg parser, "...")-->  [ L0 ]
                                                         |
                                                         v
                             tmux runs L0 which is `run-shell "..."`
                             tmux parses the "..." arg, passes
                             its content (one string) to /bin/sh -c
                                                         v
    [ sh double-quoted arg ]  --(sh expansion)-->  one positional arg
                                                         v
              ~/bin/tmux-which-key-learn.sh "cmd"

Because build.py's add_quotes only escapes `"` (not `\`), any
backslash we want tmux to see in its parser must already be DOUBLED
in the Python string. So the YAML source has to emit Python strings
that already look pre-escaped for tmux; combined with YAML's own
double-quoted escape rules (`\\` -> `\`, `\"` -> `"`), this multiplies
backslash counts at each `\\"` sequence: YAML needs 4 backslashes
and one escaped quote (`\\\\\\"` — five chars) to encode what will
ultimately be a literal `\"` passed to sh.

Why double quotes around the user command, never single quotes
--------------------------------------------------------------
tmux-which-key emits menu variable values as
`set -g @wk_menu_* '...'`. That outer single-quoted tmux string
has no escape mechanism — it ends at the first inner `'`. So ANY
single quote we emit inside a wrapped command would truncate the
menu variable and corrupt every entry that follows. Double quotes
in sh preserve a literal string except for `$`, `` ` ``, `\` and
`"`; we escape those four and we're fine.

Companion files
---------------
* `~/bin/tmux-which-key-learn.sh` — the runtime wrapper this YAML
  dispatches to. Owns the keybinding lookup and the display-message
  flash.
* `~/.config/tmux/plugins/tmux-which-key/config.yaml` — the YAML
  this script operates on (path depends on
  `@tmux-which-key-xdg-enable 1` in ~/.tmux.conf.local).
"""
import re
import sys

HELPER = "$HOME/bin/tmux-which-key-learn.sh"
WRAPPER_MARK = "tmux-which-key-learn.sh"


def unquote_yaml(value: str) -> str:
    v = value.strip()
    if len(v) >= 2 and v[0] == '"' and v[-1] == '"':
        inner = v[1:-1]
        inner = re.sub(r'\\(.)', r'\1', inner)
        return inner
    if len(v) >= 2 and v[0] == "'" and v[-1] == "'":
        return v[1:-1].replace("''", "'")
    return v


def wrap(raw: str) -> str:
    # 1. Escape raw for sh inside a double-quoted arg: \, ", $, `
    sh_inner = (raw
        .replace('\\', '\\\\')
        .replace('"', '\\"')
        .replace('$', '\\$')
        .replace('`', '\\`')
    )
    # 2. L0 = the tmux command we ultimately want executed:
    #    run-shell "HELPER \"sh_inner\""
    l0 = f'run-shell "{HELPER} \\"{sh_inner}\\""'
    # 3. build.py writes init.tmux by calling add_quotes() on whatever
    #    Python string pyyaml produced. add_quotes only escapes `"`
    #    (not `\`), so we must pre-double every backslash so that the
    #    init.tmux output keeps the right backslash count for tmux's
    #    own string parser to recover L0.
    s = l0.replace('\\', '\\\\')
    # 4. YAML double-quoted escape of S: \ -> \\ and " -> \"
    yaml_val = s.replace('\\', '\\\\').replace('"', '\\"')
    return f'"{yaml_val}"'


def process(text: str):
    lines = text.split('\n')
    out = []
    in_macros = False
    wrapped = 0

    for line in lines:
        # Track the top-level `macros:` block so we never wrap inside it.
        if re.match(r'^macros:\s*$', line):
            in_macros = True
            out.append(line); continue
        if re.match(r'^[a-zA-Z_][^:]*:\s*$', line) and not line.startswith(' '):
            in_macros = line.startswith('macros:')

        if in_macros:
            out.append(line); continue

        m = re.match(r'^(\s*)command:\s*(.*)$', line)
        if not m:
            out.append(line); continue

        indent, val = m.group(1), m.group(2)
        if not val.strip() or WRAPPER_MARK in val:
            out.append(line); continue

        raw = unquote_yaml(val)
        out.append(f'{indent}command: {wrap(raw)}')
        wrapped += 1

    return '\n'.join(out), wrapped


if __name__ == '__main__':
    data = sys.stdin.read()
    result, w = process(data)
    sys.stdout.write(result)
    sys.stderr.write(f'[tmux-which-key-wrap-yaml] wrapped={w}\n')
