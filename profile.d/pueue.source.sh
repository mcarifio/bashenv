${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

pueue.session() {
    &> /dev/null systemctl --user is-active pueued.service || systemctl --user enable --now pueued || { >&2 echo "pueued not active and could not be enabled"; return 0; }
    local _tmp=$(mktemp --directory /tmp/${USER}-pueue-completions-XXXXX)
    local _shell=$(u.shell)
    pueue completions ${_shell} ${_tmp}
    source ${_tmp}/pueue.${_shell}
    rm -rf ${_tmp}
}
f.x pueue.session

sourced || true

