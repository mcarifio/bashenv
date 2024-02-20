_tmp=$(mktemp -d)
2>/dev/null bun completions ${_tmp}
source ${_tmp}/*.$(u.shell)
rm -rf ${_tmp}
unset _tmp

