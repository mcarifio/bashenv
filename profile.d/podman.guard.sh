[[ -f /sys/fs/cgroup/cgroup.controllers ]] || >&2 echo "/sys/fs/cgroup/cgroup.controllers not found. cgroups version 1? affects podman"
# alias docker=podman
podman.remove-images() (
    podman rmi -f $(podmaqn images -f "dangling=true" -q)
)
f.complete podman.remove-images

podman.env() (
    # use podman as docker, all users
    [[ -x /usr/bin/podman && ! -f /usr/bin/docker ]] && sudo ln -sr /usr/bin/{podman,docker} || true
)
declare -fx podman.env




