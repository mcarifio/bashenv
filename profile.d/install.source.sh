# install.* installs "packages" in various ways such as brew, asdf, curl, dnf, apt and so forth.

# brew install will upgrade older versions.
# https://formulae.brew.sh/formula/elan-init#default
install.brew() (
    set -Eeuo pipefail
    u.have brew && command brew install "$@"
)
f.x install.brew

install.asdf() (
    : 'install.asdf ${_plugin} [${_url} [${_version}]]'
    set -Eeuo pipefail
    local _plugin=${1:?'expecting an asdf plugin'}
    asdf plugin add ${_plugin} ${2:-} || true
    local _version=${3:-latest}
    asdf install ${_plugin} ${_version} && asdf global ${_plugin} ${_version}
    asdf which ${_plugin}
)
f.x install.asdf

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
f.x install.curl

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
f.x install.curl-tar

install.rustup() (
    : '[--home=somewhere] ${pkg}...'
    set -Eeuo pipefail

    # parse calling arguments
    if (( $# )); then
        for _a in "${@}"; do
            case "${_a}" in
                --home=*) _home="${_a#--target=}" ;;
                --)
                    shift
                    break
                    ;;
                *) break ;;
            esac
            shift
        done
    fi

    # https://www.rust-lang.org/learn/get-started
    # TODO mike@carif.io: install to ${_target}?
    # https://rust-lang.github.io/rustup/installation/other.html
    [[ -n "${_home}" ]] && export CARGO_HOME="${_home}"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -- --verbose --no-modify-path --default-toolchain stable --profile complete
    # hardcoded installation directory ugh
    path.add "${_target}"
    install.check rustup
    install.check cargo
    (( $# )) && cargo install "$@"
)



install.cargo() (
    set -Eeuo pipefail
    # local _id=$(os-release.id)
    # assume rust installed with rustup; rustup and cargo on PATH
    local _pkg=${1:?'expecting a package name'}; shift
    rustup upgrade
    cargo install ${_pkg} "$@"
    >&2 echo "${FUNCNAME} installed ${_pkg}"
    type -P ${_pkg}
)
f.x install.cargo

install.check() (
    set -Eeuo pipefail
    local _command="${1:?'expecting a command'}"
    echo "${FUNCNAME} ${_command} at $(type -P ${_command})"    
    ${_command} --version &> /dev/null && ${_command} --version && return 0
    ${_command} version
)
f.x install.check

install.go() (
    set -Eeuo pipefail
    GOBIN=${GOBIN:-$(go env GOBIN)} go install ${1:?'expecting a url'}
)
f.x install.go

# by distro id
install.fedora() (
    : '[--import=${url}]+ [--add-repo=${url}]+ pkg+'
    set -Eeuo pipefail

    if ((${#@})); then
        for _a in "${@}"; do
            case "${_a}" in
                --add-repo=*) dnf config-manager --add-repo "${_a#--add-repo=}";;
                --import=*) dnf config-manager --import "${_a#--import=}";;
                --)
                    shift
                    break
                    ;;
                *) break ;;
            esac
            shift
        done
    fi
    local _last=${1:?'expecting a package'}; shift
    ((${#@})) && sudo $(type -P dnf) install --assumeyes "$@"
    sudo $(type -P dnf) install --assumeyes "${_last}"
)
f.x install.fedora

install.ubuntu() (
    set -Eeuo pipefail
    sudo $(type -P apt) install -y "$@"
)
f.x install.ubuntu

install.distro() (
    set -Eeuo pipefail
    if type -P dnf > /dev/null; then
        # TODO mike@carif.io: fix pkg naming conventions here
        sudo $(type -P dnf) install --assumeyes "$@"
    elif type -P apt > /dev/null; then
        sudo $(type -P apt) install -y "$@" && return $?
    # TODO mike@carif.io: other platforms here as they're needed.
    # elif type -P ${command} install ${stuff}
    else
        false && return $(u.error "${FUNCNAME} cannot install '$@' on distro $(os.release ID)")
    fi
)
f.x install.distro


install.pip() (
    set -Eeuo pipefail
    local _pkg=${1:?'expecting a pip python package (please)'}; shift
    python -m pip install --upgrade pip
    python -m pip install --upgrade wheel setuptools
    # Install dependencies first if unstated in the package itself.
    # You only get one go at it.
    (( $# )) && python -m pip install --upgrade "$@"
    python -m pip install --upgrade ${_pkg}    
)
f.x install.pip


install.AppImage() (
    : '${_url} {_target:-~/opt/appimage/current/bin}'
    local _name=${1:?'expecting a name'}
    local _url="${2:?'expecting a url'}"
    local _suffix=${_url##*.}
    local _dir=${3:-${HOME}/opt/appimage/current/bin}
    local _scheme=${_url%*:}
    if [[ "${_scheme}" != file ]] ; then
        local _tmp=$(mktemp --suffix=.${_suffix})
        curl -LJ --show-error --output ${_tmp} "${_url}"
        local _source=${_tmp}/*.AppImage
    else
        local _source=${_url/file://}
    fi
    local _target="${_dir}/${_name}"
    command install -v "${_source}" "${_target}"
    >&2 echo "installed '${_target}' from '${_url}'"
    echo ${_target}    
)


install.all() (
    for i in $(bashenv.root)/profile.d/*.install.sh; do
        [[ -x "$i" ]] && $i || >&2 echo -e "\n\n\n*** $i failed\n\n\n"
    done
)
f.x install.all
