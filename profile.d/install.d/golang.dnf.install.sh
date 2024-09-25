#!/usr/bin/env bash
set -Eeuo pipefail; shopt -s nullglob
[[ "$0" = */bashdb ]] && shift
source $(dirname "$0")/_defaults.install.sh # override these as needed

_installx --kind=$(path.basename.part "$0" 1) --pkg=$(path.basename "$0") --cmd=go "$@"
GOBIN=~/.local/bin go install github.com/posener/complete/gocomplete@latest


