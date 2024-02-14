# source for bash only
realpath /proc/$$/exe | grep -Eq 'bash$' || return 0
# source only if rsync is available
type -p rsync &> /dev/null || return 0

rsync.local.target() ( echo /run/media/${USER}${1:?'expecting a target'}; ); declare -fx rsync.local.target
rsync.local.root() ( echo /run/media/${USER}/home; ); declare -fx rsync.local.root


rsync.eject() ( sudo eject /run/media/${USER}/home; ); declare -fx rsync.eject

rsync.local() (
    local _from="${1:-${PWD}}"; shift
    local _to=$(${FUNCNAME}.target "${_from}")

    set -x
    rsync -avz --relative --backup --ignore-errors "$@" "${_from}/" "${_to}"
); declare -fx rsync.local

rsync.home() (
    rsync.local "${HOME}" --exclude='/home/mcarifio/vmware/**' --exclude='/home/mcarifio/.local/share/containers/**' --exclude='/home/mcarifio/.cache'
); declare -fx rsync.home

