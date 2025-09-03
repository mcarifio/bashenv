# ${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

binstall.tbs() (
    set -Eeuo pipefail; shopt -s nullglob
    return $(u.error "${FUNCNAME} no installation supplied" 1)
)
f.x binstall.tbs

# brew install will upgrade older versions.
# https://formulae.brew.sh/formula/elan-init#default
binstall.brew() (
    set -Eeuo pipefail; shopt -s nullglob
    local _cmd=${FUNCNAME##*.}
    u.have ${_cmd}  || return $(u.error "${FUNCNAME}: ${FUNCNAME##*.} not on path, stopping.")

    local _version=latest _toolchain='' _pkg='' _url=''
    local -a _cmds=()
    
    for _a in "${@}"; do
        local _k="${_a%%=*}"
        local _v="${_a##*=}"
        case "${_a}" in
	    --version=*) _version="${_v}";;
            --pkg=*) _pkg="${_v}";;
            --url=*) _url="${_v}";;
            --cmd=*) _cmds+=("${_v}");;
            --) shift; break;;
            *) break;;
        esac
        shift
    done    
    [[ -z "${_pkg}" ]] && return $(u.error "${FUNCNAME} expecting --pkg=\${something}")
    command ${_cmd} install "$@" ${_pkg}
)
f.x binstall.brew

binstall.snap() (
    # >&2 echo "$@"
    set -Eeuo pipefail; shopt -s nullglob
    local _cmd=${FUNCNAME##*.}
    u.have ${_cmd}  || return $(u.error "${FUNCNAME}: ${_cmd} not on PATH")
    
    local _pkg=''

    for _a in "${@}"; do
        local _k="${_a%%=*}"
        local _v="${_a##*=}"
        case "${_a}" in
            --pkg=*) _pkg="${_a##*=}";;
            --) shift; break;;
            *) break;;
        esac
        shift
    done
    
    [[ -z "${_pkg}" ]] && return $(u.error "${FUNCNAME} expecting --pkg=\${something}")    
    sudo $(type -P ${_cmd}) install   --classic "$@" ${_pkg}
)
f.x binstall.snap


binstall.eget() (
    : '--pkg=${_owner}/${_project}[@${_tag}]'
    # >&2 echo "$@"
    set -Eeuo pipefail; shopt -s nullglob
    local _cmd=${FUNCNAME##*.}
    u.have ${_cmd}  || return $(u.error "${FUNCNAME}: ${_cmd} not on PATH")

    local -i _check=0
    local _version=latest
    local _pkg=''
    local -a _cmds=()
    for _a in "${@}"; do
        local _k="${_a%%=*}"
        local _v="${_a##*=}"
        case "${_a}" in
            --check) _check=1;;
            --version=*) _version="${_v}";;
            --pkg=*) _pkg="${_v//\+/\/}";;
            --cmd=*) _cmds+=("${_v}");;
            --) shift; break;;
            *) break;;
        esac
        shift
    done
    
    [[ -z "${_pkg}" ]] && return $(u.error "${FUNCNAME} expecting --pkg=\${something}")    
    ${_cmd} "$@" "${_pkg}"
    (( _check )) && binstall.check ${_cmds[@]}
)
f.x binstall.eget

binstall.pkgx() (
    : '--pkg=${_owner}/${_project}[@${_tag}]'
    # >&2 echo "$@"
    set -Eeuo pipefail; shopt -s nullglob
    local _cmd=${FUNCNAME##*.}
    u.have ${_cmd}  || return $(u.error "${FUNCNAME}: ${_cmd} not on PATH")

    local -i _check
    local _pkg2cmd=''
    local -a _cmds=()
    local _version=latest _pkg=''
    for _a in "${@}"; do
        local _k="${_a%%=*}"
        local _v="${_a##*=}"
        case "${_a}" in
            --check) _check=1;;
            --pkg=*) _pkg2cmd="${_v##*+}"; _pkg="${_v//+\/}";;
            --cmd=*) _cmds+=("${_v}");;
            --) shift; break;;
            *) break;;
        esac
        shift
    done
    
    [[ -z "${_pkg}" ]] && return $(u.error "${FUNCNAME} expecting --pkg=\${something}")
    ${_cmd} "$@" "${_pkg}"
    (( ${#_cmds[@]} )) || _cmds=( ${_pkg2cmd} )
    (( _check )) && binstall.check ${_cmds[@]}
)
f.x binstall.pkgx


binstall.asdf() (
    : 'binstall.asdf [--version=latest] ${_plugin} [${_url}]'
    set -Eeuo pipefail; shopt -s nullglob
    local _cmd=${FUNCNAME##*.}
    u.have ${_cmd} || return $(u.error "${FUNCNAME}: ${_cmd} not on PATH")

    local -i _check
    local _version=latest
    local _pkg=''
    local _url=''
    local -a _cmds=()
    for _a in "${@}"; do
        local _k="${_a%%=*}"
        local _v="${_a##*=}"
        case "${_a}" in
            --check) _check=1;;
	    --version=*) _version="${_v}";;
	    # --toolchain=*) _toolchain="${_a##*=}";;
            --pkg=*) _pkg="${_v}";;
            --url=*) _url="${_v}";;
            --cmd=*) _cmds+=("${_v}");;
            --) shift; break;;
            *) break;;
        esac
        shift
    done
    
    [[ -z "${_pkg}" ]] && return $(u.error "${FUNCNAME} expecting --pkg=\${something}")
    [[ -z "${_cmd}" ]] && _cmd="${_pkg}"
    >&2 asdf plugin add ${_pkg} ${_url:-}
    asdf install ${_pkg} ${_version} >&2
    asdf global ${_pkg} ${_version} >&2
    asdf reshim ${_pkg}
    asdf which ${_pkg}
    (( _check )) && binstall.check ${_pkg} ${_cmds[@]}
)
f.x binstall.asdf

