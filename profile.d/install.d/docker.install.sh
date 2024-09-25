#!/usr/bin/env bash
set -Eeuo pipefail

post.install() (
    # after installation configuration
    systemctl.enable docker
    systemctl.enable containerd

    sudo usermod -aG docker $USER
    newgrp docker
)


# see install.lib.sh for install variants
install() (
    dnf remove podman || true
    # TODO mike@carif.io: if docker installed from fedora repo, remove it
    # TODO mike@carif.io: how to handle /var/lib/docker/**? Does changing the docker version ruin downloaded artifacts?
    # sudo dnf remove docker \
    #               docker-client \
    #               docker-client-latest \
    #               docker-common \
    #               docker-latest \
    #               docker-latest-logrotate \
    #               docker-logrotate \
    #               docker-selinux \
    #               docker-engine-selinux \
    #               docker-engine || true
    
    # https://docs.docker.com/engine/install/fedora/
    local -r _distro=$(os.release ID) _arch=$(arch) _suffix=amd64
    install.${_distro} --add-repo=https://download.docker.com/linux/${_distro}/docker-ce.repo \
            docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin --allowerasing
    install.${_distro} https://desktop.docker.com/linux/main/${_suffix}/docker-desktop-${_arch}.rpm
    post.install
    install.check docker
    docker run hello-world    
)

install

