#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# --url= --version= [--pkg=] [--cmd=]* [--url=plugin-url]
binstall.$(path.basename.part $0 1) \
         --pkg=$(path.basename "$0") \
         --url=https://github.com/canha/asdf-pulumi.git \
         "$@"

binstall.$(path.basename.part $0 1) \
         --pkg=$(path.basename "$0")ctl \
         --url=https://github.com/adrianriobo/asdf-pulumictl \
         "$@"

# post install
