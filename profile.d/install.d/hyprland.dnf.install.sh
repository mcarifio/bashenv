#!/usr/bin/env bash
set -Eeuo pipefail; shopt -s nullglob
[[ "$0" = */bashdb ]] && shift
source $(dirname "$0")/_defaults.install.sh # override these as needed

# https://copr.fedorainfracloud.org/coprs/solopasha/hyprland
_installx --kind=$(path.basename.part "$0" 1) --pkg=$(path.basename "$0") --copr=solopasha/hyprland "$@"

