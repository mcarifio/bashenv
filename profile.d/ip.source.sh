${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

ip4.addr.show() (
    set -Eeuo pipefail
    ip -4 addr show ${1:?'expecting a device name like eth0'} | grep -oP '(?<=inet\s)\d+(\.\d+){3}'
)
f.x ip4.addr.show

sourced

