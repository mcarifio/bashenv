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
    local -A _defaults=( [primary]=snow4 [secondary]=black )
    # all switches explicitly stated at the command line
    local -A _stated=()
    # switches passed through (unprocessed by the loop)
    local -A _passthrough=()

    for _a in "$@"; do
        # --key=value => $_k is 'key', $_v is 'value'
        local _k="${_a%%=*}"
        _k="${_k##*--}"
        [[ -n "${_k}" ]] && local _v="${_a##*=}" || _v="${_a}"
        case "${_a}" in
            --switches) printf -- '--switches --defaults '
                        printf -- '--%s ' ${!_defaults[@]}
                        echo
                        return 0;; ## for help and completion
            --defaults) for _k in ${!_defaults[@]}; do printf -- '--%s="%s" ' ${_k} "${_defaults[${_k}]}"; done
                        echo
                        return 0;; ## for help and completion
            --*=*) [[ -v _defaults[${_k}] ]] && _stated[${_k}]="${_v}" || _passthrough[${_k}]="${_v}";;
            --) shift; break;; ## explicit stop
            --*) [[ -v _defaults[${_k}] ]] && _stated[${_k}]=1 || _passthrough[${_k}]=1;;
            *) break;; ## arguments start
        esac
        shift
    done
    # positional arguments
    local -a _positionals=( "$@" )
    
    # _defaults and _stated merged
    local -A _merged=()
    for _k in ${!_defaults[@]}; do _merged[${_k}]=${_defaults[${_k}]}; done
    for _k in ${!_stated[@]}; do _merged[${_k}]=${_stated[${_k}]}; done
    
    # declare -p _defaults _stated _switches _passthrough _positionals
    
    gnome.background ${_merged[primary]:-snow4} ${_merged[secondary]:-black}
)

main "$@"

