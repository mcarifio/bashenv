#!/usr/bin/env bash
# ${guard}.install.sh will install ${guard} depending on the distro id.
# guard=${name} envsubst < _template.install.sh > ${guard}.install.sh

# brew install will upgrade older versions.
# https://formulae.brew.sh/formula/elan-init#default
install.brew() ( brew install "$@"; )

install.asdf() (
    set -Eeou pipefail
    local _plugin=${1:?'expecting an asdf plugin'}
    local _version=${2:-latest}
    asdf plugin add ${_plugin} ${3:-}
    asdf install ${_plugin} ${_version}
    asdf global ${_plugin} ${_version}
)

# by distro id
install.fedora() ( sudo /usr/bin/dnf install --assumeyes "${$@}"; )
install.ubuntu() ( sudo /usr/bin/apt install -y "${$@}"; )

# dispatch
# install() ( install.$(os.release ID) "$@"; )
install() ( install.$(os.release ID) "$@"; )

# install $(path.basename ${BASH_SOURCE}) "$@"
# install "$@"
install "$@"

