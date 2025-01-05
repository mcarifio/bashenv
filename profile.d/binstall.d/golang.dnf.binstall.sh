#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# --import= --repo= --copr= --pkg= --cmd=
binstall.$(path.basename.part $0 1) \
         --pkg=$(path.basename "$0") \
         --cmd=go \
         "$@"
# post install
[[ -d ~/go ]] || mkdir -v ~/go
u.have go || { >&2 echo "$0 could not find go"; return 1; }
go env
binstall.go --url="github.com/posener/complete/gocomplete@latest"





#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh
binstalld.dispatch --kind=$(path.basename.part "$0" 1) --pkg=$(path.basename "$(realpath -Lm "$0")") --cmd=go "$@"





