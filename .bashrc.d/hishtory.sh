[[ -n "${SUDO_USER}" ]] && return 0
export PATH="$(home)/.hishtory:${PATH}"
source $(home)/.hishtory/config.sh
