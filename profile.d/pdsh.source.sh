# https://www.admin-magazine.com/HPC/Articles/pdsh-Parallel-Shell
# dnf install pdsh pdsh-rcmd-ssh pdsh-mod-dshgroup pdsh-mod-genders pdsh-mod-netgroup

pdsh.env() {
    export PDSH_RCMD_TYPE=ssh
}
f.x pdsh.env

pdsh.session() {
    :
}
f.x pdsh


sourced || true

