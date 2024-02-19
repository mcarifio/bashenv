source.guard $(basename ${BASH_SOURCE%%.*}) || return 0
source <(gh completion -s $(u.shell 2>/dev/null || echo bash))
