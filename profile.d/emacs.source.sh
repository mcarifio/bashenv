${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

# TODO mike@carif.io: use completer for emacsclient (if one exists)?
ec() (
    : '[${_pathname}] ## run emacsclient after starting emacs.service'
    set -Eeuo pipefail; shopt -s nullglob
    emacs.server || return $(u.error "emacs daemon not started")
    [[ -n "${DISPLAY}" ]] && emacsclient --reuse-frame --no-wait --timeout=20 --quiet "$@" || emacsclient --tty --timeout=20 --quiet "$@"
)
f.x ec

ec.fx() (
    : '${function-name} # ec +${lineno} ${pathname} # suitable for emacs'
    set -Eeuo pipefail; shopt -s nullglob
    shopt -s extdebug
    local -a _where=( $(declare -F ${1:?'expecting a function'}) )
    # ${name} ${lineno} ${pathname}    
    [[ main != "${_where[2]}" ]] && ec +${_where[1]} ${_where[2]} || return $(u.error "$1 has no associated file")  ## emacs format
)
f.x ec.fx


_emacs.server() (
    : ' ${service} ## starts emacs systemd service ${service}'
    set -Eeuo pipefail; shopt -s nullglob
   local _service=${1:-emacs-modified-$(os-release.id).service}

   # Is the service enabled?
   if ! systemctl --user --quiet is-enabled ${_service}; then
       # Service isn't enabled. Let's do so. This might override the user's policy.
       # Symlink a service unit definition into systemd's "user" folder ~/.config/systemd/user/.
       # The .service file is distro specific (nixos, fedora, etc) b/c I don't know enough systemd to customize a single one.
       local _unit="$(home)/.config/systemd/user/${_service}.service"
       [[ -r "${_unit}" ]] || ln -sf "$(u.here)/.config/systemd/user/${_service}.service" "$(path.mp ${_unit})"

       # populate ~/.emacs.d/ with initial contents but don't override existing files.
       for _el in $(u.here)/.emacs.d/*.el; do
           &> /dev/null ln --symbolic ${_el} $(home)/.emacs.d/
       done

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
f.x _emacs.server


emacs.server.log() (
    set -Eeuo pipefail; shopt -s nullglob
    local _service=${1:-emacs-modified-$(os-release.id).service}
    journalctl --user --boot 0 --unit ${_service} # grep something
)
f.x emacs.server.log


emacs.server() ( _${FUNCNAME} emacs-modified-$(os-release.id); )
f.x emacs.server


emc() (
    : '${_name} [${config_pathname}] # start emacs "by name" e.g. "maxemacs"'
    set -Eeuo pipefail; shopt -s nullglob
    local _name=${1:?'expecting a name, e.g. maxemacs'} && shift
    local _init_directory="${1:-~/.config/${_name}}" && shift
    
    emacs --name=${_name} --debug-init --no-splash --init-directory="${_init_directory}" --eval='(switch-to-buffer "*Messages*")' "$@"
)
__complete.emc() {
    local _command=$1 _word=$2 _previous_word=$3
    local -i _position=${COMP_CWORD} _arg_length=${#COMP_WORDS[@]}
    declare -ig __previous_position
    COMPREPLY=()
    if (( _position == 1)); then
	# prompt
	if (( __previous_position != _position )) && [[ -z "${_word}" ]] ; then
	    COMPREPLY=( compgen -d ~/.config/* )
	else
	    COMPREPLY=( compgen -d "${_word}" )
	fi	
    elif (( _position == 2 )); then
	COMPREPLY=( compgen -d  )	    
	(( __previous_position != _position )) && >&2 echo -n "(f.exists takes a single argument) "
    else
	>&2 echo "not yet implemented"
    fi
    let __previous_position=_position
}
f.complete emc

maxemacs() (
    local -n _env=${FUNCNAME^^}_CONFIG
    local _config="${1:-${_env:-~/.config/${FUNCNAME}}}" && shift
    emc ${FUNCNAME} "${_config}" "$@"
)
f.x maxemacs

# install: git clone https://github.com/syl20bnr/spacemacs $HOME/.config/spacemacs
spacemacs() (
    local -n _env=${FUNCNAME^^}_CONFIG # export SPACEMACS_CONFIG=~/.config/spacemacs
    emc ${FUNCNAME} ${1:-${_env:-~/.config/${FUNCNAME}}} "$@"
)
f.x spacemacs    

# install: git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/doom; ~/.config/doom/bin/doom install
doom() (
    local -n _env=${FUNCNAME^^}_CONFIG # export DOOM_CONFIG=~/.config/spacemacs
    emc ${FUNCNAME} ${1:-${_env:-~/.config/${FUNCNAME}}} "$@"
)
f.x doom


emacs.env() (
    : '[${_pathname}] ## run emacsclient after starting emacs.service'
    set -Eeuo pipefail
    [[ -n "${DISPLAY}" ]] || return $(u.error "${FUNCNAME} needs windowing to run the emacs systemd service")
    export EDITOR="ec"
    export VISUAL="${EDITOR}"
    emacs.server || return $(u.error "cannot start emacs service in login shell $$")
    loginctl enable-linger ${USER}
)
f.x emacs.env

sourced || true

