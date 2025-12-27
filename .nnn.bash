# The following function is a wrapper to nnn that configures "cd on exit"
# When you invoke nnn_wrap (through the "n" alias below) instead of directly
# invoking nnn, you'll be able to press CTRL+G to quit nnn and cd to the last
# directory.
nnn_wrap ()
{
    # Block nesting of nnn in subshells
    if [ -n $NNNLVL ] && [ "${NNNLVL:-0}" -ge 1 ]; then
        echo "nnn is already running"
        return
    fi

    # The behaviour is set to cd on quit (nnn checks if NNN_TMPFILE is set)
    # To cd on quit only on ^G, either remove the "export" as in:
    #    NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
    #    (or, to a custom path: NNN_TMPFILE=/tmp/.lastd)
    # or, export NNN_TMPFILE after nnn invocation
    # export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
    NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"

    # Unmask ^Q (, ^V etc.) (if required, see `stty -a`) to Quit nnn
    # stty start undef
    # stty stop undef
    # stty lwrap undef
    # stty lnext undef

    nnn "$@"

    if [ -f "$NNN_TMPFILE" ]; then
            . "$NNN_TMPFILE"
            rm -f "$NNN_TMPFILE" > /dev/null
    fi
}

# Plugins to be used and corresponding shortcut to trigger them
export NNN_PLUG='j:autojump;f:fzopen;p:preview-tui;i:imgview'

# Bookmakrs to be used and corresponding shortcut to trigger them
export NNN_BMS="b:$HOME/.config/nnn/bookmarks;p:$HOME/proj/mst/stellar/prod/gme/src/python/pygme;g:$HOME/proj/mst/stellar/prod/gme/src/;s:$HOME/proj/mst/stellar"

# The following is used by preview-tui plugin
export NNN_FIFO=/tmp/nn.fifo

# Show hidden files
export NNN_OPTS="H"

# Use something like the line below to change color of entries
# export NNN_FCOLORS='0000E6310000000000000000'

# Mattia's preferred alias. Lookup nnn -h to find out more
alias n='nnn_wrap -de -o -U'