binstall.curl() (
    set -Eeuo pipefail; shopt -s nullglob
    local _cmd=${FUNCNAME##*.}
    u.have ${_cmd} || return $(u.error "${FUNCNAME}: '${_cmd}' not on PATH")

    local -i _check=0
    local _pkg=''
    local _url=''
    local _dir="${HOME}/.local/bin"
    local -a _cmds=()    
    for _a in "${@}"; do
        local _k="${_a%%=*}"
        local _v="${_a##*=}"
        case "${_a}" in
            --check) _check=1;;
            --pkg=*) _pkg="${_v}";;
            --url=*) _url="${_v}";;
            --dir=*) _dir="${_v}";;
            --cmd=*) _cmds+=("${_v}");;
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
    [[ xz = "${_suffix}" ]] && xz --decompress "${_tmp}"

    
    local -r _target="${_dir}/${_pkg}"
    # TODO mike@carif.io: add ${_url} specific post processing here based on file extension
    # zstd --decompress --no-progress ${_tmp}
    # curl -Ssf ${_url} | tar xz -C /tmp
    >&2 command install ${_tmp%%.${_suffix}} "${_target}"
    >&2 echo "installed '${_target}' from '${_url}'"
    (( _check )) && binstall.check ${_cmds[@]}
    echo ${_target}
)    
f.x binstall.curl


binstall.zip() (
    : '${_url} ${_folder} ## fetch and unzip a remote zip file, moving all executables to ${_folder}'
    set -Eeuo pipefail
    local _url=${1:-'expecting a url'}
    local _folder="${2:-$(path.mp \"${HOME}/.local/bin\")}"
    # _tmp, a working folder in /tmp, to unzip ${_url}
    local _tmp="$(mktemp --suffix=${FUNCNAME})"
    # _tmp always removed regardless of success
    trap -- "rm -rf ${_tmp}; trap - RETURN;" RETURN
    curl -sSL "${_url}" | bsdtar -C "${_tmp}" -s '|[^/]*/||' -xf -
    for _f in "${_tmp}/*"; do bashenv.is.elf "${_f}" && install --target-directory="${_folder}" "${_f}"; done
)
f.x binstall.zip





binstall.sh() (
    : '${_url} ... # fetch a script remotely and run it'
    set -Eeuo pipefail; shopt -s nullglob

    local -i _check=0
    local _pkg=''
    local _url=''
    local -a _cmds=()    
    for _a in "${@}"; do
        local _k="${_a%%=*}"
        local _v="${_a##*=}"
        case "${_a}" in
            --check) _check=1;;
            --pkg=*) _pkg="${_v}";;
            --url=*) _url="${_v}";;
            --cmd=*) cmds+=("${_v}");;
            --) shift; break;;
            *) break;;
        esac
        shift
    done

    [[ -z "${_pkg}" ]] && return $(u.error "${FUNCNAME} expecting --pkg=\${something}")    
    [[ -z "${_url}" ]] && return $(u.error "${FUNCNAME} expecting --url=\${something}")    

    curl --proto '=https' --tlsv1.2 -sSLJ --show-error "${_url}" | bash -s -- "$@"
    (( _check )) && binstall.check ${_cmds[@]}
)    
f.x binstall.sh



binstall.curl-tar() (
    set -Eeuo pipefail; shopt -s nullglob

    local -r _suffix=${FUNCNAME##*.}
    u.have.all ${_suffix//-/ } || return $(u.error "${FUNCNAME} missing some of '${_suffix//-/ }'")

    local -i _check=0
    local _pkg=''
    local _url=''
    local -a _cmds=()
    for _a in "${@}"; do
        local _k="${_a%%=*}"
        local _v="${_a##*=}"
        case "${_a}" in
            --check) _check=1;;
            --pkg=*) _pkg="${_v}";;
            --url=*) _url="${_v}";;
            --cmd=*) cmds+=("${_v}");;
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
    (( _check )) && binstall.check ${_cmds[@]}
    echo ${_target}
)
f.x binstall.curl-tar

