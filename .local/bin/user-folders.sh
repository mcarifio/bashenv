#!/usr/bin/env bash
#!/usr/bin/env -S sudo bash
set -Eeuo pipefail; shopt -s nullglob

main() (
    local -A _expected=( [root]='' [to]="${HOME}" ) _required=()
    # Only _expected switches can be _required.
    for _k in ${!_required[@]}; do
        [[ -v _expected[${_k}] ]] || return $(u.error "${FUNCNAME}: ${FUNCNAME} is misconfigured, required switch '${_k}' is not initalized")
    done
    local -a _froms=()

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

            --from=*) _froms+=("${_v}");;
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
    (( ${#_froms[@]} )) || [[ -n "${_merged[root]}" ]] || return $(u.error "${FUNCNAME}: No --root or --from")
    [[ -d "${_merged[root]}" ]] || return $(u.error "${FUNCNAME}: root '${_merged[root]}' not found")
    (( ${#_froms[@]} )) || _froms=( ${_merged[root]}/{.ssh,.cargo,opt,src,explore,*Projects,.config,.emacs.d,.local,.pki,.gnupg,.rustup,.thunderbird,go,snap} )

    for _d in "${_froms[@]}"; do
        [[ -d "${_d}" ]] || { >&2 echo "${_d} not found"; continue; }
        local _from="${_d}" _to="${_merged[to]}/$(basename ${_d})"
        >&2 echo "rsync ${_from} -> ${_to}"
        command rsync --update --fsync --archive --partial \
                --backup --links  --mkpath --xattrs --times "${_from}" "${_to}" || true
    done        
)

# --from=/media/mcarifio/
main "$@"

