# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

source ~/.alias
source ~/.bash_functions

# The root of all custom-installed stuff
export ENV_ROOT=/env
OPT_ROOT=$ENV_ROOT/opt/ubu24
source $ENV_ROOT/cfg/sbruf.env.bash

# Avoid autocompletion escape the $ sign (so allow expansion of env vars)
shopt -s direxpand

# stty only for interactive shells (so scp does not complain for invalid ioctl for device)
[[ $- == *i* ]] && stty sane

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# Tmux starts its own terminal
[ -z "$TMUX" ] && export TERM=xterm-256color

# Use vi keybindings
set -o vi

# Set default editor
export EDITOR=nvim
export VISUAL=nvim

# autojump (replaced by zoxide, need to make sure NNN works without autojump)
# [[ -s $HOME/local/autojump/etc/profile.d/autojump.sh ]] && source $HOME/local/autojump/etc/profile.d/autojump.sh

# fuzzy finder
module load fzf &> /dev/null
[ -f $OPT_ROOT/fzf/shell/completion.bash ] && source $OPT_ROOT/fzf/shell/completion.bash
[ -f $OPT_ROOT/fzf/shell/key-bindings.bash ] && source $OPT_ROOT/fzf/shell/key-bindings.bash

# nnn
module load nnn/4.5 &> /dev/null
[ -f $HOME/nnn.bash ] && source $HOME/nnn.bash
[ -f $OPT_ROOT/nnn/4.5/misc/auto-completion/bash/nnn-completion.bash ] && source $OPT_ROOT/nnn/4.5/misc/auto-completion/bash/nnn-completion.bash 

module load bat btm dust exa fd hyperfine mdbook procs ripgrep sd tealdeer


module load starship &> /dev/null
# eval starship init script (only on interactive shells)
[[ $_ == *i* ]] && eval "$(starship init bash)"

module load viu
module load ytop
module load python
module load rust
module load neovim

# add env var used to run git -c delta.side-by-side=true delta with less typing
module load delta
export sbs='-c delta.side-by-side=true'

# Source stuff needed by rust compiler
. "$HOME/.cargo/env"

# WSL
[ -f ~/.wsl.bash ] && source ~/.wsl.bash

# make sure that the output of modulefiles goes to stdout (instead of stderr) 
# this is needed by sbruf
export MODULES_REDIRECT_OUTPUT=1

# sstdev
# module unload sstdev/4.0 > /dev/null
# module load sstdev/4.0 > /dev/null

# autocomplete with a single tab
bind 'set show-all-if-ambiguous on'
# autocomplete ignoring case
bind 'set completion-ignore-case on'

# Register sbruf custom bash autocompleters
# This section must be AFTER module load sstdev b/c SST_REPO/scripts must be in PATH
# Setup sbruf autocompletion
complete -C compl_sbruf.py sbruf

# We don't manage NVM via modulefiles, so use a traditional approach here
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

#  biocan
[ -f ~/.biocan.bash ] && source ~/.biocan.bash

# jiner
export JNR_CFG_FILE=$HOME/.config/jiner/jiner.toml

# windows shortcuts if on WSL
[ -d /mnt/c/Users/matti ] && export WIN_HOME=/mnt/c/Users/matti
[ -d /mnt/c/Users/matti/STM32CubeIDE/workspace_2.0.0 ] && export WIN_STM=/mnt/c/Users/matti/STM32CubeIDE/workspace_2.0.0

# zoxide should be init towards the end to avoid issues
module load zoxide &> /dev/null
# eval zoxide init script (only on interactive shells)
[[ $_ == *i* ]] && eval "$(zoxide init --cmd=j bash)"

