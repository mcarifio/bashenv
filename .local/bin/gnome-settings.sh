#!/usr/bin/env bash
shopt -s nullglob
[[ "$0" = */bashdb ]] && shift


# All gnome settings to my liking

# https://andrewmccarthy.ie/setting-a-blank-desktop-background-in-gnome.html
# gsettings list-keys org.gnome.desktop.background
# gsettings describe org.gnome.desktop.background primary-color
gnome.background() {
    : 'gnome.background [${primary-color:-web-gray} [${secondary-color:-gray}]]'
    local _primary=${1:-snow4}
    local _secondary=${2:-blue}
    gsettings set org.gnome.desktop.background picture-uri none
    # gsettings set org.gnome.desktop.background color-shading-type 'solid'
    gsettings set org.gnome.desktop.background color-shading-type vertical

    # https://en.wikipedia.org/wiki/X11_color_names
    # https://www.w3schools.com/colors/colors_x11.asp
    gsettings set org.gnome.desktop.background primary-color "${_primary}"
    gsettings set org.gnome.desktop.background secondary-color "${_secondary}"
}


main() (
    # expected keys and values
    # local -A _expected=( [one]=1 [two]=2 [blank]='' [i-am-required]='' [warn-me]=1 ) _required=( [i-am-required]=u.error [warn-me]=u.warn )
    local -A _expected=( [primary]=snow4 [secondary]=black ) _required=( )
    # Only _expected switches can be _required.
    for _k in ${!_required[@]}; do
        [[ -v _expected[${_k}] ]] || return $(u.error "${FUNCNAME}: ${FUNCNAME} is misconfigured, required switch '${_k}' is not expected")
    done
    
    # _args are the arguments before processing
    local -a _args=( "$@" )
    # all switches explicitly stated at the command line
    local -A _stated=()
    # switches passed through (unprocessed by the loop)
    local -A _passthrough=()

    for _a in "$@"; do
        # if --key=value then _k is 'key' and _v is 'value'
        # otherwise _k='' and _v is _a
        local _k="${_a%%=*}"
        _k="${_k##*--}"
        [[ -n "${_k}" ]] && local _v="${_a##*=}" || _v="${_a}"

        case "${_a}" in

            # enumerate all the switches including the hardcoded ones --switches --defaults for bash completion consumption
            --switches) printf -- '--switches --defaults '
                        printf -- '--%s ' ${!_expected[@]}
                        echo
                        return 0;;
            
            # enumerate the switches and default values for human consumption
            --defaults) for _k in ${!_expected[@]}; do printf -- '--%s="%s" ' ${_k} "${_expected[${_k}]}"; done
                        echo
                        return 0;;

            # --key=value; $_k is key, $_v is value.
            # $_k is expected (via _expected) and now _stated or unexpected and therefore _passthrough
            --*=*) [[ -v _expected[${_k}] ]] && _stated[${_k}]="${_v}" || _passthrough[${_k}]="${_v}";;

            # explicit parsing break
            --) shift; break;; ## explicit stop

            # boolean switch --${_k}; set it to 1
            --*) [[ -v _expected[${_k}] ]] && _stated[${_k}]=1 || _passthrough[${_k}]=1;;

            # first positional argument, switch parsing ends
            *) break;;
        esac

        shift
    done
    
    # positional arguments are whatevers left over
    local -a _positionals=( "$@" )
    
    # _expected and _stated merged to _merged; these are the actual switches
    local -A _merged=()
    for _k in ${!_expected[@]}; do
        _merged[${_k}]="${_expected[${_k}]}"
    done
    for _k in ${!_stated[@]}; do
        _merged[${_k}]="${_stated[${_k}]}"
    done

    # Missing any required values?
    for _k in ${!_required[@]}; do
        local _announcer=${_required[${_k}]:-u.error}
        [[ -n "${_merged[${_k}]}" ]] || return $(${_announcer} "${FUNCNAME}: '--${_k}' is required")
    done
         
    # body
    # declare -p _expected _required _stated _merged _passthrough _positionals
    gnome.background ${_merged[primary]:-snow4} ${_merged[secondary]:-black}
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

main "$@"

