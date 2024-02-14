# https://www.admin-magazine.com/HPC/Articles/pdsh-Parallel-Shell
# dnf install pdsh pdsh-rcmd-ssh pdsh-mod-dshgroup pdsh-mod-genders pdsh-mod-netgroup

type pdsh &> /dev/null || return 0
export PDSH_RCMD_TYPE=ssh
