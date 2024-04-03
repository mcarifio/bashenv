# usage: [guard | source] _template.guard.sh [--install] [--verbose] [--trace]

# Front matter. Parse the source command line. Install by platform if --install,
# trace (and revert) if --trace.
_guard=$(path.basename ${BASH_SOURCE})
declare -A _option=([install]=0 [verbose]=0 [summarize]=0 [trace]=0)
_undo=''; trap -- 'eval ${_undo}; unset _option _undo; trap -- - RETURN' RETURN

# declare -a _rest=( $(u.parse _option "$@") )
&> /dev/null u.parse _option "$@"
# declare -p _option

if (( ${_option[trace]} )) && ! bashenv.is.tracing; then
    _undo+='set +x;'
    set -x
fi

rdap.install() (
    : 'install the go openrdap client, see https://github.com/openrdap/rdap'
    set -Eeuo pipefail
    set -x
    { u.have go && go install github.com/openrdap/rdap/cmd/rdap@master; } || return $(u.error "${FUNCNAME} failed.")
)
f.x rdap.install

# source ${_guard}.guard.sh --install
if (( ${_option[install]} )) && ! u.have ${_guard}; then
    ${_guard}.install ${_rest} || return $(u.error "${_guard}.install failed")
fi

rdap.exists() (
    : '${_tld} # return 0 iff top level domain ${_tld} exists'
    set -Eeuo pipefail
    local _tld="${1:?'expecting a top level domain e.g. google.com'}"
    &>/dev/null rdap "${_tld}"
)
f.x rdap.exists

rdap.browse() (
    : '${_tld} # return 0 iff top level domain ${_tld} exists'
    set -Eeuo pipefail
    local _tld="${1:?'expecting a top level domain e.g. google.com'}"
    rdap.exists ${_tld} && xdg-open http://${_tld} || return $(u.error "${_tld} not registered")
)
f.x rdap.browse

rdap.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x rdap.env

rdap.session() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x rdap.session

loaded "${BASH_SOURCE}"
