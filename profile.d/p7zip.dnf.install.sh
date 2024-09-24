#!/usr/bin/env bash
set -Eeuo pipefail; shopt -s nullglob
[[ "$0" = */bashdb ]] && shift
source $(dirname "$0")/_defaults.install.sh # override these as needed

_install $(path.basename.part "$0" 1) $(path.basename "$0"){,-plugins,-gui} "$@"

