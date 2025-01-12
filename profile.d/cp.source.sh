${1:-false} || u.have $(path.basename.part ${BASH_SOURCE} 0) || return 0

# --reflink takes advantage of CoW filesystems like btrfs
cp() ( command ${FUNCNAME} --reflink=auto --backup=numbered "$@"; )
f.x cp

sourced || true
