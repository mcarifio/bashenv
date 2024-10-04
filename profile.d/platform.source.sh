${1:-false} || u.have.all shutdown reboot || return 0

platform.upgrade() (
    set -Eeuo pipefail

    local -i _shutdown=0 _reboot=0

    local -i _dnf=1 _snap=0 _cargo=0 _brew=0 _flatpak=0
    if (( ${#@} )) ; then
        for _a in "${@}"; do
            case "${_a}" in
                --nodnf) _dnf=0;;
                --dnf) _dnf=1;;
                --nosnap) _snap=0;;
                --snap) _snap=1;;
                --nocargo) _cargo=0;;
                --cargo) _cargo=1;;
                --nobrew) _brew=0;;
                --brew) _brew=1;;
                --noflatpak) _flatpak=0;;
                --flatpak) _flatpak=1;;

		--shutdown) _shutdown=1; _reboot=0;;
                --reboot) _reboot=1; _shutdown=0;;
                
                --) shift; break;;
                # --*) break;; ## break on unknown switch, pass it along
                # --*) >&2 echo "${FUNCNAME}: unknown switch ${_a}, stop processing switches"; break;;
                --*) return $(u.error "${FUNCNAME} unknown switch '${_a}', stopping");; ## error on unknown switch
                *) break;;
            esac
            shift
        done
    fi


    # rpm-ostree | dnf upgrade first, might effect what's above it.
    (( _dnf )) && sudo $(type -P rpm-ostree) upgrade 2>/dev/null || dnf upgrade --allowerasing

    # TODO mike@carif.io: how to upgrade jetbrains via their toolbox without human intervention?
    local _jetbrains_toolbox="${HOME}/.local/share/JetBrains/Toolbox/bin/jetbrains-toolbox"
    [[ -x "${_jetbrains_toolbox}" ]] && >&2 echo "${_jetbrains_toolbox} upgrade # tbs"

    (( _snap )) && u.have snap && snap refresh
    (( _cargo )) && u.have cargo && cargo.update.all
    (( _brew )) && u.have brew && brew update -y
    (( _flatpak )) && u.have flatpak && flatpak upgrade -y
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

