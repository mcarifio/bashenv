#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# --pkg= --cmd=
binstall.$(path.basename.part $0 1) \
         --pkg=$(path.basename "$0") \
         "$@"
# post install
npm install --global --no-fund npm
_pkgs="$(pn.first  ${ASDF_NPM_DEFAULT_PACKAGES_FILE} {${ASDF_DIR},$(u.here)}/.default-npm-packages)"
[[ -r "${_pkgs}" ]] && npm install --global --no-fund $(sed 's/#.*$//' "${_pkgs}")
