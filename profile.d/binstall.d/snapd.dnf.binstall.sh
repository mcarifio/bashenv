#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# --import= --repo= --copr= --pkg= --cmd=
binstall.$(path.basename.part $0 1) \
         --pkg=$(path.basename "$0") \
         "$@"
# post install
sudo ln -s /var/lib/snapd/snap /snap || true
sudo systemctl enable --now snapd.socket
