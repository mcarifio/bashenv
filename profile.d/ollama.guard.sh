# usage: [guard | source] ollama.guard.sh [--install] [--verbose] [--trace]

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
# eval "${_guard}.install() ( ${_guard}.install.\$(os-release.id); )"
eval "${_guard}.install() ( ${FUNCNAME}.asdf \"\$@\"; )"
f.x ${_guard}.install

eval "${_guard}.install.fedora() ( set -x; dnf install ${_guard}; )"
f.x ${_guard}.install.fedora

eval "${_guard}.install.ubuntu() ( set -x; sudo apt upgrade -y; sudo apt install -y ${_guard}; )"
f.x ${_guard}.install.ubuntu

# source ${_guard}.guard.sh --install
if (( ${_option[install]} )) && ! u.have ${_guard}; then
    ${_guard}.install ${_rest} || return $(u.error "${_guard}.install failed")
fi


# stopgap measure
ollama.install.asdf() (
    set -Eeuo pipefail
    asdf plugin-add ollama https://github.com/virtualstaticvoid/asdf-ollama.git
    asdf install ollama latest
    asdf global ollama latest
    # https://github.com/ollama/ollama/blob/main/docs/linux.md
    # sudo useradd --system --shell /bin/false --create-home --home-dir /usr/share/ollama ollama    
)
f.x ollama.install.asdf


# ollama itself
# not working
_ollama.parse() (
    : '## example: parse callers arglist'
    set -uEeo pipefail
    shopt -s nullglob
    declare -A _ollama_options=([file]="${PWD}/${FUNCNAME}" [comment]="${HOSTNAME}:and_some_stuff" [trace]=0)
    local -a _rest=( $(u.parse _ollama_options --foo=bar --user=${USER} --trace 1 2 3) )
    printf '%s ' ${FUNCNAME}; declare -p _ollama_options; printf '%s ' ${_rest[@]}
)

# TODO mike@carif.io: logic needs fixing
f.x _ollama.parse

_ollama.server() (
    : ' ${service} ## starts ollama systemd service ${service}'
   set -Eeuo pipefail
   local _service=${1:-${FUNCNAME%.*}.service}

   # Is the service enabled?
   if ! systemctl --user --quiet is-enabled ${_service}; then
       # Service isn't enabled. Let's do so. This might override the user's policy.
       # Symlink a service unit definition into systemd's "user" folder ~/.config/systemd/user/.
       # The .service file is distro specific (nixos, fedora, etc) b/c I don't know enough systemd to customize a single one.
       local _unit="$(home)/.config/systemd/user/${_service}"
       [[ -r "${_unit}" ]] || ln -sf "$(u.here)/.config/systemd/user/${_service}" "$(path.mp ${_unit})"


       # Enable the service and start it.
       systemctl --user enable --now ${_service} || return $(u.error "${FUNCNAME} cannot enable ${_service}")
   fi

   # Is the service running (active)? If not, try starting it manually.
   # This should be rare but covers the case where the user has manually stopped the service and
   #  forgotten to restart it.
   if systemctl --user --quiet is-active ${_service} ; then
       systemctl --user start ${_service} || return $(u.error "${FUNCNAME} cannot start ${_service}")
   fi
)
f.x _ollama.server


ollama.server.log() (
    set -Eeuo pipefail
    local _service=${1:-${FUNCNAME%.*}.service}
    journalctl --user --boot 0 --unit ${_service} # grep something
)
f.x ollama.server.log


ollama.server() ( _${FUNCNAME} ${FUNCNAME%.*}.service; )
f.x ollama.server


ollama.env() (
    set -Eeuo pipefail
    ollama.server || return $(u.error "cannot start ollama service in login shell $$")
)
f.x ollama.env

ollama.session() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x ollama.session

loaded "${BASH_SOURCE}"
