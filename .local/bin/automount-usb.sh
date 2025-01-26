#!/usr/bin/env bash

set -Eeuo pipefail; shopt -s nullglob

generate() (
    local -a _args=( "$@" )
    (( ${#_args[@]} )) || return $(u.error "need at least one PARTUUID")
    for _partuuid in "${_args[@]}"; do
        >&2 printf '%s...' ${_partuuid}
        cat <<EOF

#*# ID_PART_TABLE_UUID=="${_partuuid}"
SUBSYSTEM=="block", ENV{ID_PART_TABLE_UUID}=="${_partuuid}" ACTION=="add", RUN+="/usr/bin/mount -o defaults,X-mount.mkdir /dev/%k /run/mnt/\$env{ID_FS_LABEL}"
# no fs label
ENV{ID_FS_LABEL}=="", SUBSYSTEM=="block", ENV{ID_PART_TABLE_UUID}=="${_partuuid}" ACTION=="add", RUN+="/usr/bin/mount -o defaults,X-mount.mkdir /dev/%k /run/mnt/\$env{ID_PART_TABLE_UUID}"
EOF
        >&2 printf 'done  '
    done
    >&2 echo
)


automount-usb() (
    set -Eeuo pipefail; shopt -s nullglob
    # u.trace gsettings for gvfs

    # TODO mike@carif.io: gnome intercepts mounting, disable it
    # gsettings set org.gnome.desktop.media-handling automount-open false
    # gsettings set org.gnome.desktop.media-handling automount false

    # sudo udevadm control --reload-rules
    # sudo udevadm trigger --action=add /dev/sdf1
    # sudo journal -u systemd-udevd

    local _rules=/etc/udev/rules.d/99-$(basename $0 .sh).rules
    local _target=/tmp/$(basename ${_rules})
    ( echo "#*# '$(realpath $0)' added rules by '${USER}' on '$(date --iso=minutes)'"
      generate "$@") > ${_target}
    [[ -r "${_target}" ]] && >&2 echo "${_target} created"
    sudo cp --verbose --backup=numbered ${_target} ${_rules}
    sudo udevadm control --reload-rules
    >&2 echo "journalctl -f -u systemd-udevd && sudo udevadm trigger"
)

# to get PARTUUIDS
# lsblk --noheading --list -o NAME,FSTYPE,LABEL,PARTUUID,MOUNTPOINT|grep btrfs

return $(u.error "$0 doesn't work yet")

# btrfs.partitions to get this table
declare -A _label2partuuid=(
    [mobilework]=2049eea7-d3d8-4701-bf78-b08fd4fcde34
    [mobilehome]=7a17a28f-1aa5-410a-8806-e67e8660c2c2)
$(basename $0 .sh) "${_label2partuuid[@]}"

