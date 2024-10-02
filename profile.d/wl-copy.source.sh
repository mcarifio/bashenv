${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

cb.cp() (
    : '# copy /dev/stdin to clipboard under wayland'
    wl-copy -n
)
f.complete cb.cp

cb.pn() (
    : '${pathname} # copy pathname to clipboard'
    path.pn ${1:?'expecting a pathname'} | cb.cp
)
f.complete cb.pn

sourced || true
