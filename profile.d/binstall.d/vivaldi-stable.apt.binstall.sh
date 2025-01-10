#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# [--uri=]* [--suite=]* [--component=]* [_components=]* [--signed-by=]* [--pkg=]* [--cmd=*]
binstall.$(path.basename.part $0 1) \
	 --signed-by="https://repo.vivaldi.com/archive/linux_signing_key.pub" \
         --uri="https://repo.vivaldi.com/archive/deb" \
         --component=stable --component=main \
         --pkg=$(path.basename "$0") \
         "$@"
# post install
