type -p direnv &> /dev/null || return 0
source <(direnv hook $(u.shell 2>/dev/null || echo bash))
