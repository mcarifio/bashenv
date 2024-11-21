# ${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

binstall.tbs() (
    set -Eeuo pipefail; shopt -s nullglob
    return $(u.error "${FUNCNAME} no installation supplied")
)
f.x binstall.tbs

# brew install will upgrade older versions.
# https://formulae.brew.sh/formula/elan-init#default
binstall.brew() (
    set -Eeuo pipefail; shopt -s nullglob
    local _cmd=${FUNCNAME##*.}
    u.have ${_cmd}  || return $(u.error "${FUNCNAME}: ${FUNCNAME##*.} not on path, stopping.")

    local _version=latest _toolchain='' _pkg='' _url=''    
    for _a in "${@}"; do
        case "${_a}" in
	    --version=*) _version="${_a##*=}";;
            --pkg=*) _pkg="${_a##*=}";;
            --url=*) _url="${_a##*=}";;
            --) shift; break;;
            *) break;;
        esac
        shift
    done    
    [[ -z "${_pkg}" ]] && return $(u.error "${FUNCNAME} expecting --pkg=\${something}")    

    command ${_cmd} install "$@"
)
f.x binstall.brew

binstall.snap() (
    set -Eeuo pipefail; shopt -s nullglob
    local _cmd=${FUNCNAME##*.}
    u.have ${_cmd}  || return $(u.error "${FUNCNAME}: ${FUNCNAME##*.} not on path, stopping.")
    local _version=latest _toolchain='' _pkg='' _url=''    
    for _a in "${@}"; do
        case "${_a}" in
	    --version=*) _version="${_a##*=}";;
            --pkg=*) _pkg="${_a##*=}";;
            --url=*) _url="${_a##*=}";;
            --) shift; break;;
            *) break;;
        esac
        shift
    done
    
    [[ -z "${_pkg}" ]] && return $(u.error "${FUNCNAME} expecting --pkg=\${something}")    
    sudo $(type -P ${_cmd}) install ${_pkg}  "$@"
)
f.x binstall.snap

binstall.asdf() (
    : 'binstall.asdf [--version=latest] ${_plugin} [${_url}]'
    set -Eeuo pipefail; shopt -s nullglob
    u.have ${FUNCNAME##*.} || return $(u.error "${FUNCNAME}: ${FUNCNAME##*.} not on path, stopping.")

    local _version=latest _toolchain='' _pkg='' _url=''
    for _a in "${@}"; do
        case "${_a}" in
	    --version=*) _version="${_a##*=}";;
	    --toolchain=*) _toolchain="${_a##*=}";;
            --pkg=*) _pkg="${_a##*=}";;
            --url=*) _url="${_a##*=}";;

            --*) >&2 echo "${FUNCNAME}: unknown switch ${_a}, stop processing switches"; break;;
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
    u.have ${FUNCNAME##*.} || return $(u.error "${FUNCNAME}: ${FUNCNAME##*.} not on path, stopping.")

    local _pkg='' _url='' _dir="${HOME}/.local/bin"
    for _a in "${@}"; do
        case "${_a}" in
            --pkg=*) _pkg="${_a##*=}";;
            --url=*) _url="${_a##*=}";;
            --dir=*) _dir="${_a##*=}";;

            --*) >&2 echo "${FUNCNAME}: unknown switch ${_a}, stop processing switches"; break;;
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

    local _pkg='' _url=''
    for _a in "${@}"; do
        case "${_a}" in
            --pkg=*) _pkg="${_a##*=}";;
            --url=*) _url="${_a##*=}";;

            --*) >&2 echo "${FUNCNAME}: unknown switch ${_a}, stop processing switches"; break;;
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

    local -r _suffix=${FUNCNAME##*.}
    for _c in ${_suffix//-/ }; do
        u.have ${_c} || return $(u.error "${FUNCNAME}: ${_c} not found on path")
    done

    local _pkg='' _url=''
    for _a in "${@}"; do
        case "${_a}" in
            --pkg=*) _pkg="${_a##*=}";;
            --url=*) _url="${_a##*=}";;

            --*) >&2 echo "${FUNCNAME}: unknown switch ${_a}, stop processing switches"; break;;
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

            --*) >&2 echo "${FUNCNAME}: unknown switch ${_a}, stop processing switches"; break;;
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
    binstall.sh https://sh.rustup.rs --verbose --no-modify-path --default-toolchain stable --profile complete
    # hardcoded installation directory ugh
    path.add "${_target}"
    binstall.check rustup cargo
    (( $# )) && cargo install "$@"
)



binstall.cargo() (
    set -Eeuo pipefail; shopt -s nullglob
    u.have ${FUNCNAME##*.} || return $(u.error "${FUNCNAME}: ${FUNCNAME##*.} not on path, stopping.")

    local _pkg='' _options=''
    declare -a _cmds=()

    for _a in "${@}"; do
        case "${_a}" in
            --pkg=*) _pkg="${_a##*=}";;
            --cmd=*) _cmds+="${_a##*=}";;            
            --git=*) _options+=" ${_a}";;
            --git) return $(u.error "${FUNCNAME} expecting --git=url, got just --git");;
            --*) >&2 echo "${FUNCNAME}: unknown switch ${_a}, stop processing switches"; break;;
            --) shift; break;;
            *) break;;
        esac
        shift
    done

    [[ -z "${_pkg}" ]] && return $(u.error "${FUNCNAME} expecting --pkg=\${something}")
    u.have cargo || path.add ~/.cargo/bin
    cargo install ${_options} ${_pkg} $@
)
f.x binstall.cargo

