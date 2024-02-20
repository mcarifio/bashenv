[[ -f /sys/fs/cgroup/cgroup.controllers ]] || >&2 echo "/sys/fs/cgroup/cgroup.controllers not found. cgroups version 1? affects podman"
# alias docker=podman


