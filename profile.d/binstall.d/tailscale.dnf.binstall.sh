#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# --import= --repo= --copr= --pkg= --cmd=
binstall.$(path.basename.part $0 1) \
         --repo="https://pkgs.tailscale.com/stable/${_id}/$(path.basename "$0").repo" \
         --pkg=$(path.basename "$0") \
         "$@"
# post install
sudo systemctl enable --now tailscaled
systemctl status tailscaled
