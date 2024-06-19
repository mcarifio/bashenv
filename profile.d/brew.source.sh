# usage: source brew.source.sh [--install] [--verbose] [--trace]

# brew is in an odd location
/home/linuxbrew/.linuxbrew/bin/brew --version &> /dev/null || return 0

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

eval "${_guard}.install.fedora() ( set -x; ujust install-${_guard}; )"
f.x ${_guard}.install.fedora

eval "${_guard}.install.ubuntu() ( set -x; sudo apt upgrade -y; sudo apt install -y ${_guard}; )"
f.x ${_guard}.install.ubuntu

# source ${_guard}.guard.sh --install
if (( ${_option[install]} )) && ! u.have ${_guard}; then
    ${_guard}.install ${_rest} || return $(u.error "${_guard}.install failed")
fi


# _guard itself

# not working
brew.parse() (
    : '## example: parse callers arglist'
    set -uEeo pipefail
    shopt -s nullglob
    declare -A brew_options=([file]="${PWD}/${FUNCNAME}" [comment]="${HOSTNAME}:and_some_stuff" [trace]=0)
    local -a _rest=( $(u.parse brew_options --foo=bar --user=${USER} --trace 1 2 3) )
    printf '%s ' ${FUNCNAME}; declare -p brew_options; printf '%s ' ${_rest[@]}
)

# TODO mike@carif.io: logic needs fixing
__brew.parse.complete() {
    :
}

f.complete brew.parse


brew.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x brew.env

# `brew shellenv` *side effects* the bash environment so it's at the start of each session.
# This seems broken to me.
brew.session() {
    source <(/home/linuxbrew/.linuxbrew/bin/brew shellenv) || return $(u.error "${FUNCNAME} failed")
    export HOMEBREW_NO_ENV_HINTS="$(path.pn ${BASH_SOURCE})"
}
f.x brew.session
# try to run once to avoid adding brew to PATH multiple times
u.singleton brew.session

loaded "${BASH_SOURCE}"
