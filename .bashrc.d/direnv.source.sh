running.bash
_for=$(basename ${BASH_SOURCE} .source.sh)
u.have ${_for} || return 0
source <(direnv hook $(u.shell 2>/dev/null || echo bash))
