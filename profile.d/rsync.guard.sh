rsync.local.target() (
    echo /run/media/${USER}${1:?'expecting a target'}
)
f.complete rsync.local.target

rsync.local.root() (
    echo /run/media/${USER}/home
)
f.complete rsync.local.root


rsync.eject() (
    sudo eject /run/media/${USER}/home
)
f.complete rsync.eject

rsync.local() (
    local _from="$(realpath --logical --no-symlinks ${1:-${PWD}})"; shift
    local _to=$(${FUNCNAME}.target "${_from}")

    set -x
    command rsync --update --human-readable --itemize-changes --fsync --archive --verbose --partial \
            --progress --relative --backup --ignore-errors --links --mkpath --xattrs --times --hard-links --ignore-existing \
            "$@" "${_from}"/ "${_to}"
)
f.complete rsync.local

rsync.home() (
    rsync.local "${HOME}" --exclude='/home/mcarifio/vmware/**' --exclude='/home/mcarifio/.local/share/containers/**' --exclude='/home/mcarifio/.cache'
)
f.complete rsync.home

rsync.default() (
    : 'rsync with default flags' 
    command rsync --update --human-readable --itemize-changes --fsync --archive --verbose --partial --progress --relative --backup --ignore-errors --links  --mkpath --xattrs --times --hard-links "$@"
)
f.complete rsync.default