binstall.rustup() (
    : '[--home=somewhere] ${_pkg}...'
    set -Eeuo pipefail; shopt -s nullglob

    local -i _check=0
    local -a _pkgs=()
    # parse calling arguments
    for _a in "${@}"; do
        local _k="${_a%%=*}"
        local _v="${_a##*=}"
        case "${_a}" in
            --check) _check=1;;
            --home=*) _home="${_v}";;
            --pkg=*) _pkgs+=("${_v}");;
            --) shift; break;;
            *) break ;;
        esac
        shift
    done

    # https://www.rust-lang.org/learn/get-started
    # https://rust-lang.github.io/rustup/installation/other.html
    # TODO mike@carif.io: install to ${_target}?
    [[ -n "${_home}" ]] && export CARGO_HOME="${_home}"
    # curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -- --verbose --no-modify-path --default-toolchain stable --profile complete
    binstall.sh https://sh.rustup.rs -- -y --verbose --no-modify-path --default-toolchain stable --profile complete
    # hardcoded installation directory ugh
    source ${CARGO_HOME:-~/.cargo/}env
    (( _check )) && binstall.check rustup cargo
    for _crate in ${_pkgs[@]} "$@"; do binstall.cargo ${_crate}; done
)



binstall.cargo() (
    set -Eeuo pipefail; shopt -s nullglob
    local _cmd=${FUNCNAME##*.}
    u.have ${_cmd} || return $(u.error "${FUNCNAME}: ${_cmd} not on PATH.")

    local _pkg=''
    declare -a _cmds=()

    for _a in "${@}"; do
        local _k="${_a%%=*}"
        local _v="${_a##*=}"
        case "${_a}" in
            --check) _check=1;;
            --pkg=*) _pkg="${_v}";;
            --cmd=*) _cmds+=("${_v}");;            
            --) shift; break;;
            *) break;;
        esac
        shift
    done

    [[ -z "${_pkg}" ]] && return $(u.error "${FUNCNAME} expecting --pkg=something")
    path.add ${CARGO_HOME:-~/.cargo}/bin
    u.have cargo || return $(u.error "${FUNCNAME} cannot find cargo on PATH")
    cargo install --locked $@ ${_pkg}
    (( _check )) && binstall.check ${_cmds[@]}
)
f.x binstall.cargo

binstall.check() (
    set -Eeuo pipefail; shopt -s nullglob
    for _command in "$@"; do
        # For each possible ${_command} switch
        for _switch in --version version -V --help; do
            # ... attempt the command with the switch silently. If it succeeds issue it again and break.
            command ${_command} ${_switch} &> /dev/null && printf '%s %s\n%s\n\n' "${_command}" "${_switch}" "$(command ${_command} ${_switch})" >&2 && break
        done
        (( $? )) && >&2 printf "${_command} failed?\n\n"
    done
)
f.x binstall.check

binstall.go() (
    set -Eeuo pipefail; shopt -s nullglob
    local _cmd=${FUNCNAME##*.}
    u.have ${_cmd} || return $(u.error "${FUNCNAME}: ${_cmd} not on PATH.")

    local -i _check=0
    local pkg=''
    local _url=''
    local -a _cmds=()
    for _a in "${@}"; do
        local _k="${_a%%=*}"
        local _v="${_a##*=}"
        case "${_a}" in
            --check) _check=1;;
            --url=*) _url="${_v}";;
            --pkg=*) _pkg="${_v}";;
            --cmd=*) _cmds+=("${_v}");;
            --) shift; break;;
            *) break;;
        esac
        shift
    done

    [[ -n "${_url}" ]] || return $(u.error "${FUNCNAME} expecting --url=\${something}")
    GOBIN=${GOBIN:-$(go env GOBIN)} go install "${_url}"
    (( _check )) && binstall.check ${_cmds[@]}
)
f.x binstall.go


# by package manager

