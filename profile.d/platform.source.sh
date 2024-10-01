${1:-false} || u.have.all shutdown reboot || return 0

platform.upgrade() (
    set -Eeuo pipefail

    local -i _shutdown=0 _reboot=0
    
    if (( ${#@} )) ; then
        for _a in "${@}"; do
            case "${_a}" in
		--shutdown) _shutdown=1;;
                --reboot) _reboot=1;;
                --) shift; break;;
                *) break;;
            esac
            shift
        done
    fi


    # rpm-ostree | dnf upgrade first, might effect what's above it.
    sudo $(type -P rpm-ostree) upgrade 2>/dev/null || dnf upgrade --allowerasing

    # TODO mike@carif.io: how to upgrade jetbrains via their toolbox without human intervention?
    local _jetbrains_toolbox="${HOME}/.local/share/JetBrains/Toolbox/bin/jetbrains-toolbox"
    [[ -x "${_jetbrains_toolbox}" ]] && >&2 echo "${_jetbrains_toolbox} upgrade # tbs"

    u.have snap && snap refresh
    u.have cargo && cargo.update.all
    u.have brew && brew update -y
    u.have flatpak && flatpak upgrade -y
    # u.have asdf && type asdf.platform-update &> /dev/null && asdf.platform-update

    (( _shutdown )) && sudo shutdown -h now
    (( _reboot )) && sudo reboot
)
f.x platform.upgrade

platform.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x platform.env

platform.session() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x platform.session

sourced || true

