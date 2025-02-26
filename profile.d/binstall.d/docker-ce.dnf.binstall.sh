#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# --import= --repo= --copr= --pkg= --cmd=
binstall.$(path.basename.part $0 1) \
         --repo=https://download.docker.com/linux/$(os.release ID)/docker-ce.repo \
         $(u.switches pkg $(path.basename "$0"){,-cli} containerd.io docker-{buildx-plugin,compose-plugin}) \
         "$@"
# post install
sudo systemctl enable --now docker
sudo systemctl enable --now containerd
sudo usermod -aG docker $USER
echo "newgrp docker ## next"
