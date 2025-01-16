#!/usr/bin/env bash
set -Eeuo pipefail; shopt -s nullglob
[[ "$0" = */bashdb ]] && shift

main() (
    local _target=${2:-/etc/default/grub.d/$(basename $0 .sh)}
    cat <<EOF | sudo tee -a ${_target}
# sudo update-grub; sudo reboot; cat /proc/cmdline
# remove quiet and splash from GRUB_CMDLINE_LINUX_DEFAULT preserving the rest
GRUB_CMDLINE_LINUX_DEFAULT=`echo ${GRUB_CMDLINE_LINUX_DEFAULT} | sed 's/quiet//g;s/splash//g'`
EOF
    sudo update-grub
)

main "$@"





