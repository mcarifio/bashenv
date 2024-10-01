${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

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

sourced || true

