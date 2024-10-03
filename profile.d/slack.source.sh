${1:-false} || u.haveP $(path.basename.part ${BASH_SOURCE} 0) || return 0

slack() (
    : '# logs to ~/.config/Slack/logs/default/*'
    set -Eeuo pipefail; shopt -s nullglob
    command ${FUNCNAME} --silent "$@" &> /dev/null && echo "${FUNCNAME} logging to ${HOME}/.config/Slack/logs/default/*" >&2
)
f.x slack

slack.doc.urls() ( echo ; ) # urls here
f.x slack.doc.urls

slack.doc() (
    set -Eeuo pipefail; shopt -s nullglob
    for _u in $(${FUNCNAME}.urls); do xdg-open ${_u}; done
)
f.x slack.doc

slack.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x slack.env

slack.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    source.if /usr/share/bash-completion/completions/${_cmd}{,.${_shell}}
}
f.x slack.session

slack.installer() ( ls -1 $(bashenv.profiled)/binstall.d/*${FUNCNAME%.*}*.*.binstall.sh; )
f.x slack.installer

sourced || true

