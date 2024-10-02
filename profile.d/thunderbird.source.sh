${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

thunderbird() (
    set -Eeuo pipefail; shopt -s nullglob
    local -i _log=0 _default_log_pathname=/tmp/${FUNCNAME}-$$.log _log_pathname=''
    for _a in "${@}"; do
        case "${_a}" in
            --log) _log=1; _log_pathname=${_default_log_pathname};;
            --log=*) _log=1; _log_pathname="${_a##*=}";;
            --) shift; break;;
            # --*) break;; ## break on unknown switch, pass it along
            # --*) >&2 echo "${FUNCNAME}: unknown switch ${_a}, stop processing switches"; break;;
            --*) return $(u.error "${FUNCNAME} unknown switch '${_a}', stopping");; ## error on unknown switch
            *) break;;
        esac
        shift
    done

    if (( _log )); then
        NSPR_LOG_MODULES=SMTP:4,IMAP:4 NSPR_LOG_FILE="${_log_pathname}" command ${FUNCNAME} "$@" && echo "${FUNCNAME} logging to '${_log_pathname}'" >&2
    else
        command ${FUNCNAME} "$@"
    fi    
)
f.x thunderbird

thunderbird.docs() (
    set -Eeuo pipefail; shopt -s nullglob
    local -nu _docs=${FUNCNAME%.*}_urls # e.g. UV_DOCS
    set -x; xdg-open ${_docs:-} "$@" # hard-code urls here if desired
)
f.x thunderbird.docs

thunderbird.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x thunderbird.env

thunderbird.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    local -r _completions=/usr/share/bash-completion/completions
    source.if ${_completions}/${_cmd}.${_shell} ${_completions}/${_cmd}
}
f.x thunderbird.session

thunderbird.installer() ( ls -1 $(bashenv.profiled)/binstall.d/*${FUNCNAME%.*}*.*.binstall.sh; )
f.x thunderbird.installer

sourced || true
