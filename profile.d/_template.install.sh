#!/usr/bin/env bash
set -Eeuo pipefail; shopt -s nullglob
[[ "$0" = */bashdb ]] && shift
source ${0%/*}/_defaults.install.sh

_install $(path.basename.part "$0" 1) $(path.basename "$0") "$@"

