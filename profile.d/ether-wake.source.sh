${1:-false} || u.haveP $(path.basename.part ${BASH_SOURCE} 0) || return 0

ether-wake.hosts() ( awk '{ split($0, a, "#"); split(a[1],b, " "); if (b[2] != "") print b[2]}' /etc/ethers; )
f.x ether-wake.hosts

ether-wake() ( sudo $(type -P ${FUNCNAME}) -i enp3s0 -b "$@"; )
__complete.ether-wake() {
    local _command=$1 _word=$2 _previous_word=$3
    local -i _position=${COMP_CWORD} _arg_length=${#COMP_WORDS[@]}
    [[ -r /etc/ethers ]] && COMPREPLY=( $(compgen -W "$(ether-wake.hosts)" -- "${_word}") ) || COMPREPLY=()
}
f.complete ether-wake


ether-wake.doc.urls() ( echo ; ) # urls here
f.x ether-wake.doc.urls

ether-wake.doc() (
    set -Eeuo pipefail; shopt -s nullglob
    for _u in $(${FUNCNAME}.urls); do xdg-open ${_u}; done
)
f.x ether-wake.doc

ether-wake.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x ether-wake.env

ether-wake.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    local -r _completions=/usr/share/bash-completion/completions
    source.if ${_completions}/${_cmd}.${_shell} ${_completions}/${_cmd}
}
f.x ether-wake.session

ether-wake.installer() (
    set -Eeuo pipefail # DO NOT shopt -s nullglob
    realpath -Lm $(binstall.installer ${FUNCNAME%.*})
)
f.x ether-wake.installer

ether-wake.config.dir() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="${HOME}/.config/${_guard}"
    [[ -d "${_dir}" ]] || return $(u.error "${FUNCNAME} '${_dir}' not found")
    echo ${_dir}
)
f.x ether-wake.config.dir

ether-wake.config() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="$(${FUNCNAME}.dir)"
    local _config="${_dir}/${_guard}"
    [[ -r "${_config}" ]] || return $(u.error "${FUNCNAME} '${_config}' not found")
    echo "${_config}"
)
f.x ether-wake.config


sourced || true
