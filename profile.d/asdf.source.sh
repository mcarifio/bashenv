# https://asdf-vm.com/guide/upgrading-to-v0-16
path.add ${HOME}/opt/asdf/current/bin
${1:-false} || u.have asdf || return 0
export ASDF_DATA_DIR="$(dirname $(dirname $(which asdf)))"
path.add ${ASDF_DATA_DIR}/shims
ASDF_CONFIG_FILE=${HOME}/.config/asdf/asdfrc


# is plugin
asdf.plugin.have() (
    set -eu
    asdf plugin list | command grep --quiet -e "^${1:?'expecting a plugin'}\$" &> /dev/null
)
f.x asdf.plugin.have


asdf.plugin.add() (
    : '${_plugin} [${_from}] # add an asdf plugin from an optional url'
    set -eu; shopt -s nullglob
    local _pkg=${1:?'expecting a plugin'}
    local _from=${2:-}
    asdf plugin add ${_pkg} ${_from}
)
f.x asdf.plugin.add


# asdf.starred() (
#     set -euo pipefail
#     local _pkg=${1:?'expecting a pkg'}
#     asdf list ${_pkg} | grep -E ^[[:space:]]\\*\+[[:digit:]]\+\.[[:digit:]]\+\.[[:digit:]] | tr -d ' *' || echo "${FUNCNAME} failed" >&2
# )
# f.x asdf.latest-version

asdf.latest-installed() (
    set -euo pipefail
    local _pkg=${1:?'expecting a pkg'}
    asdf list ${_pkg} | sed 's/^[* ]*//' | grep -v '^system$' | sort -V | tail -1
)
f.x asdf.latest-version

asdf.install() (
    : '[--url=${_plugin_url}] ${_plugin} ${_version} ## install ${_plugin} ${_verision} from ${_url}'
    set -euo pipefail

    for _a in "${@}"; do
        local _v="${_a##*=}"
        case "${_a}" in
	    --url=*) local _url="${_a##*=}"
                     local _plugin=$(path.basename "${_url}")
                     _plugin=${_plugin/asdf-/}
                     asdf plugin add "${_plugin}" "${_url}";;
            --) shift; break;;
            *) break;;
        esac
        shift
    done
    
    local _pkg=${1:-${_plugin:?'expecting a package'}}
    local _version=${2:-latest}
    asdf install ${_pkg} ${_version}
    asdf.set ${_pkg}
)
f.x asdf.install

asdf.set() (
    set -euo pipefail
    local _pkg=${1:?'expecting a pkg'}
    local _version=$(asdf.latest-installed ${_pkg})
    asdf set -u ${_pkg} ${_version}
    asdf reshim ${_pkg}
    asdf which ${_pkg}
    hash -r ${_pkg}
    which ${_pkg}
)


asdf.remove.past() (
    : '${_plugin}* # remove older versions for each ${_plugin}, $(asdf plugin list) for all installed plugins'
    set -Eeuo pipefail
    for _plugin in "$@"; do
        >&2 echo -n "${FUNCNAME} ${_plugin} ... "
        for _v in $(asdf list ${_plugin}|head -n-1); do asdf uninstall ${_plugin} ${_v}; done
        (( $? )) && >&2 echo "failed." || >&2 echo "succeeded."
    done    
)
f.x asdf.remove.past

# asdf.plugin.add chezmoi https://github.com/joke/asdf-chezmoi.git
# asdf.plugin.add cheat https://github.com/jmoratilla/asdf-cheat-plugin.git

# Don't install pypy using asdf, it breaks python itself. See ~/opt/pypy/current/bin/pypy.
# python3
if asdf.plugin.have python; then
    # https://github.com/danhper/asdf-python/
    # asdf plugin add python
    export ASDF_PYTHON_DEFAULT_PACKAGES_FILE=${ASF_DATA_DIR}/.default-python-packages
    path.add $(asdf where python)/bin
fi

# nodejs
if asdf.plugin.have nodejs; then
    # https://github.com/asdf-vm/asdf-nodejs
    # asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
    export ASDF_NPM_DEFAULT_PACKAGES_FILE=${ASDF_DATA_DIR}/.default-npm-packages
    # note: on new version, after `asdf reshim nodejs`:
    # npm i -g $(tr '\n' ' ' < ${ASDF_NPM_DEFAULT_PACKAGES_FILE}
    # asdf reshim nodejs # again
    path.add $(asdf where nodejs)/bin

fi


# go
if asdf.plugin.have golang; then
    # go bash completion?
    # export PATH+=:$(go env GOPATH)/bin
    # path.add $(go env GOPATH)/bin
    export GOBIN=${HOME}/.local/bin
    # see .default-golang-pkgs for go install ${pkg}@latest
    export ASDF_GOLANG_DEFAULT_PACKAGES_FILE=${ASDF_DATA_DIR}/.default-golang-pkgs
    asdf.go-install() {
        for _p in $(< ${ASDF_GOLANG_DEFAULT_PACKAGES_FILE}); do
            GOBIN=${1:-${GOBIN:?'expecting env GOBIN'}} go install ${_p}
        done
    }
    f.x asdf.go-install
fi


if asdf.plugin.have yq ; then
    yq.session() { source <(yq shell-completion bash) || return $(u.error "${FUNCNAME} failed"); }
    f.xx yq.session
    yq.session
fi



if asdf.plugin.have deno; then
    path.add $(asdf where deno)/bin
    deno.session() { source <(deno completions bash) || return $(u.error "${FUNCNAME} failed"); }
    declare -fx deno.session
    deno.session
fi


if asdf.plugin.have plz ; then
    plz.session() { source <(plz --completion_script) || return $(u.error "${FUNCNAME} failed"); }
    declare -fx plz.session
    plz.session
fi

asdf.session() {
    source <(asdf completion $(u.shell))
}
f.x asdf.session
asdf.session


asdf.platform-update() {
    asdf update
    asdf plugin update --all
    for _pkg in $(cut -f1 -d ' ' ~/.tool-versions); do
        asdf.install ${_pkg} || true 
    done
}
f.x asdf.platform-update

asdf.plugin.urls() (
    set -Eeuo pipefail
    for _g in $(find ${ASDF_DIR}/plugins -name \.git -type d); do
        git -C $_g remote get-url origin
    done
)
f.x asdf.plugin.urls

asdf.install.all() (
    set -Eeuo pipefail
    for _url in "$@"; do
        local _pkg=$(path.basename ${_url##*/asdf-})
        asdf plugin add ${_pkg} ${_url}
        asdf.install ${_pkg}
    done    
)
f.x asdf.install.all

sourced || true


