# source into bash, assumes asdf precedes other installation approaches.
# [commands](http://asdf-vm.com/manage/commands.html)
export ASDF_DATA_DIR=~/opt/asdf/current
[[ -d ${ASDF_DATA_DIR} ]] || return 0

. ${ASDF_DATA_DIR}/asdf.sh
. ${ASDF_DATA_DIR}/completions/asdf.bash

# is plugin
asdf.is-installed() {
    local _plugin=$1
    asdf current ${_plugin} &> /dev/null
}
f.complete asdf.is-installed


# For those plugins that support "auto install of packages" (and the environment variable is configured), you'll also
# get auto install of the packages

asdf.install-latest-enum() {
    for p in "$@"; do
	asdf install ${p} latest && asdf global ${p} latest
    done
    # hack, two different locations on PATH
    local _gopath=$(go env GOPATH)/bin
    [[ -d "${_gopath}" ]] && export PATH+=:${_gopath}
    # asdf.go-install
    asdf reshim
    hash -r
}
f.complete asdf.install-latest-enum

asdf.install-latest() { asdf.install-latest-enum $(asdf plugin-list); }
f.complete  asdf.install-latest

asdf.plugin+install() {
    local _pkg=${1:?'expecting a pkg'}
    local _from=${2:-}
    asdf plugin-add ${_pkg} ${_from}
    asdf install ${_pkg} latest
    asdf global ${_pkg} latest
    hash -r
}
f.complete asdf.plugin+install
# asdf.plugin+install chezmoi https://github.com/joke/asdf-chezmoi.git
# asdf.plugin+install cheat https://github.com/jmoratilla/asdf-cheat-plugin.git

# direnv
# if asdf.is-installed direnv ; then
#     source <(direnv hook bash)
# fi

# https://github.com/hensou/asdf-dotnet
# https://github.com/emersonsoares/asdf-dotnet-core/blob/master/README.md
if asdf.is-installed dotnet; then
    source ${ASDF_DATA_DIR}/plugins/dotnet-core/set-dotnet-home.bash
fi

# Don't install pypy using asdf, it breaks python itself. See ~/opt/pypy/current/bin/pypy.
# python3
if asdf.is-installed python; then
    # https://github.com/danhper/asdf-python/
    # asdf plugin add python
    export ASDF_PYTHON_DEFAULT_PACKAGES_FILE=${ASF_DATA_DIR}/.default-python-packages
fi

# pypoetry (independent of asdf python)
# if asdf.is-installed poetry ; then
#    source <(poetry completions bash)
# fi


# nodejs
if asdf.is-installed nodejs; then
    # https://github.com/asdf-vm/asdf-nodejs
    # asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
    export ASDF_NPM_DEFAULT_PACKAGES_FILE=${ASDF_DATA_DIR}/.default-npm-packages
    # note: on new version, after `asdf reshim nodejs`:
    # npm i -g $(tr '\n' ' ' < ${ASDF_NPM_DEFAULT_PACKAGES_FILE}
    # asdf reshim nodejs # again
fi


# go
if asdf.is-installed go; then
    # go bash completion?
    export PATH+=:$(go env GOPATH)/bin
    # see .default-golang-pkgs for go install ${pkg}@latest
    export ASDF_GOLANG_DEFAULT_PACKAGES_FILE=${ASDF_DATA_DIR}/.default-golang-pkgs
fi
asdf.go-install() { xargs -n1 -I% go install % < ${ASDF_GOLANG_DEFAULT_PACKAGES_FILE}; }
f.complete asdf.go-install

if asdf.is-installed yq ; then
    source <(yq shell-completion bash)
fi



if asdf.is-installed deno; then
    source <(deno completions bash)
    _v=$(asdf which deno)
    [[ -n "${_v}" ]] && export DENO_INSTALL_ROOT=${_v%%/bin/*}
    path.add ${DENO_INSTALL_ROOT}
    unset _v
fi


# haskell stack
if asdf.is-installed stack ; then
    source <(stack --bash-completion-script stack)
    export STACK_ROOT=${ASDF_DATA_DIR}/installs/stack/stack_root
    export PATH+=:${STACK_ROOT}/bin
    if [[ -r "${STACK_ROOT}/config.yaml" ]] ; then
      _local_bin_path="$(yq e .local-bin-path ${STACK_ROOT}/config.yaml)"
      [[ null != "${_local_bin_path}" ]] && export PATH+=:${_local_bin_path}
      unset _local_bin_path
    fi    
fi


if asdf.is-installed plz ; then
    source <(plz --completion_script)
fi
