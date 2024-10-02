${1:-false} || u.haveP $(path.basename.part ${BASH_SOURCE} 0) || return 0

# https://www.admin-magazine.com/HPC/Articles/pdsh-Parallel-Shell
# dnf install pdsh pdsh-rcmd-ssh pdsh-mod-dshgroup pdsh-mod-genders pdsh-mod-netgroup
pdsh.doc.urls() ( echo ; ) # urls here
f.x pdsh.doc.urls

pdsh.doc() (
    set -Eeuo pipefail; shopt -s nullglob
    for _u in $(${FUNCNAME}.urls); do xdg-open ${_u}; done
)
f.x pdsh.doc

pdsh.env() {
    export PDSH_RCMD_TYPE=ssh
}
f.x pdsh.env

pdsh.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    local -r _completions=/usr/share/bash-completion/completions
    source.if ${_completions}/${_cmd}.${_shell} ${_completions}/${_cmd}
}
f.x pdsh.session

pdsh.installer() (
    set -Eeuo pipefail # DO NOT shopt -s nullglob
    binstall.installer ${FUNCNAME%.*}
)
f.x pdsh.installer

sourced || true

