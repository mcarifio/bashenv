# guard isn't sufficient here?
[[ -r ~/opt/asdf/current/asdf.sh ]] || return 0
export ASDF_DATA_DIR=~/opt/asdf/current
source ${ASDF_DATA_DIR}/asdf.sh

# is plugin
function asdf.plugin.have (
    asdf plugin-list | grep --quiet -e "^${1:?'expecting a plugin'}\$" &> /dev/null
)
declare -fx asdf.plugin.have


asdf.plugin.add() (
    local _pkg=${1:?'expecting a plugin'}
    local _from=${2:-}
    asdf plugin-add ${_pkg} ${_from}
)
declare -fx asdf.plugin.add

asdf.install() (
    local _pkg=${1:?'expecting a pkg'}
    local _version=${2:-latest}
    asdf install ${_pkg} ${_version}
    asdf global ${_pkg} ${_version}
    asdf reshim ${_pkg}
    hash -r ${_pkg}
)
declare -fx asdf.install

asdf.remove.past() (
    local _pkg=${1:?'expecting a pkg'}
    for v in $(asdf list ${_pkg}|head -n-1); do asdf uninstall ${_pkg} $v; done
)
declare -fx asdf.remove.past

# asdf.plugin-add chezmoi https://github.com/joke/asdf-chezmoi.git
# asdf.plugin-add cheat https://github.com/jmoratilla/asdf-cheat-plugin.git

# Don't install pypy using asdf, it breaks python itself. See ~/opt/pypy/current/bin/pypy.
# python3
if asdf.plugin.have python; then
    # https://github.com/danhper/asdf-python/
    # asdf plugin add python
    export ASDF_PYTHON_DEFAULT_PACKAGES_FILE=${ASF_DATA_DIR}/.default-python-packages
fi

# pypoetry (independent of asdf python)
# if asdf.installed? poetry ; then
#    source <(poetry completions bash)
# fi


# nodejs
if asdf.plugin.have nodejs; then
    # https://github.com/asdf-vm/asdf-nodejs
    # asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
    export ASDF_NPM_DEFAULT_PACKAGES_FILE=${ASDF_DATA_DIR}/.default-npm-packages
    # note: on new version, after `asdf reshim nodejs`:
    # npm i -g $(tr '\n' ' ' < ${ASDF_NPM_DEFAULT_PACKAGES_FILE}
    # asdf reshim nodejs # again
fi


# go
if asdf.plugin.have go; then
    # go bash completion?
    export PATH+=:$(go env GOPATH)/bin
    # see .default-golang-pkgs for go install ${pkg}@latest
    export ASDF_GOLANG_DEFAULT_PACKAGES_FILE=${ASDF_DATA_DIR}/.default-golang-pkgs
fi

asdf.go-install() { xargs -n1 -I% go install % < ${ASDF_GOLANG_DEFAULT_PACKAGES_FILE}; }
f.complete asdf.go-install

if asdf.plugin.have yq ; then
    yq.session() { source <(yq shell-completion bash); }
    declare -fx yq.session
    yq.session
fi



if asdf.plugin.have deno; then
    path.add $(asdf where deno)/bin
    deno.session() { source <(deno completions bash); }
    declare -fx deno.session
    deno.session
fi


if asdf.plugin.have plz ; then
    plz.session() { source <(plz --completion_script); }
    declare -fx plz.session
    plz.session
fi

asdf.session() {
    local _asdf_bash=${ASDF_DATA_DIR:-~/opt/asdf/current}/completions/asdf.bash
    [[ -r "${_asdf_bash}" ]] && source "${_asdf_bash}"
}
declare -fx asdf.session
asdf.session

asdf.platform-update() {
    asdf update
    asdf plugin update --all
    for _pkg in $(cut -f1 -d ' ' ~/.tool-versions); do
        asdf.install ${_pkg} || true 
    done
}
f.complete asdf.platform-update


