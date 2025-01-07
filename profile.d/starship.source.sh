${1:-false} || u.haveP $(path.basename.part ${BASH_SOURCE} 0) || return 0

starship() ( command ${FUNCNAME} "$@"; )
f.x starship

starship.doc.urls() ( echo https://starship.rs/{guide,config}; ) # urls here
f.x starship.doc.urls

starship.doc() (
    set -Eeuo pipefail; shopt -s nullglob
    for _u in $(${FUNCNAME}.urls); do xdg-open ${_u}; done
)
f.x starship.doc

starship.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x starship.env

starship.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    source <(starship init ${_shell})
}
f.x starship.session

starship.installer() (
    set -Eeuo pipefail # DO NOT shopt -s nullglob
    realpath -Lm $(binstall.installer ${FUNCNAME%.*})
)
f.x starship.installer

starship.config.dir() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="${HOME}/.config/${_guard}"
    [[ -d "${_dir}" ]] || return $(u.error "${FUNCNAME} '${_dir}' not found")
    echo ${_dir}
)
f.x starship.config.dir

starship.config() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="$(${FUNCNAME}.dir)"
    local _config="${_dir}/${_guard}"
    [[ -r "${_config}" ]] || return $(u.error "${FUNCNAME} '${_config}' not found")
    echo "${_config}"
)
f.x starship.config


sourced || true
