#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/binstalld.lib.sh
binstall.dispatch --kind=dnf --pkg=rlwrap
binstalld.dispatch --kind=$(path.basename.part "$0" 1) --pkg=$(path.basename "$0") --url="github.com/traefik/yaegi/cmd/yaegi@latest" "$@"


