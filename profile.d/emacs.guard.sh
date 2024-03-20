# dnf install -y emacs
# systemctl --user enable --now emacs-modified
# journalctl --user-unit emacs
# loginctl enable-linger ${USER}
ec() {
   : 'run emacsclient after starting emacs.service'
   # run the background service iff it isn't active
   # https://askubuntu.com/questions/1499139/how-to-run-emacs-daemon-as-a-systemd-service-with-wayland-on-ubuntu-22-04
   # local _service=emacs
   emacs.server || return $(u.error "cannot start emacs server")
   emacsclient --reuse-frame --no-wait "$@"
}
f.complete ec

emacs.server() (
   set -Eeuo pipefail
   local _service=${1:-emacs-modified}
   if ! systemctl --user --quiet is-enabled ${_service}; then
       local _unit="$(home)/.config/systemd/user/${_service}.service"
       [[ -r "${_unit}" ]] || ln -s "$(path.md $(u.here)/${_service}.service" "$(path.md $(dirname ${_unit})))/$(basename ${_unit})"
       systemctl --user enable --now ${_service} || return $(u.error "${FUNCNAME} cannot enable ${_service}")
   fi
   systemctl --user --quiet is-active ${_service} || systemctl --user start ${_service} ||
       return $(u.error "${FUNCNAME} cannot start ${_service}")   
)




emc() (
    : '${_name} [${config_pathname}] # start emacs'
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
	>&2 
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


export EDITOR='emacsclient -t'
export VISUAL='emacsclient -t'

emacs.env() {
    # set -Eeuo pipefail
    emacs.server || return $(u.error "${FUNCNAME} cannot start emacs server")
    loginctl enable-linger ${USER}
}
declare -fx emacs.env
