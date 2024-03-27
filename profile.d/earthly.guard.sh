# usage: source earthly.guard.sh [--install] [--verbose] [--trace]
_guard=$(path.basename ${BASH_SOURCE})
declare -A _option=([install]=0 [verbose]=0 [trace]=0)
_undo=''; trap -- 'eval ${_undo}; unset _option _undo; trap -- - RETURN' RETURN
local -a _rest=( $(u.parse _option "$@" )
if (( ${_option[trace]} )) && ! bashenv.is.tracing; then
    _undo+='set +x;'
    set -x
fi
if (( ${_option[install]} )); then
    if u.have ${_guard}; then
        >&2 echo ${_guard} already installed
    else
        bashenv.install.exe https://github.com/earthly/earthly/releases/latest/download/earthly-linux-amd64 ${HOME}/.local/bin/${_guard}
        earthly --bootstrap
        command ${_guard} --version
    fi
fi

earthly.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x earthly.env

earthly.session() {
    earthly bootstrap --with-autocomplete
}
f.x earthly.session

loaded "${BASH_SOURCE}"
