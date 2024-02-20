rsync.local.target() ( echo /run/media/${USER}${1:?'expecting a target'}; ); declare -fx rsync.local.target
rsync.local.root() ( echo /run/media/${USER}/home; ); declare -fx rsync.local.root


rsync.eject() ( sudo eject /run/media/${USER}/home; ); declare -fx rsync.eject

rsync.local() (
    local _from="$(realpath --logical --no-symlinks ${1:-${PWD}})"; shift
    local _to=$(${FUNCNAME}.target "${_from}")

    set -x
    rsync --archive --verbose --partial --progress --relative --backup --ignore-errors --links --checksum --mkpath --xattrs --times --hard-links "$@" "${_from}"/ "${_to}"
); declare -fx rsync.local

rsync.home() (
    rsync.local "${HOME}" --exclude='/home/mcarifio/vmware/**' --exclude='/home/mcarifio/.local/share/containers/**' --exclude='/home/mcarifio/.cache'
); declare -fx rsync.home

