bun.session() {
  local _tmp=$(mktemp -d)
  2>/dev/null command bun completions ${_tmp}
  source ${_tmp}/*.$(u.shell) || u.error
  rm -rf ${_tmp} 
}
declare -fx bun.session
bun.session