binstall.check() (
    set -Eeuo pipefail; shopt -s nullglob
    echo >&2
    for _command in "$@"; do
        local _exec="$(u.or $(type -p ${_command}) ${_command})"
        printf '%s (%s): ' "${_command}" "${_exec}" >&2
        # For each possible ${_command} switch
        for _switch in --version version -V --help; do
            # ... attempt the command with the switch silently. If it succeeds issue it again and break.
            ${_command} ${_switch} &> /dev/null && (set -x; ${_command} ${_switch}) >&2 && break
        done
        echo >&2
    done
)
f.x binstall.check

binstall.go() (
    set -Eeuo pipefail; shopt -s nullglob
    u.have ${FUNCNAME##*.} || return $(u.error "${FUNCNAME}: ${FUNCNAME##*.} not on path, stopping.")

    local _url='' pkg=''
    for _a in "${@}"; do
        case "${_a}" in
            --url=*) _url="${_a##*=}";;
            # --pkg ignored
            --pkg=*) _pkg="${_a##*=}";;

            --*) >&2 echo "${FUNCNAME}: unknown switch ${_a}, stop processing switches"; break;;
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
    u.have ${FUNCNAME##*.} || return $(u.error "${FUNCNAME}: ${FUNCNAME##*.} not on path, stopping.")

    local _pkg=''
    local -a _cmds=()

    for _a in "${@}"; do
        case "${_a}" in
            --add-repo=*) sudo $(type -P dnf) --assumeyes config-manager addrepo --from-repofile="${_a##*=}";;
            # TODO mike@carif.io: --assumeyes doesn't work?
            --copr=*) sudo $(type -P dnf) --assumeyes copr enable "${_a##*=}";;
            --import=*) sudo $(type -P rpm) --import "${_a##*=}";;
            --pkg=*) _pkg="${_a##*=}";;
            --cmd=*) _cmds+="${_a##*=}";;

            --*) break;;
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
    sudo $(type -P dnf) install --assumeyes $@ ${_pkg}
    
)
f.x binstall.dnf

binstall.dnf.pkg.cmd-pathnames() (
    : '${pkg}... ## |> pathnames, e.g. /usr/bin/ysh'
    set -Eeuo pipefail; shopt -s nullglob
    rpm -ql "$@" | grep --extended-regexp '^/usr/s?bin/' | sort | uniq
)
f.x binstall.dnf.pkg.cmd-pathnames

binstall.dnf.pkg.cmds() (
    : '${pkg}... ## |> cmds'
    set -Eeuo pipefail; shopt -s nullglob
    basename -a $(binstall.dnf.pkg.cmd-pathnames "$@") | sort | uniq
)
f.x binstall.dnf.pkg.cmds

