# bbinstall.* installs "packages" in various ways such as brew, asdf, curl, dnf, apt and so forth.

binstall.tbs() (
    set -Eeuo pipefail; shopt -s nullglob
    return $(u.error "${FUNCNAME} no installation supplied")
)
f.x binstall.tbs

# brew install will upgrade older versions.
# https://formulae.brew.sh/formula/elan-init#default
binstall.brew() (
    set -Eeuo pipefail; shopt -s nullglob
    u.have brew && command brew install "$@"
)
f.x binstall.brew

binstall.asdf() (
    : 'binstall.asdf [--version=latest] ${_plugin} [${_url}]'
    set -Eeuo pipefail; shopt -s nullglob

    local _version=latest _toolchain='' _pkg='' _url=''
    for _a in "${@}"; do
        case "${_a}" in
	    --version=*) _version="${_a##*=}";;
	    --toolchain=*) _toolchain="${_a##*=}";;
            --pkg=*) _pkg="${_a##*=}";;
            --url=*) _url="${_a##*=}";;
            --) shift; break;;
            *) break;;
        esac
        shift
    done
    
    [[ -z "${_pkg}" ]] && return $(u.error "${FUNCNAME} expecting --pkg=\${something}")
    >&2 asdf plugin add ${_pkg} ${_url:-} || true
    asdf install ${_pkg} ${_version} >&2
    asdf global ${_pkg} ${_version} >&2
    asdf which ${_pkg}
)
f.x binstall.asdf

binstall.curl() (
    set -Eeuo pipefail; shopt -s nullglob

    local _pkg='' _url='' _dir="${HOME}/.local/bin"
    for _a in "${@}"; do
        case "${_a}" in
            --pkg=*) _pkg="${_a##*=}";;
            --url=*) _url="${_a##*=}";;
            --dir=*) _dir="${_a##*=}";;
            --) shift; break;;
            *) break;;
        esac
        shift
    done

    [[ -z "${_pkg}" ]] && return $(u.error "${FUNCNAME} expecting --pkg=\${something}")    
    [[ -z "${_url}" ]] && return $(u.error "${FUNCNAME} expecting --url=\${something}")    
    local -r _suffix=${_url##*.}
    local -r _tmp=$(mktemp --suffix=.${_suffix})

    >&2 curl -LJ --show-error --output ${_tmp} "${_url}"
    [[ zst = "${_suffix}" ]] && zstd --decompress --no-progress "${_tmp}"

    
    local -r _target="${_dir}/${_pkg}"
    # TODO mike@carif.io: add ${_url} specific post processing here based on file extension
    # zstd --decompress --no-progress ${_tmp}
    # curl -Ssf ${_url} | tar xz -C /tmp
    >&2 command install ${_tmp%%.${_suffix}} "${_target}"
    >&2 echo "installed '${_target}' from '${_url}'"
    echo ${_target}
)    
f.x binstall.curl

binstall.sh() (
    : '${_url} ... # fetch a script remotely and run it'
    set -Eeuo pipefail; shopt -s nullglob

    local _pkg='' _url=''
    for _a in "${@}"; do
        case "${_a}" in
            --pkg=*) _pkg="${_a##*=}";;
            --url=*) _url="${_a##*=}";;
            --) shift; break;;
            *) break;;
        esac
        shift
    done

    [[ -z "${_pkg}" ]] && return $(u.error "${FUNCNAME} expecting --pkg=\${something}")    
    [[ -z "${_url}" ]] && return $(u.error "${FUNCNAME} expecting --url=\${something}")    

    >&2 printf "\n\nugh, hate this\n\n"
    # curl --proto '=https' --tlsv1.2 -sSf 
    (set -x; curl --proto '=https' --tlsv1.2 -sSLJ --show-error "${_url}" | bash -s -- "$@")
)    
f.x binstall.sh



binstall.curl-tar() (
    set -Eeuo pipefail; shopt -s nullglob

    local _pkg='' _url=''
    for _a in "${@}"; do
        case "${_a}" in
            --pkg=*) _pkg="${_a##*=}";;
            --url=*) _url="${_a##*=}";;
            --) shift; break;;
            *) break;;
        esac
        shift
    done

    [[ -z "${_pkg}" ]] && return $(u.error "${FUNCNAME} expecting --pkg=\${something}")    
    [[ -z "${_url}" ]] && return $(u.error "${FUNCNAME} expecting --url=\${something}")    

    local _suffix=${_url##*.tar.}
    local _dir=${3:-~/.local/bin}
    curl -SsfLJ --show-error "${_url}" | tar x --${_suffix} -C /tmp
    local _target="${_dir}/${_pkg}"
    # brittle, depends on how .tar.* was tarred
    local _cmd=/tmp/$(basename ${_url} .tar.${_suffix})/${_pkg}
    command install  "${_cmd}" "${_target}"
    rm -rf /tmp/$(basename ${_url} .tar.${_suffix})
    >&2 echo "installed '${_target}' from '${_url}'"
    echo ${_target}
)
f.x binstall.curl-tar

