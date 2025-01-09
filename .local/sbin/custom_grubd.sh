#!/usr/bin/env -P sudo bash
set -Eeuo pipefail; shopt -s nullglob

u.here () ( printf $(realpath -Ls $(dirname ${BASH_SOURCE[${1:-1}]})); )

grub.mkcustom() (
    for _c in "$@"; do
        local _there=${_c##*/}; _there="/etc/grub.d/${_there%%.*}"
        install -v _c ${_there}
    done
)

main() (
    grub.mkcustom $(u.here)/*.grub.cfg
    grub2-mkconfig -o /boot/grub2/grub.cfg
)

main "$@"
