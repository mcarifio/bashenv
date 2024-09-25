#!/usr/bin/env bash
set -Eeuo pipefail; shopt -s nullglob
[[ "$0" = */bashdb ]] && shift
source $(dirname "$0")/_defaults.install.sh # override these as needed

install.dnf ShellCheck shunit2 log4sh


