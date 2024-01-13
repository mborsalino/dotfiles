# .bash_profile

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
. "$HOME/.cargo/env"

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# New environment setting added by Protex on Wed Oct 12 15:18:11 CEST 2022 1.
# The unmodified version of this file is saved in /home/mborsali/.bash_profile907375172.
# Do NOT modify these lines; they are used to uninstall.
PATH="/opt/blackduck/protexIP/bin:${PATH}"

export PATH
# End comments by InstallAnywhere on Wed Oct 12 15:18:11 CEST 2022 1.
