# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Avoid autocompletion escape the $ sign (so allow expansion of env vars)
shopt -s direxpand

# stty only for interactive shells (so scp does not complain for invalid ioctl for device)
[[ $- == *i* ]] && stty sane

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# Tmux starts its own terminal
[ -z "$TMUX" ] && export TERM=xterm-256color

#   -------------------------------- #
#              Functions             #
#   -------------------------------- # 

#
#   -------- prepend-path ---------- #
#
function prepend_path () {
    
    # Retrieve input args
    if [[ $1 == '-h' || $1 == '--help' ]]; then
        echo "Usage: prepend-path <pathvar> <newpath>"
        return
    fi
    pathvar=$1
    newpath=$2
    
    # Start building line to be evaluated
    eval_line="$pathvar=$newpath"

    # Check whether the pathhvar variable is defined (either exported or not)
    is_defined=$(env | grep $pathvar)
    if [[ -z $is_defined ]]; then
        compgen -v | grep $pathvar  > /tmp/ppath.tmp
        sz=$(wc -c /tmp/ppath.tmp | cut -d' ' -f 1)
        rm -f /tmp/ppath.tmp
        if [[ $sz > 0 ]]; then
            is_defined=1
        fi
    fi
       
    # If it is, then add the new path to it 
    if [[ -n $is_defined ]]; then
        eval_line+=':$'
        eval_line+="$pathvar"
    fi

    # Finally eval the line
    eval "$eval_line"
    # Export the variable if it was not defined
    eval "export $pathvar"

}
export -f prepend_path


#
#   -------- append-path ---------- #
#
function append_path () {
    
    # Retrieve input args
    if [[ $1 == '-h' || $1 == '--help' ]]; then
        echo "Usage: append-path <pathvar> <newpath>"
        return
    fi
    pathvar=$1
    newpath=$2
    

    # Check whether the pathhvar variable is defined (either exported or not)
    is_defined=$(env | grep $pathvar)
    if [[ -z $is_defined ]]; then
        compgen -v | grep $pathvar  > /tmp/ppath.tmp
        sz=$(wc -c /tmp/ppath.tmp | cut -d' ' -f 1)
        rm -f /tmp/ppath.tmp
        if [[ $sz > 0 ]]; then
            is_defined=1
        fi
    fi
       
    # If it is, then add the new path to it 
    if [[ -n $is_defined ]]; then
        eval_line="$pathvar="
        eval_line+='$'
        eval_line+="$pathvar:"
        eval_line+="$newpath"
    else
        eval_line="$pathvar=$newpath; export $pathvar"
    fi

    # Finally eval the line
    eval "$eval_line"
    # Export the variable if it was not defined
    eval "export $pathvar"

}
export -f append_path


#
#   -------- split_path ---------- #
#
function split_path() {
    
    # Retrieve input args
    if [[ $1 == '-h' || $1 == '--help' ]]; then
        echo "Usage: split_path <pathvar>"
        return
    fi
    
    # Print splitted path
    echo $1 | sed 's/:/\n/g' 
}
export -f split_path


#
#   -------- export_var ---------- #
#
# Not very useful. Provided to show how code executed in a function applies to
# the current shell.
function export_var () {
    varname=$1
    value="$2"
    export $varname="$value"     
}
export -f export_var


#
#   -------- hl (highlight) ---------- #
#
# print input to hl function to stdout but highlight pattern in color.
#
# Usage: echo "foo" | hl red foo
# 
# Stolen from https://github.com/kepkin/dev-shell-essentials/blob/master/highlight.sh
# Call it hl Vs. highlight b/c/ the latter is a binary in /usr/bin
function hl() {
	declare -A fg_color_map
	fg_color_map[black]=30
	fg_color_map[red]=31
	fg_color_map[green]=32
	fg_color_map[yellow]=33
	fg_color_map[blue]=34
	fg_color_map[magenta]=35
	fg_color_map[cyan]=36
	 
	fg_c=$(echo -e "\e[1;${fg_color_map[$1]}m")
	c_rs=$'\e[0m'
	sed -u s"/$2/$fg_c\0$c_rs/g"
}

# Use vi keybindings
set -o vi
   
source ~/.alias

# Set default editor
export EDITOR=nvim
export VISUAL=nvim

# [[ -f ~/local/fzf-tab-completion/bash/fzf-bash-completion.sh ]] && source ~/local/fzf-tab-completion/bash/fzf-bash-completion.sh && bind -x '"\t": fzf_bash_completion'


# autojump
[[ -s $HOME/local/autojump/etc/profile.d/autojump.sh ]] && source $HOME/local/autojump/etc/profile.d/autojump.sh

# fuzzy finder
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# nnn
[ -f ~/.nnn.bash ] && source ~/.nnn.bash

# alacritty completions
[ -f ~/.alacritty.bash ] && source ~/.alacritty.bash

# biocan
[ -f ~/.biocan.bash ] && source ~/.biocan.bash

# add env var used to run git -c delta.side-by-side=true delta with less typing
export sbs='-c delta.side-by-side=true'

# Source stuff needed by rust compiler
. "$HOME/.cargo/env"

[ -f ~/.wsl.bash ] && source ~/.wsl.bash

# source starship init script (only on interactive shells)
[[ $_ == *i* ]] && eval "$(starship init bash)"

eval "$(zoxide init --cmd=j bash)"

source /sicoe3/cfg/sbruf.env.bash

export JNR_CFG_FILE=$HOME/.config/jiner/jiner.toml

export MODULES_REDIRECT_OUTPUT=1
module load neovim
module unload sstdev/4.0 > /dev/null
module load sstdev/4.0 > /dev/null

# autocomplete with a single tab
bind 'set show-all-if-ambiguous on'
# autocomplete ignoring case
bind 'set completion-ignore-case on'

# This section must be AFTER module load sstdev b/c SST_REPO/scripts must be in PATH
# Setup sbruf autocompletion
complete -C compl_sbruf.py sbruf


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
