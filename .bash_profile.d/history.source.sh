running.bash
_for=$(basename ${BASH_SOURCE} .source.sh)
u.have ${_for} || return 0
eval "declare -ix _load_count_${_for}"

# add global functions here

history.env() {
    : 'history.env [${_size}]'
    export HISTSIZE=${1:-10000}
    export HISTFILESIZE=$(( 10 * HISTSIZE ))
    shopt -s histappend
    export HISTCONTROL=$HISTCONTROL:ignorespace:ignoredups
}; declare -fx history.env

eval "${_for}.load_count() ( echo \$_load_count_${_for}; ); declare -fx ${_for}.load_count"
if (( _load_count_${_for} == 0 )); then
    type ${_for}.env &> /dev/null || return 0
    ${_for}.env "$@"
else
    type ${_for}.env &> /dev/null || return 0
    >&2 echo "${_for}.env # run?"
fi
(( ++_load_count_${_for} ))
