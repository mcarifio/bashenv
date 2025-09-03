#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# [--ppa=]* [--uri=]* [--suite=]* [--component=]*  [--signed-by=]* [--pkg=]* [--cmd=*] [--check]
binstall.$(path.basename.part $0 1) \
         --signed-by=https://packages.microsoft.com/keys/microsoft.asc \
         --uri=https://packages.microsoft.com/repos/azure-cli/ \
         --component=main \
         --suite=jammy \
         --pkg=$(path.basename "$0") \
         --pkg=azcopy \
         --cmd=az \
         --cmd=azcopy \
         --check "$@"
# post install
