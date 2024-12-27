${1:-false} || [[ -r /etc/os-release ]] || return 0

# better than lsb_release
# All variables in /etc/os-release can be printed
name2env() {
    local _result=${1:?'expecting a name'}
    # _result=${_result##*.}
    echo ${_result^^}
}
f.x name2env

os-release() (
    local _name=$(name2env ${1:?'expecting a name in /etc/os-release'})
    source /etc/os-release
    if [[ -n "${!_name}" ]] ; then
        echo ${!_name}
    else
        >&2 echo "${_name} not in /etc/os-release"
        return 1
    fi    
)
f.x os-release

os-release.version_id() (
    os-release $(name2env ${FUNCNAME##*.})
)
f.x os-release.version_id

os-release.id() (
    os-release $(name2env ${FUNCNAME##*.})
)
f.x os-release.id

os-release.version_codename() (
    os-release $(name2env ${FUNCNAME##*.})
)
f.x os-release.version_codename

os-release.major() {
    local _major=$(os-release.version_id)
    echo -n ${_major%.*}
}
f.x os-release.major

os-release.name-version() (
    printf "%s-%s" $(os-release.id) $(os-release.version_id)
)
f.x os-release.name-version

os.release() (
    local _name=${1:-PRETTY_NAME}
    source /etc/os-release
    [[ -n "${!_name}" ]] && echo ${!_name} || >&2 echo "${_name} not in /etc/os-release"
)
f.x os.release

sourced || true