# Note that dnf can handle urls directly. Use the url instead of the package name.
# Note that web browser can often report the url they downloaded from. This can useful
# for ${_guard}.{dnf,apt}.binstall.sh.
binstall.dnf() (
    # >&2 echo ${FUNCNAME}@${LINENO} "$@"
    set -Eeuo pipefail; shopt -s nullglob
    local _cmd=${FUNCNAME##*.}
    local _installer=$(type -P ${FUNCNAME##*.})
    [[ -n "${_installer}" ]] || return $(u.error "${FUNCNAME}: ${_installer} not on PATH")
    
    local -i _status=0
    local -i _check=0
    local -a _imports=()
    local -a _repos=()
    local -a _coprs=()
    local -a _pkgs=()
    local -a _cmds=()

    for _a in "${@}"; do
        local _k="${_a%%=*}"
        local _v="${_a##*=}"
        # >&2 echo ${FUNCNAME}@${LINENO} ${_k} ${_v}
        case "${_a}" in
            --check) _check=1;;
            --import=*) _imports+=("${_v}");;
            --add-repo=*|--repo=*) _repos+=("${_v}");;
            --copr=*) _coprs+=("${_v}");;
            --pkg=*) _pkgs+=("${_v}");;
            --cmd=*) _cmds+=("${_v}");;
            --) shift; break;;
            *) break ;;
        esac
        shift
    done

    (( ${#_pkgs[@]} )) || return $(u.error "${FUNCNAME}@${LINENO}: expecting --pkg=something")

    for _import in "${_imports[@]}"; do sudo $(type -P rpmkeys) --import "${_import}" || u.warn "${FUNCNAME}@${LINENO}: cannot import '${_import}', skipping..."; done
    for _repo in "${_repos[@]}"; do sudo ${_installer} --assumeyes config-manager addrepo --overwrite --from-repofile="${_repo}" || u.warn "${FUNCNAME}@${LINENO}: cannot addrepo '${_repo}', skipping..."; done
    # TODO mike@carif.io: --assumeyes doesn't work?
    for _copr in "${_coprs[@]}"; do sudo ${_installer} --assumeyes copr enable "${_copr}" || u.warn "${FUNCNAME}@${LINENO}: cannot enable copr '${_copr}', skipping..."; done
    sudo ${_installer} install --assumeyes $@ ${_pkgs[@]} || sudo ${_installer} install --assumeyes --no-best --allowerasing --skip-unavailable $@ ${_pkgs[@]} 
    (( _check )) && binstall.check $(binstall.dnf.pkg.cmds ${_pkgs[@]}) ${_cmds[@]} 
)
f.x binstall.dnf


binstall.dnf.all() (
    local _installer=$(path.basename ${FUNCNAME} 1)
    for _a in $(find $(bashenv.binstalld) -mindepth 1 -maxdepth 1 -name \*.${_installer}.binstall.sh -a ! -name _\*.${_installer}.binstall.sh -executable); do
        u.have $(path.basename ${_a}) || ${_a}
    done
)
f.x binstall.dnf.all



binstall.dnf.find-pkg() (
    # >&2 echo ${FUNCNAME} "$@"
    set -Eeuo pipefail; shopt -s nullglob
    # forward this function call to _delegate with the name switches and modified arguments
    local _delegate=${FUNCNAME%.*}
    # recast non-switch arguments using _arguments
    local _arguments=${FUNCNAME#*.}

    local _options=''
    for _a in "${@}"; do
        local _k="${_a%%=*}"
        local _v="${_a##*=}"
        case "${_a}" in
            # gather options to forward them
            --*) _options="${_options} ${_a}";;
            --) shift; break;;
            *) break ;;
        esac
        shift
    done

    # echo \
    ${_delegate} "${_options}" $(u.switches pkg $(${_arguments} "$@"))
)
f.x binstall.dnf.find-pkg


binstall.dnf.pkg.cmd-pathnames() (
    : '${pkg}... ## |> pathnames, e.g. /usr/bin/ysh'
    set -Eeuo pipefail; shopt -s nullglob
    rpm -ql "$@" | grep --extended-regexp '^/usr/s?bin/' | sort | uniq
)
f.x binstall.dnf.pkg.cmd-pathnames

binstall.dnf.pkg.cmds() (
    : '${pkg}... ## |> cmds'
    set -Eeuo pipefail; shopt -s nullglob
    binstall.dnf.pkg.cmd-pathnames "$@" | sort | uniq
)
f.x binstall.dnf.pkg.cmds

binstall.dnf.installers-by-cmd() (
    : '# relative symlink all dnf installers by their cmds. pkg must be installed'
    set -Eeuo pipefail; shopt -s nullglob
    for _installer in $(binstall.installers dnf); do
        for _cmd in $(binstall.dnf.pkg.cmds $(path.basename.part ${_installer} 0)); do
            ln -srv ${_installer} $(dirname ${_installer})/by-cmd.d/${_cmd}.dnf.binstall.sh || true
        done
    done                  
)


