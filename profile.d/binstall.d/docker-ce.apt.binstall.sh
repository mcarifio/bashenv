#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# --pkg= --cmd=
binstall.$(path.basename.part $0 1) \
         --signed-by=https://download.docker.com/linux/ubuntu/gpg \
         --component=$(os-release.version_codename) \
         --component=stable \
         --uri=https://download.docker.com/linux/ubuntu \
         --name=$(path.basename.part "$0") \
         $(u.switches pkg $(path.basename "$0"){,-cli} containerd.io docker-{buildx-plugin,compose-plugin}) \
         "$@"
# post install
sudo systemctl enable --now docker
sudo systemctl enable --now containerd
sudo usermod -aG docker $USER
echo "newgrp docker ## next"
