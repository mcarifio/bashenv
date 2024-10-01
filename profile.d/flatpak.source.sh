${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

flatpak.wrap() {
    : '# wrap each flatpak app with a bash function fp.${id} to simplify invocation. `fp.` prefix assists bash completion'
    local -A _defined=()
    for _id in $(flatpak list --app --columns=application); do
        local _command=${_id##*.}; _command=${_command,,}
        if (( _defined[${_command}] )); then
            echo >&2 "${_command} already defined, skipping..."
        else
            eval "fp.${_command}()(flatpak run ${_id} \"\$@\";)"
            f.x fp.${_command}
            _defined[${_command}]=1
        fi        
    done    
}
f.x flatpak.wrap
flatpak.wrap


flatpak.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x flatpak.env

flatpak.session() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x flatpak.session

sourced || true

