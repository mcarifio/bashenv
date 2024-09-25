# install.* installs "packages" in various ways such as brew, asdf, curl, dnf, apt and so forth.

install.tbs() (
    set -Eeuo pipefail; shopt -s nullglob
    return $(u.error "${FUNCNAME} no installation supplied")
)
f.x install.tbs

# brew install will upgrade older versions.
# https://formulae.brew.sh/formula/elan-init#default
install.brew() (
    set -Eeuo pipefail; shopt -s nullglob
    u.have brew && command brew install "$@"
)
f.x install.brew

install.asdf() (
    : 'install.asdf [--version=latest] ${_plugin} [${_url}]'
    set -Eeuo pipefail; shopt -s nullglob

    local _version=latest _toolchain=''
     if (( ${#@} )) ; then
         for _a in "${@}"; do
            case "${_a}" in
		--version=*) _version="${_a##*=}";;
		--toolchain=*) _toolchain="${_a##*=}";;
                --) shift; break;;
                *) break;;
            esac
            shift
        done
    fi
    
    local _plugin=${1:?'expecting an asdf plugin'}
    asdf plugin add ${_plugin} ${2:-} || true
    { asdf install ${_plugin} ${_version} && asdf global ${_plugin} ${_version}; } >&2
    asdf which ${_plugin}
)
f.x install.asdf

