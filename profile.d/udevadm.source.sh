${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

config.memory() (
    udevadm info -e | grep -e MEMORY_DEVICE
)
f.x config.memory

udevadm.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    local -r _completions=/usr/share/bash-completion/completions
    source.if ${_completions}/${_cmd}.${_shell} ${_completions}/${_cmd}
}
f.x udevadm.session

udevadm.installer() ( ls -1 $(bashenv.profiled)/binstall.d/*systemd-udev*.*.binstall.sh; )
f.x udevadm.installer

sourced || true
