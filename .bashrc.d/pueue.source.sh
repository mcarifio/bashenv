# github https://github.com/Nukesor/pueue
# wiki 
# install https://copr.fedorainfracloud.org/coprs/gourlaysama/pueue/

running.bash
has pueue

>& /dev/null systemctl --user is-active pueued.service || systemctl --user enable --now pueued || { >&2 echo "pueued not active and could not be enabled"; return 0; }

pueue.completions() {
    local _tmp=$(mktemp --directory /tmp/${USER}-pueue-completions-XXXXX)
    local _shell=$(u.shell)
    pueue completions ${_shell} ${_tmp}
    source ${_tmp}/pueue.${_shell}    
}


pueue.completions