binstall.dnf.installers-by-cmd() (
    : '# relative symlink all dnf installers by their cmds. pkg must be installed'
    set -Eeuo pipefail; shopt -s nullglob
    for _installer in $(binstall.installers dnf); do
        for _cmd in $(binstall.dnf.pkg.cmds $(path.basename.part ${_installer} 0)); do
            ln -srv ${_installer} $(dirname ${_installer})/${_cmd}.dnf.binstall.sh || true
        done
    done                  
)



binstall.apt() (
    : '[--import=${url}]+ [--add-repo=${url}]+ pkg+'
    set -Eeuo pipefail; shopt -s nullglob
    u.have ${FUNCNAME##*.} || return $(u.error "${FUNCNAME}: ${FUNCNAME##*.} not on path, stopping.")

    for _a in "${@}"; do
        case "${_a}" in
            --add-repo=*) sudo $(type -P apt) add "${_a##*=}";;
            # --import=*) sudo $(type -P apt) config-manager --import "${_a##*=}";;
            --import=*) sudo $(type -P apt) apt import "${_a##*=}";;

            --*) >&2 echo "${FUNCNAME}: unknown switch ${_a}, stop processing switches"; break;;
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
        false && return $(u.error "${FUNCNAME}: ${FUNCNAME} cannot install '$@' on distro $(os.release ID)")
    fi
)
f.x binstall.distro


binstall.pip() (
    set -Eeuo pipefail; shopt -s nullglob
    u.have python -m pip list &> /dev/null || return $(u.error "python -m pip not working, stopping.")


    local _pkg='' _url=''
    declare -a _cmds=()
    for _a in "${@}"; do
        case "${_a}" in
            --pkg=*) _pkg="${_a##*=}";;
            --url=*) _url="${_a##*=}";;
            --cmd=*) _cmds+="${_a##*=}";;

            --*) >&2 echo "${FUNCNAME}: unknown switch ${_a}, stop processing switches"; break;;
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

            --*) >&2 echo "${FUNCNAME}: unknown switch ${_a}, stop processing switches"; break;;
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
        case "${_a}" in
            --pkg=*) _pkg="${_a##*=}";;
            --url=*) _url="${_a##*=}";;

            --*) >&2 echo "${FUNCNAME}: unknown switch ${_a}, stop processing switches"; break;;
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
    set -Eeuo pipefail; shopt -s nullglob
    # known flags with default values
    local -A _known=(
        [pkg]='' ## required
    )
    local _unknown=''

    for _a in "${@}"; do
        case "${_a}" in
            --) shift; break;;
            --*) [[ "${_a}" =~ ^--(([^=]+)?(=(.+))?)$ ]] || return $(u.error "${FUNCNAME} re failed")
                 local _key="${BASH_REMATCH[2]}" _value="${BASH_REMATCH[4]:-1}"
                 [[ -z "${_key}" && -n "${_value}" ]] && return $(u.error "${FUNCNAME} switch '${_a}' has no key")
                 [[ -v _known["${_key}"] ]] && _known["${_key}"]="${_value}" || _unknown+="${_a} ";;
            *) break;;
        esac
        shift
    done

    [[ -n "${_known[pkg]}" ]] || return $(u.error "${FUNCNAME} expecting --pkg=something")
    npm install -g npm
    npm install -g ${_known[pkg]} ${_unknown} $@
)
f.x binstall.npm


binstall.installer() (
    set -Eeuo pipefail
    binstall.installers ${1:?"${FUNCNAME} expecting a _pkg"}
)
f.x binstall.installer

binstall.mkbinstall() (
    set -Eeuo pipefail; shopt -s nullglob

    local _pkg='' _kind=tbs
    for _a in "${@}"; do
        case "${_a}" in
            --pkg=*) _pkg="${_a##*=}";;
            --kind=*) _kind="${_a##*=}";;

            --*) >&2 echo "${FUNCNAME}: unknown switch ${_a}, stop processing switches"; break;;
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



sourced || true

