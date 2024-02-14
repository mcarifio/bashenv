realpath /proc/$$/exe | grep -Eq 'bash$' || return 0  ## shell must be bash
type go &> /dev/null || return 0  ## go must be installed

go.path() (
    : 'go.path |> current path for go binaries iff the folder exists'
    local _gopath=$(go env GOPATH)
    if [[ -n "${_gopath}" ]] ; then
        local _gopath_bin=${_gopath}/bin
        # [[ -d "${_gopath_bin}" ]] && export PATH+=:${_gopath_bin}
        [[ -d "${_gopath_bin}" ]] && echo ${_gopath_bin}
    fi
); declare -fx go.path

# assume path.sh sourced
path.add $(go.path)


