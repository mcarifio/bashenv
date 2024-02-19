source.guard $(basename ${BASH_SOURCE%%.*}) || return 0
source <(poetry completions $(u.shell 2>/dev/null || echo bash))

