#!/usr/bin/env bash
# ${guard}.install.sh will install ${guard} depending on the distro id.
# guard=${name} envsubst < _template.install.sh > ${guard}.install.sh

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

