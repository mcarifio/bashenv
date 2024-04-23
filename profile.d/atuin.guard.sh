# usage: [guard | source] atuin.guard.sh [--install] [--verbose] [--trace]

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


# _guard itself

# not working
atuin.parse() (
    : '## example: parse callers arglist'
    set -uEeo pipefail
    shopt -s nullglob
    declare -A atuin_options=([file]="${PWD}/${FUNCNAME}" [comment]="${HOSTNAME}:and_some_stuff" [trace]=0)
    local -a _rest=( $(u.parse atuin_options --foo=bar --user=${USER} --trace 1 2 3) )
    printf '%s ' ${FUNCNAME}; declare -p atuin_options; printf '%s ' ${_rest[@]}
)

# TODO mike@carif.io: logic needs fixing
__atuin.parse.complete() {
    :
}

f.complete atuin.parse


atuin.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x atuin.env

atuin.session() {
    [[ -f /usr/share/bash-prexec ]] && source /usr/share/bash-prexec
    source <(atuin init bash) || return $(u.error "${FUNCNAME} failed")
}
f.x atuin.session

loaded "${BASH_SOURCE}"
