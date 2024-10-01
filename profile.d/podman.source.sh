${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

[[ -f /sys/fs/cgroup/cgroup.controllers ]] || >&2 echo "/sys/fs/cgroup/cgroup.controllers not found. cgroups version 1? affects podman"

podman.remove.images() (
    podman rmi -f $(podmaqn images -f "dangling=true" -q)
)
f.x podman.remove.images

podman.env() (
    : 'alias podman as docker with a pathname sym link. works for immutable systems like nixos as well'
    set -Eeuo pipefail
    local _podman=$(type -p podman)
    local _docker="${HOME}/.local/bin/docker"
    # ln -srf "${_podman}" "${_docker}" || return $(u.error "cannot alias '${_docker}' as '${_podman}'")
)
f.x podman.env

sourced || true





