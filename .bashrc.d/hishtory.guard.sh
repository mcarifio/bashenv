[[ -z "${SUDO_USER}" ]] || return 0
source $(home)/.hishtory/config.sh
path.add "$(home)/.hishtory"
