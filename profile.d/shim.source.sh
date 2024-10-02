_shim() (
    local _from=${1:-'expecting a folder'}
    local _to=${2:-${HOME}}
    find "${_from}" -type f -exec echo ${_to}/$(realpath  --relative-to=${_from} --strip {}) \;
)
f.x _shim

sourced || true

