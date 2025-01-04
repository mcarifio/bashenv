#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# --login= --registry= --user= --password= --namespace= --pkg= --image= --tag= --digest=
_pkg=$(path.basename "$0"); binstall.$(path.basename.part $0 1) --pkg=${_pkg} "$@"
# post install
# docker run --name=${_pkg}-${USER} ${_pkg}
