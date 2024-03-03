systemctl() (
    : '$@ #> systemctl command with implied sudo'
    sudo command ${FUNCNAME} "$@"
)
# use systemctl's completion function (_systemctl). it's a complicated function.
f.complete systemctl

systemctl.start() (
    : ''
    local _service=${1:?'expecting a service'}; shift
    command systemctl --quiet is-active ${_service} || systemctl start ${_service} || { journalctl --user-unit ${_service}; return 0; }
)
f.complete systemctl.start


systemctl.env() {
    # echo ${FUNCNAME}
    return 0 
}
f.complete systemctl.env