install.curl() (
    set -Eeuo pipefail; shopt -s nullglob
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

install.sh() (
    : '${_url} ... # fetch a script remotely and run it'
    set -Eeuo pipefail; shopt -s nullglob
    local _name="${1:?'expecting a name'}"; shift
    local _url="${1:?'expecting a url'}"; shift
    >&2 printf "\n\nugh, hate this\n\n"
    # curl --proto '=https' --tlsv1.2 -sSf 
    curl --proto '=https' --tlsv1.2 -LJ --show-error "${_url}" | sh -- "$@"
)    
f.x install.sh



install.curl-tar() (
    set -Eeuo pipefail; shopt -s nullglob
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
    set -Eeuo pipefail; shopt -s nullglob

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
    # https://rust-lang.github.io/rustup/installation/other.html
    # TODO mike@carif.io: install to ${_target}?
    [[ -n "${_home}" ]] && export CARGO_HOME="${_home}"
    # curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -- --verbose --no-modify-path --default-toolchain stable --profile complete
    install.sh https://sh.rustup.rs --verbose --no-modify-path --default-toolchain stable --profile complete
    # hardcoded installation directory ugh
    path.add "${_target}"
    install.check rustup cargo
    (( $# )) && cargo install "$@"
)



install.cargo() (
    set -Eeuo pipefail; shopt -s nullglob
    # rustup upgrade
    local -r _pkg=${1:?'expecting a cargo package name'}; shift
    (( ${#@} )) && cargo install "$@" || cargo install ${_pkg}
)
f.x install.cargo

install.check() (
    set -Eeuo pipefail; shopt -s nullglob
    for _command in "$@"; do
        printf '%s (%s): ' ${_command} $(type -P ${_command})
        ${_command} --version &> /dev/null && ${_command} --version && break
        ${_command} version
    done >&2
)
f.x install.check

install.go() (
    set -Eeuo pipefail; shopt -s nullglob
    GOBIN=${GOBIN:-$(go env GOBIN)} go install ${1:?'expecting a url'}
)
f.x install.go


# by package manager

# Note that dnf can handle urls directly. Use the url instead of the package name.
# Note that web browser can often report the url they downloaded from. This can useful
# for ${_guard}.{dnf,apt}.install.sh.
install.dnf() (
    : '[--import=${url}]+ [--add-repo=${url}]+ {$pkg||$url} $pkg*'
    set -Eeuo pipefail; shopt -s nullglob

    if ((${#@})); then
        for _a in "${@}"; do
            case "${_a}" in
                --add-repo=*) sudo $(type -P dnf) config-manager --add-repo "${_a##*=}";;
                --copr=*) sudo $(type -P dnf) copr enable "${_a##*=}";;
                --import=*) sudo $(type -P dnf) config-manager --import "${_a##*=}";;
                --) shift; break;;
                *) break ;;
            esac
            shift
        done
    fi

    # $@ is a list of packages to install. For convenience, the first package is considered
    # the "primary" package and rest of the packages are considered prerequisites to be installed *first*.
    local -a _pkgs=( "$@" )
    # If there are prerequisites, install them first...
    ((${#_pkgs[*]} - 1)) && sudo $(type -P dnf) install --assumeyes "${_pkgs[*]:1}"
    # ... and then install the primary package.
    sudo $(type -P dnf) install --assumeyes "${_pkgs[0]}"
)
f.x install.dnf

install.apt() (
    : '[--import=${url}]+ [--add-repo=${url}]+ pkg+'
    set -Eeuo pipefail; shopt -s nullglob

    if ((${#@})); then
        for _a in "${@}"; do
            case "${_a}" in
                --add-repo=*) sudo $(type -P apt) add "${_a##*=}";;
                # --import=*) sudo $(type -P apt) config-manager --import "${_a##*=}";;
                --import=*) sudo $(type -P apt) apt import "${_a##*=}";;
                --) shift; break;;
                *) break ;;
            esac
            shift
        done
    fi

    # $@ is a list of packages to install. For convenience, the first package is considered
    # the "primary" package and rest of the packages are considered prerequisites to be installed *first*.
    local -a _pkgs=( "$@" )
    # If there are prerequisites, install them first...
    ((${#_pkgs[*]} - 1)) && sudo $(type -P apt) install -y "${_pkgs[*]:1}"
    # ... and then install the primary package.
    sudo $(type -P apt) install -y "${_pkgs[0]}"
)
f.x install.apt

install.distro() (
    set -Eeuo pipefail; shopt -s nullglob
    if u.have dnf; then
        # TODO mike@carif.io: fix pkg naming conventions here
        install.dnf "$@"
    elif u.have apt; then
        install.apt "$@"
    else
        false && return $(u.error "${FUNCNAME} cannot install '$@' on distro $(os.release ID)")
    fi
)
f.x install.distro


install.pip() (
    set -Eeuo pipefail; shopt -s nullglob
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
    : '${_name} ${_url} {_target:-~/opt/appimage/current/bin}'
    set -Eeuo pipefail; shopt -s nullglob
    local _name=${1:?'expecting a name'}
    local _url="${2:?'expecting a url'}"
    local _suffix=${_url##*.}
    local _dir=${3:-${HOME}/opt/appimage/current/bin}
    local _scheme=${_url%*:}
    if [[ "${_scheme}" != file ]] ; then
        local _tmp=$(mktemp --suffix=.${_suffix})
        curl -LJ --show-error --output ${_tmp} "${_url}"
        local _source=${_tmp}
    else
        local _source=${_url/file://}
    fi
    local _target="${_dir}/${_name}"
    command install -v "${_source}" "${_target}"
    >&2 echo "installed '${_target}' from '${_url}'"
    echo ${_target}    
)
f.x install.AppImage


# dnf install git autoconf automake texinfo || true
install.git() (
    set -Eeuo pipefail; shopt -s nullglob
    local -r _pkg=${1:-}
    local -r _url=${2:?'expecting a url'}
    local -r _repo="/tmp/$(path.basename ${_url})"
    
    ( [[ -d "${_repo}" ]] || git clone "${_url}" ${_repo}
      cd ${_repo}
      [[ -f ./autogen.sh ]] && ./autogen.sh
      make
      sudo make install ) >&2
    echo ${_repo}
)
f.x install.git


install.all() (
    set -Eeuo pipefail; shopt -s nullglob
    for i in $(bashenv.root)/profile.d/*.*.install.sh; do
        [[ -x "$i" ]] && $i || >&2 echo -e "\n\n\n*** $i failed\n\n\n"
    done
)
f.x install.all
