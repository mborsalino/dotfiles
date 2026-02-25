# .bash_profile

if [ -f $HOME/.bash_profile.cb ]; then
    . $HOME/.bash_profile.cb
fi

# User specific environment and startup programs
PATH=$HOME/.local/bin:$HOME/bin:$PATH

# Mattia's special paths on lilliput
PATH+=:$HOME/scripts/:$HOME/scripts/sync_mosys:$HOME/vpn
export PATH

# Mattia's modules
# MODULEPATH=/usr/share/Modules/modulefiles:/etc/modulefiles:/mosys/modulefiles/cad:/mosys/modulefiles/proj
# MODULEPATH=/usr/share/Modules/modulefiles:/etc/modulefiles:/mosys/modulefiles/cad:/mosys/modulefiles/proj
# export MODULEPATH

# source cargo env (needed for Rust)
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env" 

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi
