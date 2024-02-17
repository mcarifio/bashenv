running.bash && u.have $(basename ${BASH_SOURCE} .sh) || return 0

[[ -f /sys/fs/cgroup/cgroup.controllers ]] || >&2 echo "/sys/fs/cgroup/cgroup.controllers not found. cgroups version 1?"
alias docker=podman


