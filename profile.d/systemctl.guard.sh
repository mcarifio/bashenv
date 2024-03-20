systemctl() (
    : '$@ #> systemctl command with implied sudo'
    # Not yet clear to me which commands require root.
    command ${FUNCNAME} "$@" || sudo $(which ${FUNCNAME}) "$@"
)
# use systemctl's completion function (_systemctl). it's a complicated function.
f.complete systemctl _systemctl

systemctl.start() (
    : ''
    local _service=${1:?'expecting a service'}; shift
    systemctl --quiet is-active ${_service} || systemctl start ${_service} || { journalctl --user-unit ${_service}; return 0; }
)
f.complete systemctl.start _systemctl


systemctl.env() {
    # echo ${FUNCNAME}
    return 0 
}
declare -fx systemctl.env
