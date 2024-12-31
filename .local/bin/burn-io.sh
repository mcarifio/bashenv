#!/usr/bin/env -S sudo bash
# as root, burn an iso to a usb disk by device name /dev/sd?.
# NO ERROR CHECKING SO GET THE DEVICE NAME RIGHT.

set -Eeuo pipefail

main() (
    local _iso="${1:?"${BASH_SOURCE}:${FUNCNAME} expecting an iso"}"
    local _device="${2:?"${BASH_SOURCE}:${FUNCNAME} expecting an unmounted device e.g. /dev/sdh"}"

    # in case ${_device} is mounted
    umount ${_device} && >&2 echo "unmounted ${_device}"
    dd if="${_iso}" of=${_dev} bs=4M status=progress oflag=sync

    # eject the device
    sync
    eject ${_device} && >&2 echo "ejected ${_device}"
)

main "$@"
