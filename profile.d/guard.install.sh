#!/usr/bin/env bash
# use guard.install.sh as the template to start ${item}.install.sh

# brew install will upgrade older versions.
# https://formulae.brew.sh/formula/elan-init#default
install.brew() ( brew install "$@"; )

# by distro id
install.fedora() ( sudo /usr/bin/dnf install --assumeyes "${$@}"; )
install.ubuntu() ( sudo /usr/bin/apt install -y "${$@}"; )

# dispatch
_install() ( install.$(os.release ID) "$@"; )
install() ( install.$(os.release ID) "$@"; )

install "$@"

