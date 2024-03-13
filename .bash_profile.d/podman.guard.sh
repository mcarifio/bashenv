[[ -f /sys/fs/cgroup/cgroup.controllers ]] || >&2 echo "/sys/fs/cgroup/cgroup.controllers not found. cgroups version 1? affects podman"
# alias docker=podman
podman.remove-images() (
    podman rmi -f $(docker images -f "dangling=true" -q)
)
f.complete podman.remove-images

docker() (
    command podman "$@"
)
f.complete docker



