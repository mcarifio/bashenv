#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh

# https://forgejo.org/ https://forgejo.org/docs/latest/ https://codeberg.org/forgejo/forgejo/releases https://codeberg.org/forgejo/-/packages/container

# --login= --registry= --user= --password= --pkg=
binstall.$(path.basename.part $0 1) \
         --registry="codeberg.org" \
         --pkg="forgejo/forgejo:9.0.3" \
         "$@"
# post install
# docker run --name=${_pkg}-${USER} ${_pkg}
