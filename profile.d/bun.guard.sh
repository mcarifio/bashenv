bun.session() {
  local _tmp=$(mktemp -d)
  2>/dev/null bun completions ${_tmp}
  source ${_tmp}/*.$(u.shell) && rm -rf ${_tmp}
}
f.complete bun.session
bun.session
