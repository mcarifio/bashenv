# creation: guard.mkguard ${_name}
_guard=$(path.basename ${BASH_SOURCE})


slack() (
    : '# logs to ~/.config/Slack/logs/default/*'
    set -Eeuo pipefail    
    &> /dev/null command ${FUNCNAME} --silent "$@"
)
f.x slack

slack.docs() (
    set -Eeuo pipefail
    local -nu _docs=${FUNCNAME%.*}_urls # e.g. UV_DOCS
    set -x; xdg-open ${_docs:-} "$@" # hard-code urls here if desired
)
f.x slack.docs

slack.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x slack.env

slack.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    # source.if /usr/share/bash-completion/completions/${_cmd}.${_shell}
}
f.x slack.session

unset _guard
loaded "${BASH_SOURCE}"
