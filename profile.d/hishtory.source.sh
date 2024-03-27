[[ -z "${SUDO_USER}" ]] || return 0
[[ -r "$(home)/.hishtory/config.sh" ]] || return 0

path.add "$(home)/.hishtory"

hishtory.session() {
    source $(home)/.hishtory/config.sh
}
f.x hishtory.session
hishtory.session

loaded "${BASH_SOURCE}"
