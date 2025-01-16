example.options() (
    set -Eeuo pipefail; shopt -s nullglob
    echo -e "\n\n** ${FUNCNAME} unparsed args: " "$@" >&2 

    local -i _bool=0
    # _var required, see check below
    local _var='_var' _varo='_varo' _doo=default # no _do
    local -a _many=()
    local -A _pairs=()
    echo "** ${FUNCNAME} keywords initialized:" >&2
    declare -p _bool _var _varo _doo _many _pairs >&2

    for _a in "$@"; do
        local _k="${_a%%=*}"
        local _v="${_a##*=}"
        case "${_a}" in
            # switches
            --bool) _bool=1;; ## turn _bool on
            --var=*) _var="${_k}";;
            --varo=*) _varo="${_k}";;
	    --do=*) _do="${_v}";; # assign undefined variable
            --doo=*) _doo="${_v}";;
            --many=*) _many+=( "${_v}" );;
            --pairs=*) _pairs["$(u.field ${_k})"]="$(u.field ${_v} 1)";;

            # switch processing
            --) shift; break;; ## explicit stop
            # --*) >&2 echo "${FUNCNAME}: unknown switch ${_a}, stop processing switches"; break;;
            # --*) break;; ## unknown switch, pass it along
            --*) break;; ## unknown switch, pass it along
            *) break;; ## arguments start
        esac
        shift
    done

    echo "** ${FUNCNAME} args parsed" >&2
    declare -p _bool _var _varo _doo _many _pairs >&2

    echo "** ${FUNCNAME} check args" >&2
    [[ -z "${_var:-}" ]] && { echo "${FUNCNAME} _var has no required value, use --var=\${something}"; echo "return here"; } >&2
    declare -p _var >&2
    # arg checks
    (( _bool > -1 )) || return $(u.error "${FUNCNAME} _bool is ${_bool}, expecting _bool > -1")
    declare -p _bool >&2
    
    echo "** ${FUNCNAME} all options" >&2
    declare -p _bool >&2
    declare -p _var >&2
    declare -p _varo >&2
    # declare -p _do >&2
    declare -p _doo >&2
    declare -p _many >&2
    declare -p _pairs >&2
    
    # assign remaining arguments
    local _first="${1:?\"${FUNCNAME} expecting first argument\"}"; shift
    declare -p _first >&2
    
    local _second="${1:?\"${FUNCNAME} expecting second argument\"}"; shift
    declare -p _second >&2

    # _rest is everything unassigned, for completeness
    local -a _rest=( "$@" )
    declare -p _rest >&2

    echo "** ${FUNCNAME} all args" >&2
    declare -p _first >&2
    declare -p _second >&2
    declare -p _rest >&2    

    # body
    echo "** ${FUNCNAME} body" >&2
    declare -p _bool >&2
    declare -p _var >&2
    declare -p _varo >&2
    declare -p _doo >&2
    declare -p _many >&2
    declare -p _pairs >&2
    declare -p _first >&2
    declare -p _second >&2
    declare -p _rest >&2
    echo "@: $@" >&2
    echo "** ${FUNCNAME} return" >&2
    echo ${USER}
)
f.x example.options


# has to be a better way, this is broken
# declare -A __complete_example_options_state
# declare -A __complete_example_options_max=([--bool]=0 [--var]=1 [--varo]=1 [--do]=1 [--many]=-1 [--pairs]=-1)
# declare -i __complete_example_options_start __complete_example_options_entered

# __complete.example.options() {
#     local _command=$1 _word=$2 _previous_word=$3
#     local -i _position=${COMP_CWORD} _arg_length=${#COMP_WORDS[@]}

#     # echo >&2
#     # declare -p COMP_WORDS COMP_CWORD COMP_LINE COMP_POINT >&2
#     # declare -p _command _word _previous_word _position _arg_length >&2

#     local -n _state=${FUNCNAME//./_}_state
#     local -n _max=${FUNCNAME//./_}_max
#     # local -n _switches="${FUNCNAME//./_}_switches"
#     local -nig _start=${FUNCNAME//./_}_start
#     local -nig _entered=${FUNCNAME//./_}_entered

#     declare -p LINENO _entered _start _state _max >&2
#     if (( _arg_length == 2 )) && [[ -z "${_word}" ]]; then
#         _entered=1
#         _start=-1
#         _state=()
#         # _seen=([bool]=0 [var]=0 [varo]=0 [do]=0 [doo]=0 [many]=0 [pairs]=0)
#         _max=
#         declare -p LINENO _entered _start _state _max >&2
#     fi    
#     # echo >&2; declare -p _state _max _start >&2
    
#     # flags
#     local -i _still_switch=1
#     declare -p LINENO _still_switch COMP_LINE >&2
#     [[ "${COMP_LINE}" =~ [[:space:]]--[[:space:]] ]] && _still_switch=0
#     declare -p LINENO _word _still_switch >&2
#     if (( _still_switch )); then
#         case "${_word}" in
#             -) COMPREPLY=( '--' ); return 0;;
#             --bool) _state[--bool]=1; COMPREPLY=( '--bool ' ); return 0;;
#             --var | --varo | --do | --doo | --many | --pairs) COMPREPLY=( ${_word}= ); return 0;;
#             --varo=) [[ -v _state[--var] ]] && COMPREPLY=( ${_word}${_state[--var]} ); return 0;;
#             --varo=*) _state[--varo]="${_word}"; return 0;;
#             --var= | --do= | --doo= | --many= | --pairs=) printf '(%s needs a value) ' ${_word} >&2; return 0;;
#             # --*) local _flags='-- ';
#             #     for _k in ${!_max[@]}; do [[ -v _state[${_k}] ]] || _flags+="--${_key} "; done;
#             #     COMPREPLY=( $(compgen -W "${_flags}" -- ${_word}) );
#             #     return 0;;
#             *) local _keys=''; for _k in "${!_max[@]}"; do _keys+="${_k#--} "; done; COMPREPLY=( $(compgen -W  -- "${_keys}") ); return 0;;
#         esac
#         _start=$(( _arg_length - 1 ))
#     fi

#     local -i _position=$(( _arg_length - _start ))
#     (( _position == 1 )) && { printf 'positional arg %s expects a file ' ${_position} >&2; COMPREPLY+=( $(compgen -f -- "${_word}") ); }
#     (( _position == 2 )) && { printf 'positional arg %s expects one of one, two or three ' ${_position} >&2; COMPREPLY=( $(compgen -W "one two three" -- "${_word}") ); }
#     (( _position > 2 )) && { printf 'rest... ' >&2; }    
# }

# f.complete example.options
# complete -p example.options


example.optionsA() (
    # _expected are the (possible) expected switches and their default values, e.g. --one -> [one] -> 1.
    # _required are expected switches in _expected that must end with a value after parsing.
    # If not in _merged (see below), then the missing switch is "announced" with the associated function, e.g
    # [i_am_required] -> u.error so u.error is the announcing function. Note that u.error and u.warn effectively
    # stop parsing. Note also _expected and _required are on the same line to make editing a little easier.
    local -A _expected=( [one]=1 [two]=2 [blank]='' [i-am-required]='' [warn-me]=1 ) _required=( [i-am-required]=u.error [warn-me]=u.warn )
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
    # declare -p _expected _stated _switches _passthrough _positionals
    printf '%s: ' ${FUNCNAME}; declare -p _expected _stated _merged _passthrough _positionals

    
)
f.x example.optionsA
