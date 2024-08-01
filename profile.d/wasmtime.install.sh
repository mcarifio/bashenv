#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/install.lib.sh

# install via cargo fails
install0() (
    set -Eeuo pipefail
    install.cargo wasmer-cli --features singlepass,cranelift
    install.check wasmer
)

# cut-and-paste install.curl()
install.curl-tar() (
    set -Eeuo pipefail
    local _name="${1:?'expecting a name'}"
    local _url="${2:?'expecting a url'}"
    local _suffix=${_url##*.tar.}
    local _dir=${3:-~/.local/bin}
    curl -SsfLJ --show-error "${_url}" | tar x --${_suffix} -C /tmp
    local _target="${_dir}/${_name}"
    # brittle, depends on how wasmtime is tarred
    local _cmd=/tmp/$(basename ${_url} .tar.${_suffix})/${_name}
    command install  "${_cmd}" "${_target}"
    rm -rf /tmp/$(basename ${_url} .tar.${_suffix})
    >&2 echo "installed '${_target}' from '${_url}'"

    install.check ${_name}
)


install.curl-tar wasmtime https://github.com/bytecodealliance/wasmtime/releases/download/v23.0.1/wasmtime-v23.0.1-x86_64-linux.tar.xz

