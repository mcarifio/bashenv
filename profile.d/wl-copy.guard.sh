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

loaded "${BASH_SOURCE}"


