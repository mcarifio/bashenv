${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

atuin.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x atuin.env

# requires https://github.com/akinomyoga/ble.sh placed in to ~/bashenv/ble.lib.sh
# note: `atuin import bash` will populate atuin's db
atuin.session() {
    [[ -n "$SSH_CLIENT" ]] && return 0
    # [[ -f /usr/share/bash-prexec ]] && source /usr/share/bash-prexec
    source <(atuin init $(u.shell)) || return $(u.error "${FUNCNAME} failed")
    source <(atuin gen-completions --shell $(u.shell)) || return $(u.error "${FUNCNAME} failed")
}
f.x atuin.session

sourced
