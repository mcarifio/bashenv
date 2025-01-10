#!/usr/bin/env bash
set -Eeuo pipefail; shopt -s nullglob
source $(u.here)/$(path.basename.part $0 2).lib.sh


sudo.udisk2.config() (
    cat <<EOF | sudo tee -a /etc/udisks2/udisks2.conf
# mike@carif.io: make fedora and ubuntu consistent by adopting fedora's mountpoint convention
# check: udisksctl status ## get list of usb mounted disks with device names, e.g. nvme0n1 or sde
# lsblk ${_device}
[Mount]
MountPoints=/run/media/%u
EOF
)


sudo.nopasswd() (
    # no password prompt for sudo
    # are you in sudo group?
    local _nopasswd=/etc/sudoers.d/nopasswd
    [[ -f "${_nopasswd}" ]] || { >&2 echo "'${_nopasswd}' already exists"; return 0; }
    for _g in $@; do
        echo "%${_g}	ALL=(ALL)	NOPASSWD: ALL"
    done | sudo install --mode=0600 - ${_nopasswd}
    >&2 echo "sudo id ## no prompt"
    sudo id
)


main() (
    local -i _doctor=0 ## --doctor
    local _user=${USER}
    local _id=$(os-release.id)
    local _from='' ## --from=${_pathname}
    local _to="${HOME}" ## --to=${_pathname}
    local -a _parts=() ## --part={_directory_suffix}
    
    for _a in "${@}"; do
        local _k="${_a%%=*}"
        local _v="${_a##*=}"
        case "${_a}" in
            # switches
            --doctor) _doctor=1;;
            --user=*) _user="${_v}";; ## unnecessary b/c of --to=*?
            --from=*) _from="${_v}";;
            --to=*) _to="${_v}";;
            --part=*) _parts+=( "${_v}" );;
            # switch processing
            --) shift; break;; ## explicit stop
            # --*) >&2 echo "${FUNCNAME}: unknown switch ${_a}, stop processing switches"; break;;
            # --*) break;; ## unknown switch, pass it along
            --*) break;; ## unknown switch, pass it along
            *) break;; ## arguments start
        esac
        shift
    done

    (( ${#_parts[@]} )) || _parts=( .emacs.d .thunderbird .local .config opt .cargo explore src )
    [[ -d "${_from}" ]] || return $(u.error "'${_from}' is not a directory")

    # --docker checks some things
    if (( _doctor )); then
        local -i _status=0
        declare -p _from
        declare -p _to
        [[ -d "${_to}" ]] || { >&2 echo "'{_to}' is not a directory"; _status=1; }
        declare -p _parts
        return ${_status}
    fi
        
    sudo.nopasswd sudo wheel
    sudo.udisk2.config
    
    sudo apt upgrade
    sudo apt install -y tree curl emacs doas keepassx plocate
    sudo updatedb
    
    # TODO mike@carif.io: import gnome key material into ~/.local/share/keyrings/

    for _p in ${_parts[@]}; do
        local _f="${_from}/${_p}"
        [[ -d "${_f}" ]] || continue
        local _t="${_to}"
        # TODO mike@carif.io: add correct switches
        >&2 echo rsync -a ${_f}/ ${_t}
    done

    # remove all the spurious "SingletonLocks" copied from elsewhere. Assumes no browsers are running (ugh).
    for _sl in $(find ~/.config -name SingletonLock -type l) $(find ~/snap -name SingletonLock -type l); do rm -vf ${_sl}; done
    
)

main "$@"
