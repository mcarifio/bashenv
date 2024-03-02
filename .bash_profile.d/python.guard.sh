path.frontier.dir() (
    local _root=${1:-${PWD}}
    cat <<- EOF | forward.py /dev/stdin "${_root}"
import os
for root, dirs, files in os.walk('${_root}'):
  if not dirs:
    print(os.path.abspath(root))
EOF
)
f.complete path.frontier.dir
