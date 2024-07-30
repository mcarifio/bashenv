#!/usr/bin/env bash
# ${guard}.install.sh will install ${guard} depending on the distro id.
# guard=${name} envsubst < _template.install.sh > ${guard}.install.sh

# brew install will upgrade older versions.
# https://formulae.brew.sh/formula/elan-init#default
install.brew() ( brew install "$@"; )

# install.asdf ${_plugin} [${_version:-latest} [${_git_url}]]
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
    local _name="${1:?'expecting a name'}"
    local _url="${2:?'expecting a url'}"
    local _suffix=${_url##*.}
    local _dir=${3:-~/.local/bin}
    local _tmp=$(mktemp --suffix=.${_suffix})
    curl -LJ --show-error --output ${_tmp} "${_url}"
    # add ${_url} specific post processing here
    # zstd --decompress --no-progress ${_tmp}
    local _target="${_dir}/${_name}"
    command install ${_tmp%%.${_suffix}} "${_target}"
    >&2 echo "installed '${_target}' from '${_url}'"
)    

# by distro id
install.fedora() ( sudo $(type -P dnf) install --assumeyes "${$@}"; )
install.ubuntu() ( sudo $(type -P apt) install -y "${$@}"; )

# dispatch
# install() ( install.$(os.release ID) "$@"; )
install() (
    install.asdf "$@"
)

# install $(path.basename ${BASH_SOURCE}) "$@"
# install "$@"
install $(path.basename ${BASH_SOURCE}) "$@"

