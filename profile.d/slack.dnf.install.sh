#!/usr/bin/env bash
set -Eeuo pipefail; shopt -s nullglob
[[ "$0" = */bashdb ]] && shift
source $(dirname "$0")/_defaults.install.sh # override these as needed

_install $(path.basename.part "$0" 1) $(path.basename "$0") "https://downloads.slack-edge.com/desktop-releases/linux/x64/4.39.95/slack-4.39.95-0.1.el8.x86_64.rpm"