binstall.rustup() (
    : '[--home=somewhere] ${_pkg}...'
    set -Eeuo pipefail; shopt -s nullglob

    # parse calling arguments
    for _a in "${@}"; do
        case "${_a}" in
            --home=*) _home="${_a##*=}" ;;
            --)
                shift
                break
                ;;
            *) break ;;
        esac
        shift
    done

    # https://www.rust-lang.org/learn/get-started
    # https://rust-lang.github.io/rustup/installation/other.html
    # TODO mike@carif.io: install to ${_target}?
    [[ -n "${_home}" ]] && export CARGO_HOME="${_home}"
    # curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -- --verbose --no-modify-path --default-toolchain stable --profile complete
    binstall.sh https://sh.rustup.rs --verbose --no-modify-path --default-toolchain stable --profile complete
    # hardcoded installation directory ugh
    path.add "${_target}"
    binstall.check rustup cargo
    (( $# )) && cargo install "$@"
)



binstall.cargo() (
    set -Eeuo pipefail; shopt -s nullglob
    # rustup upgrade
    local _pkg=''
    declare -a _cmds=()

    for _a in "${@}"; do
        case "${_a}" in
            --pkg=*) _pkg="${_a##*=}";;
            --cmd=*) _cmds+="${_a##*=}";;            
            --) shift; break;;
            *) break;;
        esac
        shift
    done

    [[ -z "${_pkg}" ]] && return $(u.error "${FUNCNAME} expecting --pkg=\${something}")
    cargo install ${_pkg} $@
)
f.x binstall.cargo

binstall.check() (
    set -Eeuo pipefail; shopt -s nullglob
    for _command in "$@"; do
        local _exec="$(u.or $(type -p ${_command}) ${_command})"
        printf '%s (%s):\n' "${_command}" "${_exec}" >&2
        ${_command} --version &> /dev/null && ${_command} --version >&2 || ${_command} version >&2
    done
)
f.x binstall.check

binstall.go() (
    set -Eeuo pipefail; shopt -s nullglob

    local _url='' pkg=''
    for _a in "${@}"; do
        case "${_a}" in
            --url=*) _url="${_a##*=}";;
            # --pkg ignored
            --pkg=*) _pkg="${_a##*=}";;
            --) shift; break;;
            *) break;;
        esac
        shift
    done

    [[ -z "${_url}" ]] && return $(u.error "${FUNCNAME} expecting --url=\${something}")    
    GOBIN=${GOBIN:-$(go env GOBIN)} go install "${_url}"
)
f.x binstall.go


# by package manager

