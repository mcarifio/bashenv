# dnf install -y emacs
# systemctl --user enable --now emacs-modified-$(os-release.id)
# journalctl --user --unit emacs-modified--$(os-release.id)
# loginctl enable-linger ${USER}

_guard=$(path.basename ${BASH_SOURCE})
declare -A _option=([install]=0 [verbose]=0 [summarize]=0 [trace]=0)
_undo=''; trap -- 'eval ${_undo}; unset _option _undo; trap -- - RETURN' RETURN
local -a _rest=( $(u.parse _option "$@") )
if (( ${_option[trace]} )) && ! bashenv.is.tracing; then
    _undo+='set +x;'
    set -x
fi

# install by distro id
emacs.install() ( emacs.install.$(os-release.id); )
f.x emacs.install
emacs.install.fedora() ( dnf install emacs; )
f.x emacs.install.fedora
emacs.install.ubuntu() ( sudo apt upgrade -y; sudo apt install -y emacs; )
f.x emacs.install.ubuntu

# source ${_guard}.guard.sh --install
if (( ${_option[install]} )) && ! u.have ${_guard}; then
    emacs.install ${_rest} || return $(u.error "emacs.install failed")
}




ec() (
    : '[${_pathname}] ## run emacsclient after starting emacs.service'
    set -Eeuo pipefail
    emacs.server || return $(u.error "emacs daemon not started")
    [[ -n "${DISPLAY}" ]] && emacsclient --reuse-frame --no-wait --timeout=20 --quiet "$@" || emacsclient --tty --timeout=20 --quiet "$@"
)
f.complete ec

_emacs.server() (
    : ' ${service} ## starts emacs systemd service ${service}'
   set -Eeuo pipefail
   local _service=${1:?'expecting a service name'}

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
   systemctl --user --quiet is-active ${_service} || systemctl --user start ${_service} ||
       return $(u.error "${FUNCNAME} cannot start ${_service}")   
)
f.x _emacs.server
emacs.server() ( _${FUNCNAME} emacs-modified-$(os-release.id); )
f.x emacs.server


emc() (
    : '${_name} [${config_pathname}] # start emacs "by name" e.g. "maxemacs"'
    set -Eeuo pipefail
    local _name=${1:?'expecting a name, e.g. maxemacs'} && shift
    local _init_directory="${1:-~/.config/${_name}}" && shift
    
    emacs --name=${_name} --debug-init --no-splash --init-directory="${_init_directory}" --eval='(switch-to-buffer "*Messages*")' "$@"
)
__emc.complete() {
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
f.complete maxemacs

# install: git clone https://github.com/syl20bnr/spacemacs $HOME/.config/spacemacs
spacemacs() (
    local -n _env=${FUNCNAME^^}_CONFIG # export SPACEMACS_CONFIG=~/.config/spacemacs
    emc ${FUNCNAME} ${1:-${_env:-~/.config/${FUNCNAME}}} "$@"
)
f.complete spacemacs    

# install: git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/doom; ~/.config/doom/bin/doom install
doom() (
    local -n _env=${FUNCNAME^^}_CONFIG # export DOOM_CONFIG=~/.config/spacemacs
    emc ${FUNCNAME} ${1:-${_env:-~/.config/${FUNCNAME}}} "$@"
)
f.complete doom


export EDITOR="ec"
export VISUAL="${EDITOR}"

emacs.env() (
    : '[${_pathname}] ## run emacsclient after starting emacs.service'
    set -Eeuo pipefail
    emacs.server || return $(u.error "cannot start emacs service in login shell $$")
    loginctl enable-linger ${USER}
)
f.x emacs.env

loaded "${BASH_SOURCE}"
