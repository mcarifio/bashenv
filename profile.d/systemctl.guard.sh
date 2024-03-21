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
f.x systemctl.env
