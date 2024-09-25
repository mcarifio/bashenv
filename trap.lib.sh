on.EXIT.cleanup() ( : ; )

on.EXIT() (
    local -ir _status=$?
    set -Eeuo pipefail; shopt -s nullglob
    f.exists ${FUNCNAME}.cleanup && ${FUNCNAME}.cleanup "$@"
)
trap on.EXIT EXIT

on.ERR() (
    local -ir _status=$?
    set -Eeuo pipefail; shopt -s nullglob
    (( _status )) && printf '%s => %i\n' ${_status} $(u.self)
)
trap on.ERR ERR



