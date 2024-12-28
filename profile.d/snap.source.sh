${1:-false} || type -P $(path.basename.part ${BASH_SOURCE} 0) &> /dev/null || return 0

snap() (
    sudo $(type -P ${FUNCNAME}) "$@"

    local _verb=''
    for _a in "${@}"; do
        case "${_a}" in
            --) shift; break;;
            -*) ;;
            *) _verb="${_a}"; shift; break;;
        esac
        shift
    done

    [[ install = "${_verb}" ]] || return 0
    local _p=${1:-$(return 0)}
    local _binstalld="$(bashenv.profiled)/binstall.d"
    local _installer="${_binstalld}/${_p}.${FUNCNAME}.binstall.sh"
    [[ -r "${_installer}" ]] || cp -v ${_binstalld}/{_template.tbs,${_p}.${FUNCNAME}}.binstall.sh

)
f.x snap

snap.doc.urls() ( echo ; ) # urls here
f.x snap.doc.urls

snap.doc() (
    set -Eeuo pipefail; shopt -s nullglob
    for _u in $(${FUNCNAME}.urls); do xdg-open ${_u}; done
)
f.x snap.doc

snap.env() {
    : '# called (once) by .bash_profile'
    systemctl is-active snapd &> /dev/null || echo "${FUNCNAME} snapd not active" >&2
}
f.x snap.env

snap.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    local -r _completions=/usr/share/bash-completion/completions
    source.if ${_completions}/${_cmd}{,.${_shell}}
}
f.x snap.session

snap.installer() (
    set -Eeuo pipefail # DO NOT shopt -s nullglob
    binstall.installer ${FUNCNAME%.*}
)
f.x snap.installer

sourced || true

