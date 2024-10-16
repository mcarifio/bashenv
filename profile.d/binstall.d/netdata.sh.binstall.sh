#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh
binstalld.dispatch --kind=$(path.basename.part "$0" 1) --pkg=$(path.basename "$(realpath -Lm "$0")") --url=https://get.netdata.cloud/kickstart.sh --stable-channel --claim-token ehDzlLFcfV_5srVBBUZz3zgUBZiiB_0cnoPwYtLFvi3FCwOIuQoXUI_RW-OzvSTZgg7UK-NUyDA7gZaQR-5zIbGE1_oZ8di3hoDcj2897N4ZOlJ-cjb8d-miKyGE1nEgotOtY18 --claim-rooms 91ad1c97-7e6d-4f72-aaed-b475df2a3b44 --claim-url https://app.netdata.cloud "$@"


