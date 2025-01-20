#!/usr/bin/env bash
set -Eeuo pipefail; shopt -s nullglob
[[ "$0" = */bashdb ]] && shift

# TODO mike@carif.io: do a udisk2 alternative

main() (
    : '${_label} [${_mountpoint} [${_target}]] ## create an /etc/fstab mount on ${_mountpoint} for all btrfs filesystems labeled ${_label}'
    local _label="${1:?"${FUNCNAME}@${LINENO} expecting a label"}" ## label to search for, e.g. 'store'
    local _root="/"
    local _mountpoint="${2:-${_root}${_label}}" ## the mountpoint created, default /${_label}
    local _target=${3:-/tmp/fstab+{_label}} ## the output. set this to something like /tmp/fstab+${_label} to inspect the result first
    local _working="/tmp/$(basename $0)/fstab+${_label}" ## the intermediate result which findmnt --verify will inspect first

    # Create the pathname to ${_working} if needed
    mkdir -p $(dirname ${_working}) &> /dev/null || true
    
    # Are there any btrfs filesystems actually labeled ${_label}?
    btrfs filesystem show ${_label} || u.warn "${FUNCNAME}@${BASH_LINENO}: no btrfs filesystem labeled '${_label}', continuing..."

    # create the mount options
    local -i _subvolid=$(btrfs subvolume get-default ${_root} | cut -d' ' -f2) ## usually 5
    local _options="defaults,nofail,degraded,discard=async,space_cache=v2,ssd,autodefrag,subvolid=${_subvolid:-5},subvol=${_root}"

    if findmnt --fstab --timeout 3000 --mountpoint "${_mountpoint}"; then
        _target=${_working}.generated
        >&2 echo "${FUNCNAME}@${BASH_LINENO}: /etc/fstab already has a mountpoint ${_mountpoint}."
        >&2 echo "${FUNCNAME}@${BASH_LINENO}: You must merge ${_target} and /etc/fstab manually"
    fi
    
    
    cat /etc/fstab - <<EOF > ${_working}

# $0 ${USER} $(date --iso)
# mount all partitions formatted btrfs and labeled ${_label} on ${_mountpoint} (with some fault tolerance)

# To approximate $0 manually as root:
# mkdir -pv ${_mountpoint}
# emacs /etc/fstab # add entry
# systemctl daemon-reload
# findmnt --verify # check syntax
# findmnt --fstab # what should happen next
# mount ${_mountpoint}
# findmnt ${_mountpoint}
# btrfs filesystems show ${_label} # find disks by label and enumerate them

# manually as root without modifying fstab:
# install -d -o ${USER} -g ${USER} ${_mountpoint}
# mount -o ${_options} LABEL=${_label} ${_mountpoint}


# noauto for rebooting and mounting manually: 'sudo mount ${_mountpoint}'. Note that udisk2 will also "recognize" store.
# LABEL=${_label}                                            ${_mountpoint}          btrfs   ${_options},noauto 0 1
# automount ${_mountpoint} on boot
LABEL=${_label}                                            ${_mountpoint}          btrfs   ${_options} 0 1

EOF

    (set -x; LIBMOUNT_FSTAB="${_working}" sudo findmnt --verbose --verify) || return $(u.error "${FUNCNAME}@${BASH_LINENO}: ${_working} did not verify")
    sudo cp --update --verbose --backup=numbered "${_working}" "${_target}" || true
    [[ -d "${_mountpoint}" ]] && >&2 "mountpoint '${_mountpoint}' exists, continuing..." || \
            sudo install --directory --owner=${USER} --group=${USER} "${_mountpoint}"
    cp /etc/fstab /tmp/fstab
    sudo meld ${_target} /etc/fstab
    if diff --ignore-tab-expansion --ignore-trailing-space --ignore-space-change --ignore-blank-lines /{tmp,etc}/fstab &> /dev/null; then
        >&2 echo "/tmp/fstab is still different from /etc/fstab"
    else
        sudo systemctl daemon-reload
        sudo umount --verbose ${_mountpoint} && sudo mount --verbose ${_mountpoint}
        findmnt "${_mountpoint}" || return $(u.error "${FUNCNAME}@${LINENO}: '${_mountpoint}' not mounted? Check /etc/fstab.")
    fi
)


# for testing:
main store "/store"

