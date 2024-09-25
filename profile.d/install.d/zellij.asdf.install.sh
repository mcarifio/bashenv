#!/usr/bin/env bash
set -Eeuo pipefail; shopt -s nullglob
[[ "$0" = */bashdb ]] && shift
source $(dirname "$0")/_defaults.install.sh # override these as needed

# https://zellij.dev/launch
_installx --kind=$(path.basename.part "$0" 1) --pkg=$(path.basename "$0") "$@"


