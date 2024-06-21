# usage: [guard | source] wasmer.guard.sh [--install] [--verbose] [--trace]

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

# install by distro id by (runtime) dispatching to distro install function
eval "${_guard}.install() ( ${_guard}.install.\$(os-release.id); )"
f.x ${_guard}.install

eval "${_guard}.install.fedora() ( set -x; dnf install ${_guard}; )"
f.x ${_guard}.install.fedora

eval "${_guard}.install.ubuntu() ( set -x; sudo apt upgrade -y; sudo apt install -y ${_guard}; )"
f.x ${_guard}.install.ubuntu

# source ${_guard}.guard.sh --install
if (( ${_option[install]} )) && ! u.have ${_guard}; then
    ${_guard}.install ${_rest} || return $(u.error "${_guard}.install failed")
fi


# wasmer itself

# not working
_wasmer.parse() (
    : '## example: parse callers arglist'
    set -uEeo pipefail
    shopt -s nullglob
    declare -A _template_options=([file]="${PWD}/${FUNCNAME}" [comment]="${HOSTNAME}:and_some_stuff" [trace]=0)
    local -a _rest=( $(u.parse _template_options --foo=bar --user=${USER} --trace 1 2 3) )
    printf '%s ' ${FUNCNAME}; declare -p _wasmer_options; printf '%s ' ${_rest[@]}
)

# TODO mike@carif.io: logic needs fixing
f.x _wasmer.parse


wasmer.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x wasmer.env

wasmer.session() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x wasmer.session

loaded "${BASH_SOURCE}"
