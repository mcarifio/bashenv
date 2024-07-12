#!/usr/bin/env bash
# _template.install.sh will install _template depending on the distro id.
# cp {_template,${guard}}.install.sh

# brew install will upgrade older versions.
# https://formulae.brew.sh/formula/elan-init#default
install.brew() ( brew install "$@"; )

# by distro id
install.fedora() ( sudo /usr/bin/dnf install --assumeyes "${$@}"; )
install.ubuntu() ( sudo /usr/bin/apt install -y "${$@}"; )

# dispatch
# install() ( install.$(os.release ID) "$@"; )
install() ( install.$(os.release ID) "$@"; )

install "$@"