# create sources .list style. eventually remove this
binstall.aptlist() (
    : '[--uri=${url}]+ [--suite=${suite}]+ [--component=${component}] [--signed-by=${url}] pkg+'
    set -Eeuo pipefail; shopt -s nullglob
    local _cmd=${FUNCNAME##*.}
    u.have ${_cmd} || return $(u.error "${FUNCNAME}: ${_cmd} not on PATH")

    local -i _check=0
    local -i _status=0
    local -a _debconfs=() _uris=() _suites=() _components=() _keys=() _cmds=() _pkgs=() _ppas=()
    local _name=''
    local -i _trusted=0
    for _a in "$@"; do
        local _k="${_a%%=*}"
        local _v="${_a##*=}"
        case "${_a}" in
            # adds [trusted=yes] to add repos, use with caution
            --check) _check=1;;
            --trusted) _trusted=1;;
            --name=*) _name="${_v}";;
            --debconf=*) _debconfs+=("${_v}");;
            --uri=*) _uri="${_v}";;
            --ppa=*) _ppas+=("${_v}");;
            --suite=*) _suites+=("${_v}");;
            --component=*) _components+=("${_v}");;
            --signed-by=*) _key="${_v}";;
            --pkg=*) _pkgs+=("${_v}");;
            --cmd=*) _cmds+=("${_v}");;
            --) shift; break;;
            *) break ;;
        esac
        shift
    done

    (( ${#_pkgs[@]} )) || return $(u.error "${FUNCNAME} expecting --pkg=something")
    [[ -z "${_name}" ]] && _name=${_pkgs[0]}


    # TODO mike@carif.io: btrfs snapshot of /?
    
    # keys
    if [[ -n "${_key}" ]] ; then
        local _keyrings="/usr/share/keyrings"
        local _keyring="${_keyrings}/${_name}.gpg"
        # TODO mike@carif.io: is this the preferred method and local target?
        curl -sSL "${_key}" | sudo gpg --dearmor -o "${_keyring}"
        >&2 echo "Added '${_keyring}' from '${_key}'"
    fi

    # debconfs
    if (( ${#_debconfs[@]} )) ; then
        for _debconf in "${_debconfs[@]}"; do
            echo "${_debconf}" | sudo debconf-set-selections
        done
    fi

    # ppas
    if (( ${#_ppas[@]} )) ; then
        for _ppa in "${_ppas[@]}"; do
            sudo add-apt-repository -y "${_ppa}" && >&2 echo "Added ppa '${_ppa}'"
        done
    fi


    # uris -> sources.list.d
    if [[ -n "${_uri}" ]] ; then
        local _source="/etc/apt/sources.list.d/${_name}.list"
        (( ${#_components[@]} )) || _components=(main universe restricted multiverse) 
        if [[ ! -r "${_source}" ]] ; then
            printf 'deb [arch=%s signed-by=%s] %s %s\n' $(dpkg --print-architecture) "${_keyring}" "${_uri}" "$(printf '%s ' ${_components[@]})"  | sudo tee -ap "${_source}"
            >&2 echo "Created ${_source}"
        fi
    fi

    apt update
    apt install -y "$@" ${_pkgs[@]}
    (( _check )) && binstall.check $(binstall.${_cmd}.pkg.cmds ${_pkgs[@]}) ${_cmds[@]}
)
f.x binstall.aptlist

binstall.apt() (
    : '[--uri=${url}] [--suite=${suite}]* [--component=${component}]+ [--signed-by=${url}] pkg+'
    set -Eeuo pipefail; shopt -s nullglob
    local _cmd=${FUNCNAME##*.}
    u.have ${_cmd} || return $(u.error "${FUNCNAME}: ${_cmd} not on PATH")

    local -i _check=0
    local -i _status=0
    local -a _debconfs=() _uris=() _suites=() _components=() _keys=() _cmds=() _pkgs=() _ppas=()
    local _name='' _key='' _uri=''
    local -i _trusted=0 _check=0
    for _a in "$@"; do
        local _k="${_a%%=*}"
        local _v="${_a##*=}"
        case "${_a}" in
            # adds [trusted=yes] to add repos, use with caution
            --check) _check=1;;
            --trusted) _trusted=1;;
            --name=*) _name="${_v}";;
            --debconf=*) _debconfs+=("${_v}");;
            --uri=*) _uri="${_v}";;
            --ppa=*) _ppas+=("${_v}");;
            --suite=*) _suites+=("${_v}");;
            --component=*) _components+=("${_v}");;
            --signed-by=*) _key="${_v}";;
            --pkg=*) _pkgs+=("${_v}");;
            --cmd=*) _cmds+=("${_v}");;
            --) shift; break;;
            *) break ;;
        esac
        shift
    done

    (( ${#_pkgs[@]} )) || return $(u.error "${FUNCNAME} expecting --pkg=something")
    [[ -z "${_name}" ]] && _name=${_pkgs[0]}


    # TODO mike@carif.io: btrfs snapshot of /?
    
    # keys
    if [[ -n "${_key}" ]] ; then
        local _key_signed_by=$(mktemp -q --suffix=.gpg)
        # TODO mike@carif.io: is this the preferred method and local target?
        curl -fsSL "${_key}" | gpg --yes --dearmor -o "${_key_signed_by}" # force output
    fi

    # debconfs
    if (( ${#_debconfs[@]} )) ; then
        for _debconf in "${_debconfs[@]}"; do
            echo "${_debconf}" | sudo debconf-set-selections
        done
    fi

    # ppas
    if (( ${#_ppas[@]} )) ; then
        for _ppa in "${_ppas[@]}"; do
            sudo add-apt-repository -y "${_ppa}" && >&2 echo "Added ppa '${_ppa}'"
        done
    fi


    # uris -> sources.list.d
    if [[ -n "${_uri}" ]] ; then
        local _source="/etc/apt/sources.list.d/${_name}.sources"
        # (( ${#_components[@]} )) || _components=(main universe restricted multiverse) 
        if [[ ! -r "${_source}" ]] ; then
            local _signed_by=/usr/share/keyrings/${_name}.gpg
            (printf 'Types: deb\nEnabled: yes\nArchitectures: %s\nURIs: %s\nSuites: %s\nComponents: %s\n' $(dpkg --print-architecture) "${_uri}" "$(printf '%s ' ${_suites[@]})" "$(printf '%s ' ${_components[@]})" ; [[ -r "${_key_signed_by}" ]] && echo "Signed-By: ${_signed_by}") | sudo tee -ap "${_source}"
            sudo install -o root -g root ${_key_signed_by} ${_signed_by}
            >&2 echo "Created ${_source}"
        fi
    fi

    apt update
    apt install -y "$@" ${_pkgs[@]}
    (( _check )) && binstall.check $(binstall.${_cmd}.pkg.cmds ${_pkgs[@]}) ${_cmds[@]}
)
f.x binstall.apt

f.x binstall.apt

binstall.apt.all() (
    : 'install all missing commands via apt by way of binstall.d'
    local _installer=$(path.basename ${FUNCNAME} 1)
    for _a in $(find $(bashenv.binstalld) -mindepth 1 -maxdepth 1 -name \*.${_installer}.binstall.sh -a ! -name _\*.${_installer}.binstall.sh -executable); do
        u.have $(path.basename ${_a}) || ${_a}
    done
)
f.x binstall.apt.all


binstall.apt.pkg.cmd-pathnames() (
    : '${pkg}... ## |> pathnames, e.g. /usr/bin/ysh'
    set -Eeuo pipefail; shopt -s nullglob
    dpkg -L "$@" | grep --extended-regexp '^/usr/s?bin/' | sort | uniq
)
f.x binstall.apt.pkg.cmd-pathnames

binstall.apt.pkg.cmds() (
    : '${pkg}... ## |> cmds'
    set -Eeuo pipefail; shopt -s nullglob
    basename -a $(binstall.apt.pkg.cmd-pathnames "$@") | sort | uniq
)
f.x binstall.apt.pkg.cmds

binstall.apt.installers-by-cmd() (
    : '# relative symlink all dnf installers by their cmds. pkg must be installed'
    set -Eeuo pipefail; shopt -s nullglob
    for _installer in $(binstall.installers apt); do
        for _cmd in $(binstall.apt.pkg.cmds $(path.basename.part ${_installer} 0)); do
            ln -srv ${_installer} $(dirname ${_installer})/${_cmd}.apt.binstall.sh || true
        done
    done                  
)


binstall.distro() (
    set -Eeuo pipefail; shopt -s nullglob
    if u.have dnf; then
        # TODO mike@carif.io: fix pkg naming conventions here
        binstall.dnf "$@"
    elif u.have apt; then
        binstall.apt "$@"
    else
        false && return $(u.error "${FUNCNAME}: ${FUNCNAME} cannot install '$@' on distro $(os.release ID)")
    fi
)
f.x binstall.distro


binstall.pip() (
    set -Eeuo pipefail; shopt -s nullglob
    python -m pip list &> /dev/null || return $(u.error "python -m pip not working, stopping.")

    local -i _check=0
    local -a _pkgs=() _cmds=()
    for _a in "${@}"; do
        local _k="${_a%%=*}"
        local _v="${_a##*=}"
        case "${_a}" in
            --check) _check=1;;
            --pkg=*) _pkgs+=("${_v}");;
            --cmd=*) _cmds+=("${_v}");;
            --) shift; break;;
            *) break;;
        esac
        shift
    done

    (( ${#_pkgs[@]} )) || return $(u.error "${FUNCNAME} expecting --pkg=\${something}")    

    python -m pip install --upgrade pip
    python -m pip install --upgrade wheel setuptools
    # Install dependencies first if unstated in the package itself.
    # You only get one go at it.
    python -m pip install --upgrade ${_pkgs[@]}
    # TODO mike@carif.io: deduce commands pip ${_pkg} provides?
    (( _check )) && binstall.check ${_cmds[@]}
)
f.x binstall.pip


git.gh.release-AppImage() (
    local _owner_project=${1:?"${FUNCNAME} expecting a github owner/project"}
    local _release=${2:-latest}
    curl -s https://api.github.com/repos/${_owner_project}/releases/${_release} | jq -r '.assets[] | select(.name | endswith(".AppImage")) | .browser_download_url'    
)
f.x git.gh.release-AppImage

binstall.AppImage() (
    : '${_name} ${_url} {_target:-~/opt/appimage/current/bin}'
    set -Eeuo pipefail; shopt -s nullglob

    local _pkg='' _url='' _dir="${HOME}/opt/appimage/current/bin"
    for _a in "${@}"; do
        local _k="${_a%%=*}"
        local _v="${_a##*=}"
        case "${_a}" in
            --pkg=*) _pkg="${_v}";;
            --url=*) _url="${_v}";;
            --dir=*) _dir="${_v}";;
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
    u.have ${FUNCNAME##*.} || return $(u.error "${FUNCNAME##*.} not on path, stopping.")

    local _pkg='' _url=''
    for _a in "${@}"; do
        local _k="${_a%%=*}"
        local _v="${_a##*=}"
        case "${_a}" in
            --pkg=*) _pkg="${_v}";;
            --url=*) _url="${_v}";;
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

binstall.npm() (
    # TODO mike@carif.io: broken
    set -Eeuo pipefail; shopt -s nullglob
    local _cmd=${FUNCNAME##*.}
    u.have ${_cmd} || return $(u.error "${FUNCNAME}: ${_cmd} not on PATH.")

    local -i _check=0
    local -a _pkgs=() _cmds=()
    for _a in "${@}"; do
        local _k="${_a%%=*}"
        local _v="${_a##*=}"
        case "${_a}" in
            --check) _check=1;;
            --pkg=*) _pkgs+=("${_v}");;
            --cmd=*) _cmds+=("${_v}");;            
            --) shift; break;;
            *) break;;
        esac
        shift
    done

    (( ${#_pkgs[@]} )) || return $(u.error "${FUNCNAME} expecting --pkg=something")
    npm install -g --no-fund npm
    npm install -g --no-fund "$@" ${_pkgs[@]}
    (( ${#_cmds[@]} )) || _cmds=( ${_pkgs[@]} )
    (( _check )) && binstall.check ${_cmds[@]}
)
f.x binstall.npm


binstall.bun() (
    # TODO mike@carif.io: broken
    set -Eeuo pipefail; shopt -s nullglob
    local _cmd=${FUNCNAME##*.}
    u.have ${_cmd} || return $(u.error "${FUNCNAME}: ${_cmd} not on PATH.")

    local -i _check=0
    local -a _pkgs=() _cmds=()
    for _a in "${@}"; do
        local _k="${_a%%=*}"
        local _v="${_a##*=}"
        case "${_a}" in
            --check) _check=1;;
            --pkg=*) _pkgs+=("${_v}");;
            --cmd=*) _cmds+=("${_v}");;            
            --) shift; break;;
            *) break;;
        esac
        shift
    done

    (( ${#_pkgs[@]} )) || return $(u.error "${FUNCNAME} expecting --pkg=something")
    bun add --global --no-fund "$@" ${_pkgs[@]}
    (( ${#_cmds[@]} )) || _cmds=( ${_pkgs[@]} )
    (( _check )) && binstall.check ${_cmds[@]}
)
f.x binstall.bun



binstall.docker() (
    : '--login= --registry= --user= --password= --namespace= --pkg= --image= --tag= --digest='
    set -Eeuo pipefail; shopt -s nullglob
    local _cmd=${FUNCNAME##*.}
    u.have ${_cmd} || return $(u.error "${FUNCNAME}: ${_cmd} not on PATH")

    local -i _login=0
    local _registry=''
    local _user=${USER}
    local _password=''
    
    # ${_registry}/[${_namespace}/]${_pkg}[:${_tag}][@${_digest}]
    local _namespace='' # optional
    local _pkg='' # image name, required
    local _tag='' # human readable version, optional, docker default 'latest'
    local _digest='' # machine specific version
    
    for _a in "${@}"; do
        local _k="${_a%%=*}"
        local _v="${_a##*=}"
        case "${_a}" in
            # docker login [--user=${_user}] [--password=${_password}] [${_registry}]
            --login) _login=1;;
            --registry=*) _registry="${_v}";;
            --user=*) _user="${_v}";;
            --password=*) _password="${_v}";;

            # docker pull 
            # --namespace=*) _namespace="${_v}";;
            # docker calls the "package" an image, which is the correct terminology
            # but is called "pkg" throughout the rest of these functions. Don't fight it,
            # just give the same concept two names.
            --pkg=*|--image=*) _pkg="${_v//+/\/}";;
            # we call `tag` `version` elsewhere
            # --tag=*|--version=*) _tag="${_v}";;
            # --digest=*) _digest="${_v}";; 

            --) shift; break;;
            *) break;;
        esac
        shift
    done

    # _pkg required
    [[ -n "${_pkg}" ]] || return $(u.error "${FUNCNAME} expecting --pkg=\${something} or --image=${something}, none found")

    (( ${_login} )) && docker login \
                              --username ${_user:?"${FUNCNAME} expecting a username for login"} \
                              --password ${_password:?"${FUNCNAME} expecting a password for login"} \
                              ${_registry}
    [[ -n "${_registry}" ]] && _pkg="${_registry}/${_pkg}"
    (set -x; docker pull "$@" "${_pkg}")
)
f.x binstall.docker

binstall.nix() (
    :
)
f.x binstall.nix


# useful for _all.${_installer}.binstall.sh scripts
binstall.external-switches() (
    local _pathname="${1:?"expecting a pathname"}"; shift
    local _result=''
    for _s in "$@"; do
        local _switch_pathname="${_pathname}.${_s}.list"
        [[ -r "${_switch_pathname}" ]] && _result+="$(u.switches ${_s} $(< "${_switch_pathname}"))"
    done
    echo "${_result}"
)
f.x binstall.external-switches


binstall.installer() (
    set -Eeuo pipefail
    binstall.installers ${1:?"${FUNCNAME} expecting a _pkg"}
)
f.x binstall.installer

binstall.mkbinstall() (
    set -Eeuo pipefail; shopt -s nullglob

    local _pkg='' _kind=''
    for _a in "${@}"; do
        local _k="${_a%%=*}"
        local _v="${_a##*=}"
        case "${_a}" in
            --kind=*) _kind="${_v}";;
            --pkg=*) _pkg="${_v}";;
            --) shift; break;;
            *) break;;
        esac
        shift
    done

    [[ -n "${_kind}" ]] || return $(u.error "${FUNCNAME} expecting --kind=something")
    [[ -n "${_pkg}" ]] || return $(u.error "${FUNCNAME} expecting --pkg=something")
    bashenv.mkinstaller "${_kind}" "${_pkg}"
)
f.x binstall.mkbinstall

