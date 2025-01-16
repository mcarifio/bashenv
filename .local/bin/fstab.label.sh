#!/usr/bin/env bash
set -Eeuo pipefail; shopt -s nullglob
[[ "$0" = */bashdb ]] && shift

main() (
    local _label="${1:?"${FUNCNAME} expecting a label"}"
    local _target=${2:-/tmp/fstab+${_label}}

    btrfs filesystem show ${_label} || u.warn "${FUNCNAME} no btrfs filesystem labeled '${_label}'"

    cat /etc/fstab - <<EOF > ${_target}

# ${USER} $(date --iso) mount all disks with btrfs file label '${_label}' on /${_label} with some fault tolerance
# as root:
# systemctl daemon-reload
# mkdir /${_label}
# mount /${_label}
# mount -l --type=btrfs | grep ${_label} # check options
# btrfs filesystems show ${_label} # find disks by label and enumerate them

# noauto for rebooting and mounting manually: 'sudo mount /${_label}'. Note that udisk2 will also "recognize" store.
# LABEL=${_label}                                            /${_label}          btrfs   defaults,nofail,degraded,noauto,discard,autodefrag 0 1
# automount on boot
LABEL=${_label}                                            /${_label}          btrfs   defaults,nofail,degraded,discard,autodefrag 0 1

EOF

    >&2 echo "created '${_target}' ## for your inspection"
    >&2 echo "sudo cp -v --backup=numbered ${_target} /etc/fstab && sudo mkdir /${_label} && sudo systemctl daemon-reload && mount -l --type=btrfs"
    echo ${_target}
)

main "$@"





