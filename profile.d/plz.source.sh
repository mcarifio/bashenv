${1:-false} || u.haveP $(path.basename.part ${BASH_SOURCE} 0) || return 0

plz() ( command ${FUNCNAME} "$@"; )
f.x plz

plz.doc.urls() ( echo https://please.build/config.html; ) # urls here
f.x plz.doc.urls

plz.doc() (
    set -Eeuo pipefail; shopt -s nullglob
    for _u in $(${FUNCNAME}.urls); do xdg-open ${_u}; done
)
f.x plz.doc

plz.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x plz.env

plz.session() {
    : '# called by .bashrc'
    source <(plz --completion_script)
}
f.x plz.session

plz.installer() (
    set -Eeuo pipefail # DO NOT shopt -s nullglob
    realpath -Lm $(binstall.installer ${FUNCNAME%.*})
)
f.x plz.installer

plz.config.dir() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="${HOME}/.config/${_guard}"
    [[ -d "${_dir}" ]] || return $(u.error "${FUNCNAME} '${_dir}' not found")
    echo ${_dir}
)
f.x plz.config.dir

plz.config() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="$(${FUNCNAME}.dir)"
    local _config="${_dir}/${_guard}"
    [[ -r "${_config}" ]] || return $(u.error "${FUNCNAME} '${_config}' not found")
    echo "${_config}"
)
f.x plz.config


sourced || true
