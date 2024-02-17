running.bash && u.have $(basename ${BASH_SOURCE} .sh) || return 0
# dnf install -y emacs
# systemctl --user enable --now emacs-modified
# journalctl --user-unit emacs
# loginctl enable-linger ${USER}
ec() {
   # run the background service iff it isn't active
   # local _service=emacs-modified
   local _service=emacs
   systemctl --user --quiet is-active ${_service} || systemctl --user start ${_service} || { journalctl --user-unit ${_service}; return 0; }
   declare -i _frames=$(/usr/bin/emacsclient -e '(length (frame-list))')
   (( _frames > 1 )) && emacsclient "$@" || emacsclient -c "${@:-.}" &
}; declare -fx ec


emc() (
    : 'emc ${title} [${config_pathname}] # start emacs'
    local _name=${1:?'expecting a name, e.g. maxemacs'} && shift
    local _init_directory="${1:-~/.config/${_name}}" && shift
    
    emacs --name=${_name} --debug-init --no-splash --init-directory="${_init_directory}" --eval='(switch-to-buffer "*Messages*")' "$@"
); declare -fx emc

maxemacs() (
    local -n _env=${FUNCNAME^^}_CONFIG
    local _config="${1:-${_env:-~/.config/${FUNCNAME}}}" && shift
    emc ${FUNCNAME} "${_config}" "$@"
); declare -fx maxemacs

# install: git clone https://github.com/syl20bnr/spacemacs $HOME/.config/spacemacs
spacemacs() (
    local -n _env=${FUNCNAME^^}_CONFIG # export SPACEMACS_CONFIG=~/.config/spacemacs
    emc ${FUNCNAME} ${1:-${_env:-~/.config/${FUNCNAME}}} "$@"
); declare -fx spacemacs    

# install: git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/doom; ~/.config/doom/bin/doom install
doom() (
    local -n _env=${FUNCNAME^^}_CONFIG # export DOOM_CONFIG=~/.config/spacemacs
    emc ${FUNCNAME} ${1:-${_env:-~/.config/${FUNCNAME}}} "$@"
); declare -fx doom


export EDITOR='emacsclient -t'
export VISUAL='emacsclient -t'
alias vi='emacsclient -t'
alias vim='emacsclient -t'
