# usage: [guard | source] flatpak.guard.sh [--install] [--verbose] [--trace]

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


# guard itself

# not working
_flatpak.parse() (
    : '## example: parse callers arglist'
    set -uEeo pipefail
    shopt -s nullglob
    declare -A _flatpak_options=([file]="${PWD}/${FUNCNAME}" [comment]="${HOSTNAME}:and_some_stuff" [trace]=0)
    local -a _rest=( $(u.parse _flatpak_options --foo=bar --user=${USER} --trace 1 2 3) )
    printf '%s ' ${FUNCNAME}; declare -p _flatpak_options; printf '%s ' ${_rest[@]}
)
f.x _flatpak.parse


flatpak.wrap() {
    : '# wrap each flatpak app with a bash function fp.${id} to simplify invocation. `fp.` prefix assists bash completion'
    local -A _defined=()
    for _id in $(flatpak list --app --columns=application); do
        local _command=${_id##*.}; _command=${_command,,}
        if (( _defined[${_command}] )); then
            echo >&2 "${_command} already defined, skipping..."
        else
            eval "fp.${_command}()(flatpak run ${_id} \"\$@\";)"
            f.x fp.${_command}
            _defined[${_command}]=1
        fi        
    done    
}
f.x flatpak.wrap
flatpak.wrap


flatpak.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x flatpak.env

flatpak.session() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x flatpak.session

loaded "${BASH_SOURCE}"
