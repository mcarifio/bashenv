#!/usr/bin/env -S sudo bash
# as root, burn an iso to a usb disk by device name /dev/sd?.
# NO ERROR CHECKING SO GET THE DEVICE NAME RIGHT.

set -Eeuo pipefail

main() (
    local _iso="${1:?"${BASH_SOURCE}:${FUNCNAME} expecting an iso"}"
    local _device="${2:?"${BASH_SOURCE}:${FUNCNAME} expecting an unmounted device e.g. /dev/sdh"}"

    if pn.is.url "${_iso}" ; then
        local _target="~/Downloads/${_iso##*/}"
        [[ ! -r "${_target}" ]] && curl -fsSL -o "${_target}" ${_iso} || return $(u.error "Cannot fetch ${_iso} to ~/Downloads")
        _iso="${_target}"
    fi
    
    # in case ${_device} is mounted
    umount ${_device} && >&2 echo "unmounted ${_device}"
    (set -x; dd if="${_iso}" of=${_device} bs=4M status=progress oflag=sync)

    # eject the device
    sync
    eject ${_device} && >&2 echo "ejected ${_device} successfully" || >&2 echo "ejected ${_device} unsuccessfully?"
)

main "$@"
