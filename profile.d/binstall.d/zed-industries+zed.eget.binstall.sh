#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# --pkg=${_owner}+${_project} --cmd=
_zed_root=~/opt/zed/current
binstall.$(path.basename.part $0 1) --pkg=$(path.basename "$0") --to="${_zed_root}" --asset=.tar.gz --file='*' 
# post install
${_zed_root}/bin/zed --version
