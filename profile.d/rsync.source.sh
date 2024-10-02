${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

rsync.local.target() (
    echo /run/media/${USER}${1:?'expecting a target'}
)
f.x rsync.local.target

rsync.local.root() (
    echo /run/media/${USER}/home
)
f.x rsync.local.root


rsync.eject() (
    sudo eject /run/media/${USER}/home
)
f.x rsync.eject

rsync.local() (
    local _from="$(realpath --logical --no-symlinks ${1:-${PWD}})"; shift
    local _to=$(${FUNCNAME}.target "${_from}")

    set -x
    command rsync --update --human-readable --itemize-changes --fsync --archive --verbose --partial \
            --progress --relative --backup --ignore-errors --links --mkpath --xattrs --times --hard-links --ignore-existing \
            "$@" "${_from}"/ "${_to}"
)
f.x rsync.local

rsync.home() (
    rsync.local "${HOME}" --exclude='/home/mcarifio/vmware/**' --exclude='/home/mcarifio/.local/share/containers/**' --exclude='/home/mcarifio/.cache'
)
f.x rsync.home

rsync.default() (
    : 'rsync with default flags' 
    command rsync --update --human-readable --itemize-changes --fsync --archive --verbose --partial --progress --relative --backup --ignore-errors --links  --mkpath --xattrs --times --hard-links "$@"
)
f.x rsync.default

sourced || true

