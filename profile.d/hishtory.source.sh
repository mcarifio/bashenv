[[ -z "${SUDO_USER}" ]] || return 0
[[ -r "$(home)/.hishtory/config.sh" ]] || return 0

path.add "$(home)/.hishtory"

hishtory.session() {
    source $(home)/.hishtory/config.sh
}
f.complete hishtory.session
hishtory.session

