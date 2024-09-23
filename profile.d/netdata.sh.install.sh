#!/usr/bin/env bash
set -Eeuo pipefail; shopt -s nullglob
[[ "$0" = */bashdb ]] && shift
source $(dirname "$0")/_defaults.install.sh # override these as needed

# wget -O /tmp/netdata-kickstart.sh https://get.netdata.cloud/kickstart.sh && sh /tmp/netdata-kickstart.sh --stable-channel --claim-token ehDzlLFcfV_5srVBBUZz3zgUBZiiB_0cnoPwYtLFvi3FCwOIuQoXUI_RW-OzvSTZgg7UK-NUyDA7gZaQR-5zIbGE1_oZ8di3hoDcj2897N4ZOlJ-cjb8d-miKyGE1nEgotOtY18 --claim-rooms 91ad1c97-7e6d-4f72-aaed-b475df2a3b44 --claim-url https://app.netdata.cloud
_install $(path.basename.part $(basename ${BASH_SOURCE}) 1) $(path.basename ${BASH_SOURCE}) https://get.netdata.cloud/kickstart.sh --stable-channel --claim-token ehDzlLFcfV_5srVBBUZz3zgUBZiiB_0cnoPwYtLFvi3FCwOIuQoXUI_RW-OzvSTZgg7UK-NUyDA7gZaQR-5zIbGE1_oZ8di3hoDcj2897N4ZOlJ-cjb8d-miKyGE1nEgotOtY18 --claim-rooms 91ad1c97-7e6d-4f72-aaed-b475df2a3b44 --claim-url https://app.netdata.cloud

