${1:-false} || u.haveP $(path.basename.part ${BASH_SOURCE} 0) || return 0
# gsettings comes via rpm glib2, apt tbs

gsettings() ( command ${FUNCNAME} "$@"; )
f.x gsettings

gnome.current.theme() ( gsettings get org.gnome.desktop.interface gtk-theme; ); f.x gnome.current.theme
gnome.current.gtk() ( echo "{FUNCNAME} tbs"; ); f.x gnome.current.gtk

gsettings.doc.urls() ( echo ; ) # urls here
f.x gsettings.doc.urls

gsettings.doc() (
    set -Eeuo pipefail; shopt -s nullglob
    for _u in $(${FUNCNAME}.urls); do xdg-open ${_u}; done
)
f.x gsettings.doc

gsettings.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x gsettings.env

gsettings.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    local -r _completions=/usr/share/bash-completion/completions
    source.if ${_completions}/${_cmd}.${_shell} ${_completions}/${_cmd}
}
f.x gsettings.session

gsettings.installer() (
    set -Eeuo pipefail # DO NOT shopt -s nullglob
    realpath -Lm $(binstall.installer ${FUNCNAME%.*})
)
f.x gsettings.installer

gsettings.config.dir() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="${HOME}/.config/${_guard}"
    [[ -d "${_dir}" ]] || return $(u.error "${FUNCNAME} '${_dir}' not found")
    echo ${_dir}
)
f.x gsettings.config.dir

gsettings.config() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="$(${FUNCNAME}.dir)"
    local _config="${_dir}/${_guard}"
    [[ -r "${_config}" ]] || return $(u.error "${FUNCNAME} '${_config}' not found")
    echo "${_config}"
)
f.x gsettings.config


sourced || true
