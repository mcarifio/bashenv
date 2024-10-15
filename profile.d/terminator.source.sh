${1:-false} || u.haveP $(path.basename.part ${BASH_SOURCE} 0) || return 0

terminator() (
    : '--host=[${user}@]${host||ip} ...rest ## run terminator perhaps on another host'
    set -Eeuo pipefail; shopt -s nullglob
    local _host=''
    for _a in "${@}"; do
        case "${_a}" in
            --host=*) _host="${_a##*=}";;
            --) shift; break;;
            --*) break;; ## break on unknown switch, pass it along
            *) break;;
        esac
        shift
    done

    if [[ -n "${_host}" ]]; then
        local _title="${USER}@${HOSTNAME}"
        ssh -Y ${_host} ${FUNCNAME} --title="${_title}" --name="${_title}" "$@"
    else
        command ${FUNCNAME} "$@"
    fi
)
f.x terminator

terminator.doc.urls() ( echo ; ) # urls here
f.x terminator.doc.urls

terminator.doc() (
    set -Eeuo pipefail; shopt -s nullglob
    for _u in $(${FUNCNAME}.urls); do xdg-open ${_u}; done
)
f.x terminator.doc

terminator.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x terminator.env

terminator.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    local -r _completions=/usr/share/bash-completion/completions
    source.if ${_completions}/${_cmd}.${_shell} ${_completions}/${_cmd}
}
f.x terminator.session

terminator.installer() (
    set -Eeuo pipefail # DO NOT shopt -s nullglob
    binstall.installer ${FUNCNAME%.*}
)
f.x terminator.installer

terminator.config.dir() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="${HOME}/.config/${_guard}"
    [[ -d "${_dir}" ]] || return $(u.error "${FUNCNAME} '${_dir}' not found")
    echo ${_dir}
)
f.x terminator.config.dir

terminator.config() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="$(${FUNCNAME}.dir)"
    local _config="${_dir}/${_guard}"
    [[ -r "${_config}" ]] || return $(u.error "${FUNCNAME} '${_config}' not found")
    echo "${_config}"
)
f.x terminator.config


sourced || true
