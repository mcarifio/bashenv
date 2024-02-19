source.guard $(path.basename ${BASH_SOURCE}) || return 0
_tmp=$(mktemp -d)
bun completions ${_tmp}
source ${_tmp}/*.$(u.shell)
rm -rf ${_tmp}
unset _tmp

