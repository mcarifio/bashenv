#!/usr/bin/env bash
set -Eeuo pipefail

_post.install() (
    # after installation configuration
    >&2 echo "${FUNCNAME} $@ # ${FUNCNAME} tbs"
)


# see install.lib.sh for install variants
_install() (
    local _kind=${1:-distro}; shift || true
    local _name=${1:?'expecting a name'}; shift || true
    install.${_kind} ${_name} "$@"
    # _post.install "$@"
    install.check ${_name}
)

# wget -O /tmp/netdata-kickstart.sh https://get.netdata.cloud/kickstart.sh && sh /tmp/netdata-kickstart.sh --stable-channel --claim-token ehDzlLFcfV_5srVBBUZz3zgUBZiiB_0cnoPwYtLFvi3FCwOIuQoXUI_RW-OzvSTZgg7UK-NUyDA7gZaQR-5zIbGE1_oZ8di3hoDcj2897N4ZOlJ-cjb8d-miKyGE1nEgotOtY18 --claim-rooms 91ad1c97-7e6d-4f72-aaed-b475df2a3b44 --claim-url https://app.netdata.cloud
_install $(path.basename.part $(basename ${BASH_SOURCE}) 2) $(path.basename ${BASH_SOURCE}) https://get.netdata.cloud/kickstart.sh --stable-channel --claim-token ehDzlLFcfV_5srVBBUZz3zgUBZiiB_0cnoPwYtLFvi3FCwOIuQoXUI_RW-OzvSTZgg7UK-NUyDA7gZaQR-5zIbGE1_oZ8di3hoDcj2897N4ZOlJ-cjb8d-miKyGE1nEgotOtY18 --claim-rooms 91ad1c97-7e6d-4f72-aaed-b475df2a3b44 --claim-url https://app.netdata.cloud

