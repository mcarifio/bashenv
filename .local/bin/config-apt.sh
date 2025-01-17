#!/usr/bin/env bash
#!/usr/bin/env -S sudo bash
set -Eeuo pipefail; shopt -s nullglob

main() (
    # all args before processing
    local -a _args=( "$@" )

    local -A _expected=(
        [snapshots]=/snapshots/apt/prehook
        [ignore]=/etc/apt/apt.conf.d/99ignore-extensions
        [prehook]=/etc/apt/apt.conf.d/99btrfs-prehook
    )
    local -A _required=( )
    # Only _expected switches can be _required.
    for _k in ${!_required[@]}; do
        [[ -v _expected[${_k}] ]] || return $(u.error "${FUNCNAME}: ${FUNCNAME} is misconfigured, required switch '${_k}' is not initalized")
    done
    
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
    # declare -p _expected _stated _switches _passthrough _positionals
    # printf '%s: ' ${FUNCNAME}; declare -p _args _expected _stated _merged _passthrough _positionals
    for _e in {.,.t,.tar.}{x,g}z {.,}attic '.git.*'; do
        printf 'Dir::Ignore-Files-Silently:: "\%s$";\n'  "${_e}"
    done | sudo install --mode=0644 /dev/stdin ${_merged[ignore]}

    if findmnt --type=btrfs /; then
        sudo mkdir -pv ${_merged[snapshots]} || true
        cat <<EOF | sudo install --mode=0644 /dev/stdin ${_merged[prehook]}
DPkg::Pre-Install-Pkgs { "if [ -d ${_merged[snapshots]} ]; then \
_timestamp=\$(date --iso=seconds); \
_snapshot=${_merged[snapshots]}/\${_timestamp} \
btrfs subvolume snapshot / \${_snapshot}; \
cat - > \${_snapshot}/packages.list.log; \
echo snapshot \${_snapshot}; fi"; };
EOF
    fi
)


main "$@"

