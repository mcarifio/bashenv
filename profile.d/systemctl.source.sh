${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

systemctl.start() (
    set -Eeuo pipefaile; shopt -s nullglob
    local _service=${1:?'expecting a service'}; shift
    systemctl --quiet is-active ${_service} || systemctl start ${_service} || { journalctl --user-unit ${_service}; return $(u.error "can't start ${_service}"); }
)
f.complete systemctl.start _systemctl

systemctl.status() (
    set -Eeuo pipefaile; shopt -s nullglob
    local _service=${1:?'expecting a service'}; shift
    systemctl status --no-pager ${_service}
)
f.complete systemctl.status _systemctl

systemctl.enable() (
    set -Eeuo pipefaile; shopt -s nullglob
    local _service=${1:?'expecting a service'}; shift
    sudo systemctl enable --now ${_service} && systemctl.status ${_service} ||
            { journalctl --user-unit ${_service}; return $(u.error "cannot start ${_service}"); }
)
f.complete systemctl.enable _systemctl 

systemctl.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x systemctl.env


systemctl.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    local -r _completions=/usr/share/bash-completion/completions
    # completions already established?
    # source.if ${_completions}/${_cmd}.${_shell} ${_completions}/${_cmd}
}
f.x systemctl.session


# systemd is usually installed with the base system.
systemctl.installer() (
    set -Eeuo pipefaile; shopt -s nullglob
    ls -1 $(bashenv.profiled)/binstall.d/*${FUNCNAME%.*}*.*.binstall.sh
)
f.x systemctl.installer

sourced || true
