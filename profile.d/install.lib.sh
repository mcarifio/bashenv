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
    asdf which ${_plugin}
)

install.curl() (
    set -Eeuo pipefail
    local _name="${1:?'expecting a name'}"
    local _url="${2:?'expecting a url'}"
    local _suffix=${_url##*.}
    local _dir=${3:-~/.local/bin}
    local _tmp=$(mktemp --suffix=.${_suffix})
    curl -LJ --show-error --output ${_tmp} "${_url}"
    local _target="${_dir}/${_name}"
    # TODO mike@carif.io: add ${_url} specific post processing here based on file extension
    # zstd --decompress --no-progress ${_tmp}
    # curl -Ssf ${_url} | tar xz -C /tmp
    command install ${_tmp%%.${_suffix}} "${_target}"
    >&2 echo "installed '${_target}' from '${_url}'"
    echo ${_target}
)    

install.curl-tar() (
    set -Eeuo pipefail
    local _name="${1:?'expecting a name'}"
    local _url="${2:?'expecting a url'}"
    local _suffix=${_url##*.tar.}
    local _dir=${3:-~/.local/bin}
    curl -SsfLJ --show-error "${_url}" | tar x --${_suffix} -C /tmp
    local _target="${_dir}/${_name}"
    # brittle, depends on how .tar.* was tarred
    local _cmd=/tmp/$(basename ${_url} .tar.${_suffix})/${_name}
    command install  "${_cmd}" "${_target}"
    rm -rf /tmp/$(basename ${_url} .tar.${_suffix})
    >&2 echo "installed '${_target}' from '${_url}'"
    echo ${_target}
)


install.cargo() (
    set -Eeuo pipefail
    # local _id=$(os-release.id)
    # assume rust installed with rustup; rustup and cargo on PATH
    local _pkg=${1:?'expecting a package name'}; shift
    rustup upgrade
    (set -x; cargo install ${_pkg} "$@")
    >&2 echo "${FUNCNAME} installed ${_pkg}"
    type -P ${_pkg}
)

install.check() (
    echo -e "${FUNCNAME}\n"
    local _command="${1:?'expecting a command'}"
    type -p ${_command}
    ${_command} --version
)

# by distro id
install.fedora() ( sudo $(type -P dnf) install --assumeyes "$@"; )
install.ubuntu() ( sudo $(type -P apt) install -y "$@"; )

