# must be in bash with a history command
source.guard $(path.basename ${BASH_SOURCE}) || return 0

history.env() {
    : 'history.env [${_size}]'
    export HISTSIZE=${1:-10000}
    export HISTFILESIZE=$(( 10 * HISTSIZE ))
    shopt -s histappend
    export HISTCONTROL=$HISTCONTROL:ignorespace:ignoredups
}; declare -fx history.env


# call history.env() on first load only. history.load_count() counts the number of loads.
eval "declare -ix _load_count_${_for}"
eval "${_for}.load_count() ( echo \$_load_count_${_for}; ); declare -fx ${_for}.load_count"
u.have ${_for}.env && (( _load_count_${_for} == 0 )) && ${_for}.env "$@"
(( ++_load_count_${_for} ))

