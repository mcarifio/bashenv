${1:-u.have} $(path.basename.part ${BASH_SOURCE} 0) || return 0
_guard=$(path.basename.part ${BASH_SOURCE} 0); trap 'unset _guard' RETURN

echo "${BASH_SOURCE}"

sourced
