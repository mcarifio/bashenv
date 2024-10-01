systemctl.start() (
    local _service=${1:?'expecting a service'}; shift
    systemctl --quiet is-active ${_service} || systemctl start ${_service} || { journalctl --user-unit ${_service}; return $(u.error "can't start ${_service}"); }
)
f.complete systemctl.start _systemctl

systemctl.status() (
    local _service=${1:?'expecting a service'}; shift
    systemctl status --no-pager ${_service}
)
f.complete systemctl.status _systemctl

systemctl.enable() (
    local _service=${1:?'expecting a service'}; shift
    sudo systemctl enable --now ${_service} && systemctl.status ${_service} ||
            { journalctl --user-unit ${_service}; return $(u.error "cannot start ${_service}"); }
)
f.complete systemctl.enable _systemctl 

systemctl.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x systemctl.env

loaded "${BASH_SOURCE}"
