#!/usr/bin/env bash
# ${guard}.install.sh will install ${guard} depending on the distro id.
# guard=${name} envsubst < _template.install.sh > ${guard}.install.sh

# brew install will upgrade older versions.
# https://formulae.brew.sh/formula/elan-init#default
install.brew() ( brew install "$@"; )

install.asdf() (
    set -Eeuo pipefail
    local _plugin=${1:?'expecting an asdf plugin'}
    local _version=${2:-latest}
    asdf plugin add ${_plugin} ${3:-}
    asdf install ${_plugin} ${_version}
    asdf global ${_plugin} ${_version}
)

install.curl() (
    set -Eeuo pipefail
    local _url="${1:?'expecting a url'}"
    local _bin="${2:?'expecting an abs pathname'}"
    curl --output="${_bin}" "${_url}"
    chmod a+x "${_bin}"
    >&2 echo "installed '${_bin}' from '${_url}'"
)

# by distro id
install.fedora() ( sudo /usr/bin/dnf install --assumeyes "${$@}"; )
install.ubuntu() ( sudo /usr/bin/apt install -y "${$@}"; )

# dispatch
# install() ( install.$(os.release ID) "$@"; )
install() (
    set -Eeuo pipefail
    local _buck2=~/.local/bin/${1:?'expecting a name'}
    local _tmp=$(mktemp --suffix=.zst)
    curl -LJ --show-error --output ${_tmp} ${2:?'expecting a url'}
    zstd --decompress --no-progress ${_tmp}
    command install ${_tmp%%.zst} "${_buck2}"
    >&2 echo "installed '${_buck2}' from '$2'"
)    

# install $(path.basename ${BASH_SOURCE}) "$@"
# install "$@"
install $(path.basename ${BASH_SOURCE}) \
        https://github.com/facebook/buck2/releases/download/latest/buck2-x86_64-unknown-linux-gnu.zst "$@"

