# .bash_profile

source $(realpath ${BASH_SOURCE}).lib.sh || true
export PATH="$(path.login):${PATH}"
source.bash_profile.d
source.bashrc.d
source.bash_completion.d

# User specific aliases and functions
[[ -r ~/.bashrc ]] && source ~/.bashrc
