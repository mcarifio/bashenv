#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
binstall.dnf --pkg=$(path.basename "$0")
npm install --global --no-fund npm
_pkgs="$(pn.first {~/opt/asdf/current,$(u.here)}/.default-npm-packages)"
[[ -r "${_pkgs}" ]] && npm install --global --no-fund $(sed 's/#.*$//' "${_pkgs}")




