#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# [--uri=]* [--suite=]* [--component=]* [_components=]* [--signed-by=]* [--pkg=]* [--cmd=*]
binstall.$(path.basename.part $0 1) \
	 --signed-by="https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/windsurf.gpg" \
         --uri="https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/apt" \
         --component=stable --component=main \
         --pkg=$(path.basename "$0") \
         "$@"
# post install
