${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

cb.cp() (
    : '# copy /dev/stdin to clipboard under wayland'
    set -Eeuo pipefaile; shopt -s nullglob
    wl-copy -n
)
f.x cb.cp

cb.pn() (
    : '${pathname} # copy pathname to clipboard'
    set -Eeuo pipefaile; shopt -s nullglob
    path.pn ${1:?'expecting a pathname'} | cb.cp
)
f.x cb.pn

sourced || true
