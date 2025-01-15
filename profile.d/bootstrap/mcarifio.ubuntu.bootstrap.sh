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


sudo.etherwake() (
    >&2 echo ${FUNCNAME} tbs
)


gnome.settings() (
    local -A _settings=( [cursor-size]=96 )
    local -A _passthrough=()

    for _a in "$@"; do
        local _k="${_a%%=*}"
        local _v="${_a##*=}"
        case "${_a}" in
            --*=*) [[ -v settings[${_k}] ]] && _settings[${_k}]="${_v}" || _passthrough[${_k}]="${_v}";;
            --) shift; break;; ## explicit stop
            --*) [[ -v settings[${_k}] ]] && _settings[${_k}]=1 || _passthrough[${_k}]=1;;
            *) break;; ## arguments start
        esac
        shift
    done
    local -a _args=( "$@" )


    # > Wifi
    # set wifi ${_name} ${_password}

    # > Network
    # for all network devices, name their NetworkManager connection name to be $(basename $device)

    # > Displays
    # primary 2
    # quad pattern

    # > Sound

    # > Power
    # performance
    # screen blank 15m

    # > Multitasking

    # > Appearance
    # gnome-background
    
    # > Ubuntu Desktop
    # don't show home folder
    # auto-hide dock
    # ... positioned on right

    # > Apps
    # > Notifications
    # > Search
    # > Online Accounts
    # > Sharing

    # > Mouse and Touchpad

    # > Keyboard
    # > Color
    # > Printer
    # > Tablet
    # > Accessibility
    #   > Seeing
    #     set large text size
    #     largest cursor size
    gsettings set org.gnome.desktop.interface cursor-size 96
    # > Privacy
    # > Systems
    # hostname
    
    
)

connect.wifi() (
    # monchat
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

    mkdir -p ${HOME}/bin
    # accomodate fedora conventions for udisk2
    sudo ln -sr /run/media /media
    # sudo mkdir -p /mnt/btrfs/snapshots/$(btrfs.findmnt)
    (( ${#_parts[@]} )) || _parts=( .emacs.d .thunderbird .local .config opt .cargo go explore src )
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

    echo "104.236.99.3 do mike.carif.io" | sudo tee -a /etc/hosts
    gnome.settings
    
    sudo apt upgrade
    sudo apt install -y tree curl emacs doas keepassx plocate thunderbird terminator mtools dosfstools gparted
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
