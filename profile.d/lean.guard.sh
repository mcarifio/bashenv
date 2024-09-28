[[ -d "${HOME}/.elan/bin" ]] || return 0
_guard=$(path.basename.part ${BASH_SOURCE} 0); trap 'unset _guard' RETURN
path.add "${HOME}/.elan/bin"
source <(elan completions $(u.shell))
sourced

