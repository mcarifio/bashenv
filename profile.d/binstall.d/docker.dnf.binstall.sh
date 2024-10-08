#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/binstalld.lib.sh

post.install() (
    # after installation configuration
    systemctl.enable docker
    systemctl.enable containerd

    sudo usermod -aG docker $USER
    newgrp docker
)

# dnf remove podman || true
# --add-repo comes after --pkg
binstalld.dispatch --kind=$(path.basename.part "$0" 1) --postinstall=post.install --pkg=docker-ce \
                   --add-repo=https://download.docker.com/linux/$(os.release ID)/docker-ce.repo docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
binstall.dnf --pkg=https://desktop.docker.com/linux/main/amd64/docker-desktop-$(arch).rpm