binstall.installers() (
    : '[${_pkg} [${kind}]] #> echo ${kind} executable binstallers in all binstall*.d directories that are not tbs; kind defaults to *'
    set -Eeuo pipefail; shopt -s nullglob
    local _suffix=${FUNCNAME%.*}.sh
    local _binstalld="$(bashenv.binstalld)"
    local _name=${1:-*}.${2:-*}.${_suffix}
    # EXMPL mike@carif.io: find
    # find switch order matters, depth first, then name the type, executable
    # find all executable installers that are not tbs (to be supplied)
    # set -x    
    find "${_binstalld}" -mindepth 1 -maxdepth 1 -name "${_name}" -not -name \*.tbs.${_suffix} -type f -executable
)
f.x binstall.installers

binstall.missing() (
    set -Eeuo pipefail; shopt -s nullglob
    for _m in $(sourced.missing); do
        local _guard=$(path.basename.part ${_m} 0)
        local -a _installers=( $(binstall.installer ${_guard}) )
        for _p in $(binstall.preference); do
            local _installer="$(bashenv.binstalld)/${_guard}.${_p}.binstall.sh"
            [[ -x "${_installer}" ]] || break
            echo ${_installer} || true 
        done
    done
)
f.x binstall.missing

# binstall.run launches or runs an installer script in $(bashenv.binstalld).
# It's real value is in bash completing candidate scripts in $(bashenv.binstalld).
binstall.run() (
    : '${_script} ## run installer script ${_script}'
    set -Eeuo pipefail; shopt -s nullglob
    local _script=${1:?"${FUNCNAME} expecting a script pathname"}; shift
    [[ -x "${_script}" ]] || return $(u.error "${FUNCNAME} ${_script} is not executable.")
    ${_script} "$@"
)
__complete.binstall.run() {
    local _command=$1 _word=$2 _previous_word=$3
    local -i _position=${COMP_CWORD} _arg_length=${#COMP_WORDS[@]}

    # Completion so far is a pathname in $(bashenv.binstalld) with the beginning of a filename.
    # To winnow selections, take the basename of _word and find candidate completions.
    local _prefix=${_word##*/}
    # The candidate completions are all executable files in directory $(bashenv.binstalld) with the prefix ${_word}
    # that follow the naming convention *.binstall.sh and are not *.tbs.binstall.sh. The tbs files ("to be supplied") are
    # placeholders for figuring out how best to install something.
    COMPREPLY=( $(find "$(bashenv.binstalld)" -name "${_prefix}*.binstall.sh" -not -name \*.tbs.binstall.sh -type f -executable ) )
}
f.complete binstall.run


binstall.source() {
    local _source=${1:?"${FUNCNAME} expecting a pathname"}
    [[ -r "${_source}" ]] && source "${_source}" "$@"
}
__complete.binstall.source() {
    local _command=$1 _word=$2 _previous_word=$3
    local -i _position=${COMP_CWORD} _arg_length=${#COMP_WORDS[@]}
    COMPREPLY=( $(compgen -f "$(bashenv.profiled)/${_word##*/}") )
    # declare -p COMPREPLY >&2
}
f.complete binstall.source


binstall.source.missing() {
    local _source=${1:?"${FUNCNAME} expecting a pathname"}
    [[ -r "${_source}" ]] && source "${_source}" "$@"
}
__complete.binstall.source.missing() {
    local _command=$1 _word=$2 _previous_word=$3
    local -i _position=${COMP_CWORD} _arg_length=${#COMP_WORDS[@]}
    COMPREPLY=( $(sourced.missing | grep -E "\.d/${_word##*/}.*\.source\.sh$") )
    # declare -p COMPREPLY >&2
}
f.complete binstall.source.missing



binstall.preference() (
    : 'the preference order for multiple binstallers'
    set -Eeuo pipefail; shopt -s nullglob
    echo dnf asdf cargo AppImage go pip npm sh curl git script
)
f.x binstall.preference

binstall.installers.preferred() (
    set -Eeuo pipefail; shopt -s nullglob
    binstall.preference >&2
    return $(error "${FUNCNAME} tbs")
)
f.x binstall.installers.preferred

binstall.all() (
    : '[--kind=${kind}]* # ex --kind=dnf --kind=cargo'
    set -Eeuo pipefail; shopt -s nullglob

    local _binstalld="$(bashenv.binstalld)"
    local -a _kinds=() 
    for _a in "${@}"; do
        local _k="${_a%%=*}"
        local _v="${_a##*=}"
        case "${_a}" in
            --binstalld=*) _binstalld="${_v}";;
            --kind=*) _kinds+=("${_v}");;
            --) shift; break;;
            *) break;;
        esac
        shift
    done

    (( ${#_kinds[@]} )) || _kinds=( $(binstall.kinds --binstalld="${_binstalld}") )
    for _k in ${_kinds[@]}; do
        for _b in $(find ${_binstalld} -maxdepth 1 -mindepth 1 -name \*.${_kind}.binstall.sh -type f -a ! type -exec); do
            ${_b}
        done
    done    
)
f.x binstall.all

sourced || true

