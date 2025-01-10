#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# [--uri=]* [--suite=]* [--component=]* [_components=]* [--signed-by=]* [--pkg=]* [--cmd=*]
binstall.$(path.basename.part $0 1) \
	 --signed-by="https://dl-ssl.google.com/linux/linux_signing_key.pub" \
         --uri="http://dl.google.com/linux/chrome/deb" \
         --component=stable --component=main \
         --pkg=$(path.basename "$0") \
         "$@"
# post install
