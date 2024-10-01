${1:-false} || [[ -r ${ASDF_DIR:-${HOME}/opt/asdf/current}/asdf.sh ]] || return 0
export ASDF_DATA_DIR=${HOME}/opt/asdf/current
source ${ASDF_DATA_DIR}/asdf.sh

# is plugin
asdf.plugin.have() (
    set -Eeuo pipefail
    asdf plugin-list | command grep --quiet -e "^${1:?'expecting a plugin'}\$" &> /dev/null
)
f.x asdf.plugin.have


asdf.plugin.add() (
    : ''
    set -Eeuo pipefail
    local _pkg=${1:?'expecting a plugin'}
    local _from=${2:-}
    asdf plugin-add ${_pkg} ${_from}
)
f.x asdf.plugin.add

asdf.install() (
    : '[--url=${_plugin_url}] ${_plugin} ${_version} ## install ${_plugin} ${_verision} from ${_url}'
    set -Eeuo pipefail

    for _a in "${@}"; do
        case "${_a}" in
	    --url=*) local _url="${_a##*=}"
                     local _plugin=$(path.basename "${_url}")
                     _plugin=${_plugin/asdf-/}
                     asdf plugin-add "${_plugin}" "${_url}";;
            --) shift; break;;
            *) break;;
        esac
        shift
    done
    
    local _pkg=${1:-${_plugin:?'expecting a package'}}
    local _version=${2:-latest}
    asdf install ${_pkg} ${_version}
    asdf global ${_pkg} ${_version}
    asdf reshim ${_pkg}
    hash -r ${_pkg}
)
f.x asdf.install

asdf.remove.past() (
    set -Eeuo pipefail
    local _pkg=${1:?'expecting a pkg'}
    for v in $(asdf list ${_pkg}|head -n-1); do asdf uninstall ${_pkg} $v; done
)
f.x asdf.remove.past

# asdf.plugin-add chezmoi https://github.com/joke/asdf-chezmoi.git
# asdf.plugin-add cheat https://github.com/jmoratilla/asdf-cheat-plugin.git

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
    local _asdf_bash=${ASDF_DATA_DIR:-~/opt/asdf/current}/completions/asdf.bash
    [[ -r "${_asdf_bash}" ]] && source "${_asdf_bash}" || return $(u.error "${FUNCNAME} failed")
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
f.complete asdf.platform-update

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
        asdf plugin-add ${_pkg} ${_url}
        asdf install ${_pkg} latest && asdf global ${_pkg} latest
    done    
)
f.x asdf.install.all

sourced

