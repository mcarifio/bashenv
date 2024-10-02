${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

ysh.doc.urls() ( echo "https://www.oilshell.org/" "https://www.oilshell.org/release/latest/doc/ysh-tour.html"; ) # urls here
f.x ysh.doc.urls

ysh.doc() (
    set -Eeuo pipefail; shopt -s nullglob
    for _u in $(${FUNCNAME}.urls); do xdg-open ${_u}; done
)
f.x ysh.doc

ysh() (
    : '$@ # run ysh with args, @see https://www.oilshell.org/ especially https://www.oilshell.org/release/latest/doc/ysh-tour.html'
    PS1='\$p ' command ysh "$@"
)
f.x ysh

ysh.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x ysh.env

ysh.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    local -r _completions=/usr/share/bash-completion/completions
    source.if ${_completions}/${_cmd}.${_shell} ${_completions}/${_cmd}
}
f.x ysh.session

ysh.installer() (
    set -Eeuo pipefail
    binstall.installer oils
)
f.x ysh.installer

sourced || true
