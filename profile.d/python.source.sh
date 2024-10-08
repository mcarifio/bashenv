${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

path.frontier.dir() (
    local _root=${1:-${PWD}}
    cat <<- EOF | forward.py /dev/stdin "${_root}"
import os
for root, dirs, files in os.walk('${_root}'):
  if not dirs:
    print(os.path.abspath(root))
EOF
)
f.x path.frontier.dir

pyz() {
    : '${url.zip} # download a python zip file and run it. something like pipx'
    local -r _url=${1:?'expecting a url'} ; shift
    wget ${_url} || return 1
    local -r _pyz=$(basename ${_url})
    python ${_pyz} "$@"
}
f.x pyz

# see binstall.pip
python.pip() (
    python -m pip install -U pip
    python -m pip install -U "$@"
)
f.x python.pip

sourced || true



    
