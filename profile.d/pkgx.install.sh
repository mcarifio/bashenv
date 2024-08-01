#!/usr/bin/env bash
set -Eeuo pipefail

# ${guard}.install.sh will install ${guard} in various ways. You'll choose and
# then customize the one you want, typically by modifying `install()` to call
# the right helper function, e.g. `glab.install.sh` calls bash function `install()`
# which calls `install.asdf()`. It's a little crufty with all the boilerplate,
# but the script and functions are short.

# install {_template,${guard}}.install.sh

source $(u.here)/install.lib.sh


install.curl() (
    set -Eeuo pipefail
    local _name="${1:?'expecting a name'}"
    local _url="${2:?'expecting a url'}"
    local _suffix=${_url##*.}
    local _dir=${3:-~/.local/bin}
    # local _tmp=$(mktemp --suffix=.${_suffix})
    local _target="${_dir}/${_name}"
    # https://docs.pkgx.sh/run-anywhere/terminals
    curl -Ssf ${_url} | tar xz -C /tmp
    command install /tmp/${_name} "${_target}"
    >&2 echo "installed '${_target}' from '${_url}'"
)    


# install() ( install.$(os.release ID) "$@"; )
install() (
    install.curl "$@"
    install.check "$1"
    pkgx install mash
)

# install "$@"
# install $(path.basename ${BASH_SOURCE}) "$@"
install $(path.basename ${BASH_SOURCE}) https://pkgx.sh/$(uname)/$(uname -m).tgz "$@"

