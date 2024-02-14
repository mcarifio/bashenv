type podman &> /dev/null || return 0

[[ -f /sys/fs/cgroup/cgroup.controllers ]] || >&2 echo "/sys/fs/cgroup/cgroup.controllers not found. cgroups version 1?"
alias docker=podman


