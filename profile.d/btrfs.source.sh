${1:-false} || u.have $(path.basename.part ${BASH_SOURCE} 0) || return 0

btrfs() (
    sudo $(type -P ${FUNCNAME}) "$@"
)
f.x btrfs

btrfs.findmnt() (
    : '${_potentials}* ## find all mounted btrfs file system mountpoints'
    set -Eeuo pipefail; shopt -s nullglob
    local _cmd=${FUNCNAME%%.*}
    sudo $(type -P findmnt) --type=${_cmd} --noheading --list -o TARGET "$@"
)
f.x btrfs.findmnt

btrfs.snapshot() (
    local _cmd=${FUNCNAME%%.*}
    local _cmd=:; set -x
    local _method=${FUNCNAME##*.}
    for _a in "$@"; do
        local _m=$(btrfs.findmnt $(realpath ${_a})) || continue
        ${_cmd} subvolume ${_method} -r ${_m} ${_m}/${_method} && \
            ${_cmd} subvolume list ${_m}
    done        
)
f.x btrfs.snapshot



btrfs.find.partitions-by-label() (
    set -Eeuo pipefail
    local _label="${1:?"${FUNCNAME} expecting a label"}"
    echo "select m.path as path, b.name as device from block_devices b left join mounts m on b.name = m.device where b.type = 'btrfs' AND b.label = '${_label}';" \
         | sudo osqueryi --json
)
f.x btrfs.find.partitions-by-label


btrfs.mount.by-label() (
    set -Eeuo pipefail
    local _label=${1:?"${FUNCNAME} expecting a label, e.g. 'data'"}
    local _mountpoint=${2:-/mnt/${_label}}
    [[ -d "{_mountpoint}" ]] || sudo mkdir -p ${_mountpoint}
    for _p in $(btrfs.find.partitions-by-label ${_label}); do echo sudo mount -o subvol=$(dirname ${_mountpoint}) ${_p} ${_mountpoint}; done
    echo ${_mountpoint}
)


btrfs.doc.urls() ( echo ; ) # urls here
f.x btrfs.doc.urls

btrfs.doc() (
    set -Eeuo pipefail; shopt -s nullglob
    for _u in $(${FUNCNAME}.urls); do xdg-open ${_u}; done
)
f.x btrfs.doc

btrfs.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x btrfs.env

btrfs.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    local -r _completions=/usr/share/bash-completion/completions
    source.if ${_completions}/${_cmd}.${_shell} ${_completions}/${_cmd}
}
f.x btrfs.session

btrfs.installer() (
    set -Eeuo pipefail # DO NOT shopt -s nullglob
    realpath -Lm $(binstall.installer ${FUNCNAME%.*})
)
f.x btrfs.installer

btrfs.config.dir() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="${HOME}/.config/${_guard}"
    [[ -d "${_dir}" ]] || return $(u.error "${FUNCNAME} '${_dir}' not found")
    echo ${_dir}
)
f.x btrfs.config.dir

btrfs.config() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="$(${FUNCNAME}.dir)"
    local _config="${_dir}/${_guard}"
    [[ -r "${_config}" ]] || return $(u.error "${FUNCNAME} '${_config}' not found")
    echo "${_config}"
)
f.x btrfs.config


sourced || true