# Note that dnf can handle urls directly. Use the url instead of the package name.
# Note that web browser can often report the url they downloaded from. This can useful
# for ${_guard}.{dnf,apt}.binstall.sh.
binstall.dnf() (
    : '[--import=${url}]+ [--add-repo=${url}]+ {$pkg||$url} $pkg*'
    set -Eeuo pipefail; shopt -s nullglob

    local _pkg=''
    local -a _cmds=()

    for _a in "${@}"; do
        case "${_a}" in
            --add-repo=*) sudo $(type -P dnf) --assumeyes config-manager --add-repo "${_a##*=}";;
            # TODO mike@carif.io: --assumeyes doesn't work?
            --copr=*) sudo $(type -P dnf) --assumeyes copr enable "${_a##*=}";;
            --import=*) sudo $(type -P rpm) --import "${_a##*=}";;
            --pkg=*) _pkg="${_a##*=}";;
            --cmd=*) _cmds+="${_a##*=}";;
            --) shift; break;;
            *) break ;;
        esac
        shift
    done

    # $@ is a list of packages to binstall. For convenience, the first package is considered
    # the "primary" package and rest of the packages are considered prerequisites to be installed *first*.
    # set -x
    # local -a _pkgs=( "$@" )
    # If there are prerequisites, install them first...
    # ((${#_pkgs[*]} - 1)) && sudo $(type -P dnf) install --assumeyes ${_pkgs[*]:1}
    # ... and then install the primary package.
    # sudo $(type -P dnf) install --assumeyes ${_pkgs[0]}
    (( $# )) && sudo $(type -P dnf) install --assumeyes $@
    sudo $(type -P dnf) install --assumeyes ${_pkg}
    
)
f.x binstall.dnf

binstall.apt() (
    : '[--import=${url}]+ [--add-repo=${url}]+ pkg+'
    set -Eeuo pipefail; shopt -s nullglob

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


    # $@ is a list of packages to binstall. For convenience, the first package is considered
    # the "primary" package and rest of the packages are considered prerequisites to be installed *first*.
    local -a _pkgs=( "$@" )
    # If there are prerequisites, install them first...
    ((${#_pkgs[*]} - 1)) && sudo $(type -P apt) install -y "${_pkgs[*]:1}"
    # ... and then install the primary package.
    sudo $(type -P apt) install -y "${_pkgs[0]}"
)
f.x binstall.apt

binstall.distro() (
    set -Eeuo pipefail; shopt -s nullglob
    if u.have dnf; then
        # TODO mike@carif.io: fix pkg naming conventions here
        binstall.dnf "$@"
    elif u.have apt; then
        binstall.apt "$@"
    else
        false && return $(u.error "${FUNCNAME} cannot install '$@' on distro $(os.release ID)")
    fi
)
f.x binstall.distro


binstall.pip() (
    set -Eeuo pipefail; shopt -s nullglob

    local _pkg='' _url=''
    declare -a _cmds=()
    for _a in "${@}"; do
        case "${_a}" in
            --pkg=*) _pkg="${_a##*=}";;
            --url=*) _url="${_a##*=}";;
            --cmd=*) _cmds+="${_a##*=}";;
            --) shift; break;;
            *) break;;
        esac
        shift
    done

    [[ -z "${_pkg}" ]] && return $(u.error "${FUNCNAME} expecting --pkg=\${something}")    
    # [[ -z "${_url}" ]] && return $(u.error "${FUNCNAME} expecting --url=\${something}")    

    python -m pip install --upgrade pip
    python -m pip install --upgrade wheel setuptools
    # Install dependencies first if unstated in the package itself.
    # You only get one go at it.
    (( $# )) && python -m pip install --upgrade "$@"
    python -m pip install --upgrade ${_pkg}
    # TODO mike@carif.io: deduce commands pip ${_pkg} provides?
    binstall.check ${_cmds[*]}
)
f.x binstall.pip


binstall.AppImage() (
    : '${_name} ${_url} {_target:-~/opt/appimage/current/bin}'
    set -Eeuo pipefail; shopt -s nullglob

    local _pkg='' _url='' _dir="${HOME}/opt/appimage/current/bin"
    for _a in "${@}"; do
        case "${_a}" in
            --pkg=*) _pkg="${_a##*=}";;
            --url=*) _url="${_a##*=}";;
            --dir=*) _dir="${_a##*=}";;
            --) shift; break;;
            *) break;;
        esac
        shift
    done

    [[ -z "${_pkg}" ]] && return $(u.error "${FUNCNAME} expecting --pkg=\${something}")    
    [[ -z "${_url}" ]] && return $(u.error "${FUNCNAME} expecting --url=\${something}")    
    local -r _suffix=${_url##*.}

    local -r _scheme=${_url%*:}
    if [[ "${_scheme}" != file ]] ; then
        local -r _tmp=$(mktemp --suffix=.${_suffix})
        curl -LJ --show-error --output ${_tmp} "${_url}"
        local -r _source=${_tmp}
    else
        local -r _source=${_url/file://}
    fi
    local -r _target="${_dir}/${_pkg}"
    command install -v "${_source}" "${_target}"
    >&2 echo "installed '${_target}' from '${_url}'"
    echo ${_target}    
)
f.x binstall.AppImage


# dnf install git autoconf automake texinfo || true
binstall.git() (
    set -Eeuo pipefail; shopt -s nullglob

    local _pkg='' _url=''
    for _a in "${@}"; do
        case "${_a}" in
            --pkg=*) _pkg="${_a##*=}";;
            --url=*) _url="${_a##*=}";;
            --) shift; break;;
            *) break;;
        esac
        shift
    done

    [[ -z "${_pkg}" ]] && return $(u.error "${FUNCNAME} expecting --pkg=\${something}")    
    [[ -z "${_url}" ]] && return $(u.error "${FUNCNAME} expecting --url=\${something}")    

    local -r _repo="/tmp/$(path.basename ${_url})"
    
    ( [[ -d "${_repo}" ]] || git clone "${_url}" ${_repo}
      cd ${_repo}
      [[ -f ./autogen.sh ]] && ./autogen.sh
      make
      sudo make install ) >&2
    echo ${_repo}
)
f.x binstall.git

binstall.mkbinstall() (
    set -Eeuo pipefail; shopt -s nullglob

    local _pkg='' _kind=tbs
    for _a in "${@}"; do
        case "${_a}" in
            --pkg=*) _pkg="${_a##*=}";;
            --kind=*) _kind="${_a##*=}";;
            --) shift; break;;
            *) break;;
        esac
        shift
    done

    [[ -z "${_pkg}" ]] && _pkg=${1:?'expecting a pkg, either --pkg=${something} or first argument'}
    [[ -n "$2" ]] && _kind=$2
    local -r _regime=${FUNCNAME%.*}
    local -r _binstalld="$(bashenv.root)/profile.d/${_regime}.d"
    local -r _template="${_binstalld}/_template.tbs.${_regime}.sh"
    local -r _installer="${_binstalld}/${_pkg}.${_kind}.${_regime}.sh"
    cp --no-clobber "${_template}" "${_installer}"
    echo "${_installer}"
)
f.x binstall.mkbinstall



binstall.all() (
    set -Eeuo pipefail; shopt -s nullglob
    # local _kind=${FUNCNAME%*.}
    local _kind=install
    for _b in $(find $(bashenv.folders) -name \*.${_kind}.\*.sh -type f -executable -print0); do ${_b}; done
)
f.x binstall.all
