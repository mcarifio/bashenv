# https://www.gnu.org/software/bash/manual/html_node/Programmable-Completion.html

# bashenv traffics (mostly) in bash functions that follow these conventions:
#   - they're named ${something}.{something} e.g f.complete. bash completes on .
#   - they are exported global for subshells
#   - they optionally have a completion function named __${fn}.complete which will help the user complete
#       fn's arguments
#   - the first line of the function definition is : 'text' which acts as a docstring

# source ${_this_pathname} [true]
[[ ${1:-false} || -z "${__bashenv_sourced_from[$(realpath ${BASH_SOURCE})]}" ]] && return 0
>&2 echo "sourcing $(realpath ${BASH_SOURCE})"

# declare -Axig __bashenv_fx
f.x() {
    : '${_f}... # export functions ${_f}...'
    declare -Aigx __bashenv_fx
    for _f in "$@"; do
        declare -fx ${_f} && __bashenv_fx["${_f}"]="$(date +"%s")" || return $(u.error "${FUNCNAME} '${_f}' not exported")
    done
}
f.x f.x

f.x.reset() { declare -Axig __bashenv_fx=(); }
f.x f.x.reset

f.x.declare() {
    : '#> return all functions loaded (so far)'
    declare -p -Aigx __bashenv_fx
}
f.x f.x.declare

f.x.keys() {
    : '#> return all functions loaded (so far)'
    declare -Aigx __bashenv_fx
    printf '%s\n' ${!__bashenv_fx[@]}
}
f.x f.x.keys

f.x.match() (
    : '${prefix:-""} #> echo all bashenv functions matching ${prefix} '
    f.x.keys | command grep -E "$1"
)
f.x f.x.match

f.x.value() {
    declare -Aigx __bashenv_fx
    echo ${__bashenv_fx["$1"]};
}
f.x f.x.value

f.x.items() (
    local _fmt=${1:-'[%s]=%s '}
    for _key in $(f.x.keys); do
        printf "${_fmt}" ${_key} $(f.x.value ${_key})
    done
)
f.x f.x.items

f.x.item() (
    local _value=$(f.x.value ${1:?"${FUNCNAME} expecting a key"})
    local _fmt=${2:-'%s %s\n'}
    [[ -n "${_value}" ]] || return $(u.error "${FUNCNAME} no value for key '$1'")
    printf "${_fmt}" $1 ${_value}
)
f.x f.x.item

f.status.reset() { declare -iAxg __bashenv_f_status=(); }
f.x f.status.reset

f.status() {
    declare -iAxg __bashenv_f_status
    local _key=${1:?"${FUNCNAME} expecting a function name"}
    declare -fx ${_key} || return $(u.error "${FUNCNAME} no function named '${_key}'")
    if [[ -n "$2" ]]; then
        __bashenv_f_status["${_key}"]=$2
    else
        [[ -v ${__bashenv_f_status["${_key}"]} ]] && return ${__bashenv_f_status["${_key}"]} || \
                return $(u.error "${FUNCNAME} no status for function '${_key}'")
    fi
}
f.x f.status


f.match() {
    : '${_re} [x] ## find functions matching the regular expression, e.g. ^f\.match'
    local _re=${1:?"${FUNCNAME} expecting a regular expression"}
    local _x=${2:-}
    declare -F${_x} | cut -d ' ' -f3 | grep -E "${_re}"
}
f.x f.match


u.field() (
    local _record=${1:?"${FUNCNAME} expecting a record 0:1:2:..."}
    local -i _field=${2:-0}
    local -a _result=( ${_record//:/ } )
    echo "${_result[${_field}]}"
)
f.x u.field

u.switches() (
    local _name=${1:?"${FUNCNAME} expecting a name"}; shift
    local -a _values=( "$@" )
    (( ${#_values[@]} )) && printf -- "--${_name}=%s " "${_values[@]}"
    
)
f.x u.switches


# TODO mike@carif.io: rename u.{stacktrace,error,warn,info} to log.*
# meant to be called from u.error and u.warn
# emits a stacktrace and pprints it to stderr (using jq).
# returns the status of the last command before invocation.
u.stacktrace() (
    local -i _status=${3:-$?}
    local _level="${1:-"${FUNCNAME} expecting a level e.g. error or warn"}"
    local _message="${2:?"${FUNCNAME} expecting a message"}"

    set -Eeuo pipefail
    # the slice of FUNCNAME[@] to actually print (2..-1)
    local -i _start=2 _top=${#FUNCNAME[@]}
    # the length of that slice
    local -i _length=$(( ${_top} - ${_start} ))

    # print the "header": level, message, status
    ( printf '{ "level":"%s", "message": "%s", "status": %i' ${_level} "${_message}" ${_status}
      # if the stacktrace has contents (_length > 0), emit an array containing the length of the array
      # and {pathname, location} objects.
      if (( _length > 0 )); then
          printf ', "trace": [ %i' ${_length}
          shopt -s extdebug
          for _f in ${FUNCNAME[@]:${_start}:${_top}}; do
              local _where=( $(declare -F ${_f}) )
              printf ', {"pathname":"%s", "line": %i, "function": "%s"}' ${_where[2]:-main} ${_where[1]:-0} ${_where[0]:-main}
          done
          # close off the array
          printf ']'
      fi
      # close off the object and pprint with jq
      printf '}' ) | >&2 jq -r '.'

    return ${_status}
)
f.x u.stacktrace

# Writes an eroro pprinted message and stack trace to stderr. Returns status of caller or 1 iff status is 0.
u.error() (
    local -i _status=${2:-$?}
    local _message="${1:?"${FUNCNAME} expecting a message"}"
    u.stacktrace ${FUNCNAME#*.} "${_message}" ${_status} || true
    return $(( _status ? _status : 1 ))
)
f.x u.error

# Writes a warn pprinted message and stack trace to stderr. Returns 0 always.
u.warn() (
    local -i _status=${2:-$?}
    local _message="${1:?"${FUNCNAME} expecting a message"}"
    u.stacktrace ${FUNCNAME#*.} "${_message}" ${_status} || true
)
f.x u.warn

# Writes an info pprinted message and stack trace to stderr. Returns 0 always.
u.info() (
    local -i _status=${2:-$?}
    local _message="${1:?"${FUNCNAME} expecting a message"}"
    u.stacktrace ${FUNCNAME#*.} "${_message}" ${_status} || true
)
f.x u.info


u.bad() {
    local -i _status=${1:-1}; shift
    local _message="${1:-\"$(caller 0) returns ${_status}\"}"; shift
    >&2 printf '%s\n' ${_message}
    return ${_status}
}
f.x u.bad



test.u.err() (
    test.u.err1
)
f.x test.u.err
test.u.err1() (
    false || return $(u.error "${FUNCNAME} stack trace")
)
f.x test.u.err1

f.tbs() {
    : '#> caller to be supplied, returns 1'
    fail && return $(u.error "tbs ${FUNCNAME}")
}
f.x f.tbs

# f.exists
f.exists.sig() (echo ${FUNCNAME%.sig} req _f bash+function no_default)

f.exists() {
    : '${f} # return 0 iff bash function ${f} exists (is defined)'
    # printf '%s: ' ${FUNCNAME} >&2; caller 1 >&2
    local _f=${1:?"${FUNCNAME} expecting a bashenv function"}
    [[ function = $(type -t "${1}") ]]
}
f.x f.exists

__f.exists.complete() {
    # wizard style completion
    local _command=$1 _word=$2 _previous_word=$3
    local -i _position=${COMP_CWORD} _arg_length=${#COMP_WORDS[@]}
    declare -ig __previous_position
    COMPREPLY=()
    if ((_position == 1)); then
        # prompt

        if ((__previous_position != _position)) && [[ -z "${_word}" ]]; then
            echo >&2 -n "(required bashenv function) "
        else
            COMPREPLY=($(f.loaded.match "$2"))
        fi
    else
        ((__previous_position != _position)) && echo >&2 -n "(f.exists takes a single argument) "
    fi
    let __previous_position=_position
}

complete.exists() (
    complete -p "${1:?"${FUNCNAME} expecting a completer"}" &> /dev/null
)
f.x complete.exists

# f.complete
f.complete() {
    : '${f} [${completer}] # export ${f} for subshells and connect to a completion function ${completer}. Both must exist.'
    # printf '%s: ' ${FUNCNAME} >&2; caller 1 >&2
    local _f="${1:?"${FUNCNAME} expecting a function name"}"
    f.x "${_f}"
    local _completer="${2:-__complete.${_f}}"
    if f.exists "${_completer}"; then
        complete -o nospace -F ${_completer} ${_f}
    elif complete.exists ${_completer}; then
        local -a _complete=( $(complete -p ${_completer}) )
        eval "${_complete[@]:-3:-2} ${_f}"
    else
        return $(u.error "${FUNCNAME} no global function or completer ${_completer}") 1
    fi
}
__complete.f.complete() {
    local _command=$1 _word=$2 _previous_word=$3
    local -i _position=${COMP_CWORD} _arg_length=${#COMP_WORDS[@]}
    declare -ig __previous_position
    declare -ig __args_start
    COMPREPLY=()
    if ((_position == 1)); then
        if ((__previous_position != _position)) && [[ -z "${_word}" ]]; then
            echo >&2 -n "(required bashenv function) "
        else
            COMPREPLY=($(f.loaded.match "$2"))
        fi
    elif ((_position == 2)); then
        if ((__previous_position != _position)) && [[ -z "${_word}" ]]; then
            echo >&2 -n "(optional bashenv function that completes ${COMP_WORDS[1]}) "
        else
            COMPREPLY=($(f.loaded.match "$2"))
        fi
    else
        ((__previous_position != _position)) && echo >&2 -n "(f.complete takes 1..2 arguments) "
    fi
    let __previous_position=_position
}
f.x f.complete

f.complete.4() {
    local -a _frame=($(caller 0))
    local _one=${_frame[1]}
    echo ${_one:2:-9}
}
f.x f.complete.4

f.complete.for() (
    local _command=${1:?'expecting a command'}
    (complete -p ${_command} | cut -d' ' -f3) || true
)
f.x f.complete.for

f.complete.init() {
    declare -aig __bashenv_completer_prompted=()
    declare -ig __bashenv_completer_previous_position=-1
    declare -ig __bashenv_positionals_start=-1
    declare -g __bashenv_completer=""
}
f.x f.complete.init

# backed myself into a corner here, pause
f.mkcompleter() {
    : 'make a completer function given a signiture of the form ${fn} required|optional ${arg_name} 'type' 'completion expression' ... '
    local _for=${1:?'expecting a bashenv function'}
    shift
    declare -a _args=("$@")
    local -i _len=$(((${#_args[@]} / 4) - 1))
    for p3 in $(seq 0 ${_len}); do
        let p=p3*3
        ${FUNCNAME}.generate ${_args[$p]} ${_args[$((p + 1))]} "${_args[$((p + 2))]}" "${_args[$((p + 3))]}"
    done
}
f.x f.mkcompleter

f.mkcompleter.generate() {
    local _need="${1:?'expected need'}" _name="${3:?'expected type'}" _type="${3:?'expected type'}" _expression="${3:?'expected expression'}"
    echo -n ${_need} ${_name} "${_type}" "${_expression}"
}
f.x f.mkcompleter.generate

# f.mkcompleter f.exists required 'bashenv function' 'f.loaded.match'
# f.mkcompleter u.map required 'bashenv function' 'f.loaded.match' rest int none


source.if() {
    for _f in "$@"; do
        [[ -r "${_f}" ]] && source ${_f}
    done
    true
}
f.x source.if

source.all() {
    for _f in "$@"; do
        echo -n ${_f} >&2
        source ${_f}
        echo " => $?" >&2
    done
}

f.x source.all

path.folder() (
    for _d in "$@"; do
        [[ -d "${_d}" ]] || continue
        echo "${_d}"
        return 0
    done
    echo >&2 "No folder found in '$@'"
    return 1
)
f.x path.folder

f.folder() (
    echo -n "fix " $(caller 1) >&2
    path.folder "$@"
)
f.x f.folder

find.newest() (
    local _pattern="${1:?'expecting a pathname pattern'}"
    local _dir="${_pattern%/*}"
    local _name="${_pattern##*/}"
    find "${_dir}" -name "'${_name}'" -type f -printf '%T@ %p\n' | sort -n | tail -n 1 | cut -d' ' -f2-
)
f.x find.newest

# plus1, useful to test u.map next
example.plus1() (
    : '${number} #> 1 + ${number} # a useful example for u.map'
    echo $(($1 + 1))
)
__example.plus1.complete() {
    local _command=$1 _word=$2 _prev=$3
    printf >&2 "(int...) "
}
f.x example.plus1

f.apply() (
    local _f=${1:?'expecting a function'}
    shift
    ${_f} "$@"
)
f.x f.apply

sourced.reset() { declare -Aixg __bashenv_sourced=(); }
f.x sourced.reset

sourced0() {
    local _s=${1:-${BASH_SOURCE[1]}}
    [[ -z "${_s}" ]] && return $(u.error "${FUNCNAME} expecting a pathname")
    local _pn="$(realpath -Lm ${_s})"
    declare -Aixg __bashenv_sourced
    __bashenv_sourced["${_pn}"]=$(date +"%s")
}
f.x sourced0

sourced() {
    local _s=${1:-${BASH_SOURCE[1]}}
    [[ -z "${_s}" ]] && return $(u.error "${FUNCNAME} expecting a pathname")
    local _pn="$(realpath -Lm ${_s})"
    declare -Aixg __bashenv_sourced_from
    __bashenv_sourced_from["${_pn}"]=$(date +"%s")
}
f.x sourced


sourced.when() {
    local _s=${1:-${BASH_SOURCE[1]}}
    [[ -z "${_s}" ]] && return $(u.error "${FUNCNAME} expecting a pathname")
    local _pn="$(realpath -Lm ${_s})"
    declare -Aixg __bashenv_sourced
    local -i _timestamp=${__bashenv_sourced["${_pn}"]}
    echo ${_timestamp}
}
f.x sourced.when

sourced.pathnames() {
    declare -Aixg __bashenv_sourced
    for _pn in "${!__bashenv_sourced[@]}"; do printf '%s\n' ${_pn}; done
}
f.x sourced.pathnames

sourced.times() {
    declare -Aixg __bashenv_sourced
    for _pn in "${!__bashenv_sourced[@]}"; do printf '%s %s\n' ${_pn} ${__bashenv_sourced["${_pn}"]}; done
}
f.x sourced.times


# readline;
readline.bind() (
    local _key_sequence=${1:?'expecting a key sequence'}
    local _function=${2:?'expecting a bash function'}
    # grep --quiet --no-messages --fixed-strings \"${_key_sequence}\" >> ~/.inputrc
    bind -x $(printf '"%s":%s' ${_key_sequence} ${_function})
)
f.x readline.bind

A.clone() (
    : '${_new_aaname} ${_old_aaname} [ix;] # create '
    [[ "$(declare -p ${2:?'expecting a declare'})" =~ ^declare[[:space:]]-([[:alpha:]]+)[[:space:]][^=]+=\((.*+)\) ]] && { echo -n "declare -${BASH_REMATCH[1]/x/} ${1}=("; printf '%s ' ${BASH_REMATCH[2]}; echo ")"; }
)
f.x A.clone;

# TODO mike@carif.io: rename u.map to f.map
# u.map
u.map() {
    : '${f} ${item} ... # apply $f to each item in the list echoing the result'
    local _f=${1:?"${FUNCNAME} expecting a function"}; shift
    for _a in "$@"; do ${_f} ${_a} || return $(u.error "${FUNCNAME} ${_f} ${_a}"); done
}
__u.map.complete() {
    local _command=$1 _word=$2 _previous_word=$3
    local -i _position=${COMP_CWORD} _arg_length=${#COMP_WORDS[@]}
    COMPREPLY=()
    if ((_position == 1)); then
        if ((__previous_position != _position)) && [[ -z "${_word}" ]]; then
            echo >&2 -n "(required bashenv function to map) "
        else
            COMPREPLY=($(f.loaded.match "$2"))
        fi
        declare -ig __bashenv_rest=0
    elif ((_position > 1 && __previous_position != _position)); then
        echo >&2 -n "(u.map ${COMP_WORDS[1]} arguments...) "
        __bashenv_rest=1
    fi
    let __previous_position=_position
}
f.x u.map

# u.map.mkall
u.map.mkall() {
    : '${f} # defines a global function ${f}.all that applies $f} to each argument and returns the result'
    local _f=${1:?'expecting a function'}
    shift
    local _all=${_f}.all
    # local _completer=''
    # f.exists __${_f}.complete && _completer=__f${_f}.complete
    eval $(printf '%s() { u.map %s "$@"; }; f.x %s %s' ${_all} ${_f} ${_all})
}
__u.map.mkall.complete() {
    local _command=$1 _word=$2 _previous_word=$3
    local -i _position=${COMP_CWORD} _arg_length=${#COMP_WORDS[@]}
    COMPREPLY=()
    if ((_position == 1)); then
        COMPREPLY=($(f.loaded.match "$2"))
    else
        echo >&2
        f.doc >&2 u.map.mkall
        echo >&2 "u.map.mkall takes one argument, currently ${_previous_word}"
        echo -n "${COMP_LINE} "
    fi
}
f.x u.map.mkall


f.doc() {
    : '${function} # echos the docstring of a function to stdout'
    local _f=${1:?'expecting a function'}
    if [[ $(type -t ${_f}) = "function" ]]; then
        echo -n "${_f} "
        type ${_f} | awk "match(\$0,/\s+:\s+'(.*)'/,m) { print m[1]; }"
    else
        echo >&2 "'function ${_f}' not found"
        return 1
    fi
}
__f.doc.complete() {
    local _command=$1 _word=$2 _previous_word=$3
    local -i _position=${COMP_CWORD} _arg_length=${#COMP_WORDS[@]}
    COMPREPLY=()
    if ((_position == 1)); then
        COMPREPLY=($(f.loaded.match "$2"))
    else
        echo >&2
        f.doc >&2 f.doc
        echo >&2 "f.doc takes one argument, currently ${_previous_word}"
        echo -n "${COMP_LINE} "
    fi
}
f.x f.doc

running.bash() {
    : '# return 0 iff you are in bash (your parent process is the bash shell)'
    realpath /proc/$$/exe | command grep --silent -e 'bash$'
}
f.x running.bash

home() (
    : '[${user}:-${USER}] #> the login directory of the ${user}.'
    getent passwd ${1:-${SUDO_USER:-${USER}}} | cut -d: -f6
)
__home.complete() {
    local _command=$1 _word=$2 _previous_word=$3
    local -i _position=${COMP_CWORD} _arg_length=${#COMP_WORDS[@]}
    COMPREPLY=()
    if ((_position == 1)); then
        COMPREPLY=($(compgen -u -- "$2"))
    else
        echo >&2
        f.doc >&2 home
        echo >&2 "home takes one argument, currently ${_previous_word}"
        echo -n "${COMP_LINE} "
    fi
}
f.x home

# Return the full pathname of the bashenv root directory, usually something like ${HOME}/bashenv.
# Depends on where you placed it however.
eval "bashenv.root() ( echo $(dirname $(realpath ${BASH_SOURCE})); )"
f.x bashenv.root
eval "bashenv.lib() ( echo $(realpath -P ${BASH_SOURCE}); )"
f.x bashenv.lib

bashenv.profiled() ( find $(bashenv.root) -mindepth 1 -maxdepth 1 -name profile\*.d -type d; )
f.x bashenv.profiled
bashenv.binstalld() ( find $(bashenv.root) -mindepth 1 -maxdepth 2 -name binstall\*.d -type d; )
f.x bashenv.binstalld


path() (echo ${PATH} | tr ':' '\n')
f.x path

path.name() {
    : '${_name} ${_pathname} ## export ${_name} iff ${_pathname} exists'
    local _name=${1:?'expecting an env name'}
    local _pathname=${2:?'expecting a readable pathname'}
    [[ -r "${_pathname}" ]] && export ${_name}=${_pathname} || return $(u.error "${_pathname} not readable.")
}
f.x path.name

path.login() (
    : '#> Enumerates interesting directories under $(home) to be added to PATH'
    printf '%s:' $(home)/opt/*/current/bin $(home)/.config/*/bin ~/.local/bin
)
f.x path.login

# path.add
path.add() {
    : '${folder}... ## adds ${folder} to PATH iff not already there'
    for _a in "$@"; do
        [[ -z "${_a}" ]] && continue
        local _p=$(realpath -sm "${_a}")
        [[ -d "${_a}" ]] || continue
        case ":${PATH}:" in
        *:"${_p}":*) ;;
        *) PATH="${_p}:$PATH" ;;
        esac
    done
}
__path.add.complete() {
    local _command=$1 _word=$2 _previous_word=$3
    # return list of possible directories https://stackoverflow.com/questions/12933362/getting-compgen-to-include-slashes-on-directories-when-looking-for-files/40227233#40227233a
    COMPREPLY=($(
        compopt -o nospace
        compgen -d -- $2
    ))
}
f.x path.add
u.map.mkall path.add # path.add.all

f.x path.login

path.alias() (
    local _cmd=${1:?"${FUNCNAME} expecting a command"}
    local _alias=${2:?"${FUNCNAME} expecting an alias"}
    u.have ${_cmd} || return 0
    _cmd_pn=$(type -P ${_cmd}) || return $(u.error "${FUNCNAME} '${_cmd}' has no path")
    _dirname="$(dirname "${_cmd_pn}")"
    ln -sr ${_dirname}/{${_cmd},${_alias}} || ln -s ${_cmd_pn} ~/.local/bin/${_alias} || return $(u.error "${FUNCNAME} cannot alias '${_cmd}' with '${_alias}'")
    type -P ${_alias}
)
f.x path.alias

# path.walk
path.walk() (
    : '${folder} [${min} [${max}]] #> all directories under ${folder}'
    local -r _root=${1:-${PWD}}
    local -ri _maxdepth=${2:-1}
    local -ri _mindepth=${3:-1}
    find "${_root}" -mindepth ${_mindepth} -maxdepth ${_maxdepth} -type d -regex '.*/[^\.]+$'
)
__path.walk.complete() {
    local _command=$1 _word=$2 _previous_word=$3
    local -i _position=${COMP_CWORD} _arg_length=${#COMP_WORDS[@]}
    declare -ig __previous_position
    COMPREPLY=()
    if ((_position == 1)); then
        COMPREPLY=($(
            compopt -o nospace
            compgen -d -- $2
        ))
    elif ((_position == 2)); then
        ((__previous_position != _position)) && [[ -z "${_word}" ]] && echo >&2 -n "(mindepth) "
    elif ((_position == 3)); then
        ((__previous_position != _position)) && [[ -z "${_word}" ]] && echo >&2 -n "(maxdepth) "
    else
        echo >&2 -n "(path.walk takes 3 arguments) "
        # echo -n "${COMP_LINE} "
    fi
    let __previous_position=_position
}
f.x path.walk

# path.pn
path.pn() (
    realpath -Lms ${1:-${PWD}}
)
complete path.pn
u.map.mkall path.pn

# path.hpn, host + pathname 1
path.hpn() (
    : '${path} #> echo full pathname including host'
    echo -n ${HOSTNAME}:
    realpath -Lms ${1:-${PWD}}
)
f.x path.hpn
u.map.mkall path.hpn

# path.basename
path.basename0() (
    : '${pathname} #> echo basename of ${pathname}. all extensions are removed.'
    local _pn=${1:?'expecting a pathname'}
    local _result=${_pn##*/}
    echo ${_result%%.*}
)
# __path.basename.complete() {
#     local _command=$1 _word=$2 _previous_word=$3
#     # return list of possible directories https://stackoverflow.com/questions/12933362/getting-compgen-to-include-slashes-on-directories-when-looking-for-files/40227233#40227233a
#     COMPREPLY=($(compgen -f -- $2))
# }
# f.x path.basename0

path.basename.part() (
    : '${_pn} ${_position} # return the nth part of a pathnames basename'
    local _pn="${1:?'expecting a pathname'}"
    local -ir _position=${2:--1}
    _pn=${_pn##*/} # remove dirname
    declare -a _result=( ${_pn//./ } ) # break basename into it's parts via dot (.)
    # declare -p _pn _position _result
    echo ${_result[${_position}]} # return the part by position (indices from the right)
)
f.x path.basename.part

path.basename() ( path.basename.part "${1:?'expecting a pathname'}" 0; )
f.x path.basename



# path.md
path.md() (
    : '${folder} #> make a directory (md) and return its pathname, e.g cp foo $(path.md /tmp/foo)/bar'
    local _d=$(path.pn $1)
    [[ -d "$_d" ]] || mkdir -p ${_d}
    printf "%s" ${_d}
)
__path.md.complete() {
    local _command=$1 _word=$2 _previous_word=$3
    # return list of possible directories https://stackoverflow.com/questions/12933362/getting-compgen-to-include-slashes-on-directories-when-looking-for-files/40227233#40227233a
    COMPREPLY=($(compgen -d -- $2))
}
f.x path.md

# path.mkcd
path.mkcd() {
    : '${_folder} # make folder (directory) ${_folder} if needed and then cd to it.'
    local _d=$(path.md $1)
    [[ -z "${_d}" ]] || cd -Pe ${_d}
}
__path.mkcd.complete() {
    local _command=$1 _word=$2 _previous_word=$3
    # return list of possible directories https://stackoverflow.com/questions/12933362/getting-compgen-to-include-slashes-on-directories-when-looking-for-files/40227233#40227233a
    COMPREPLY=($(compgen -d -- $2))
}
f.x path.mkcd

path.mp() (
    : '{_p} # make $(dirname ${_p}) if needed and return the entire pathname to the caller. Executed for side effect.'
    local _p=$(printf "%s/%s" $(path.md $1/..) ${1##*/})
    printf ${_p}
)
f.x path.mp

# path.mpt not really needed, touch $(path.mp foo) is just as clean.
path.mpt() (
    : '${_pn} # touch ${_pn} creating the path as needed along the way. Echo the final pathname.'
    set -Eeuo pipefail
    local _pn="$(path.mp ${1:?'expecting a pathname'})" || return $(u.error "Cannot create pathname $1")
    touch ${_pn}
    printf ${_p}
)
f.x path.mpt

# usage (in function): local _first_readable_pathname="$(path.first x y z ~/.bash_profile)" || echo "no readable path found" >&2
pn.first() (
    : '${_pathname}* # return the first pathname that is readable with status 0. otherwise return status 1'
    set -Eeuo pipefail; shopt -s nullglob
    for _a in "$@"; do
        [[ -r "${_a}" ]] && { echo "$(realpath -Lm ${_a})"; return 0; }
    done
    return $(u.error "${FUNCNAME} found none of $@" 1)
)
f.x pn.first

path.contents.clean() (
    : 'remove blank lines and comments from a set of files or stdin'
    sed '/^\s*$/d; s/#.*//' $@
)
f.x path.contents.clean

path.mpcd() (cd $(dirname $(path.mp ${1:?'expecting a pathname'})))
f.x path.mpcd

path.readable() { [[ -r "$1" ]]; }
f.x path.readable
u.map.mkall path.readable

path.exists() (
    local _pathname="${1:?"${FUNCNAME}@${BASH_LINENO}: expecting a pathname"}"
    local _mode="${2:-}"
    [[ -n "${_mode}" ]] && { chmod "${_mode}" "${_pathname}" || return $(u.error "cannot chmod '${_mode}' on '${_pathname}'?"); }
    [[ -r "${_pathname}" ]] && echo "${_pathname}" || return $(u.error "pathname '${_pathname}' is not readable.")
)
f.x path.exists



# u.have (the heart of guard())
# u can have a command in various ways: on PATH, as a flatpak or as a snap (ubutu)
u.have() (
    : '[--install=${_pkg}.${_kind}] ${_cmd} # succeeds iff ${_cmd} is (eventually) defined.'
    set -Eeuo pipefail

    local _install='' ## the basename for an _installer, e.g. 'emacs.dnf'
    for _a in "${@}"; do
        local _k="${_a%%=*}"
        local _v="${_a##*=}"
        case "${_a}" in
            # switches
            --install=*) _install="${_v}";;
            --) shift; break;;
            --*) break;; 
            *) break;;
        esac
        shift
    done
    local _cmd="${1?:"${FUNCNAME} expecting a command"}"

    [[ -z "${_install}" ]] && { type -P ${_cmd} >/dev/null; return; }
    local _installer=$(bashenv.binstalld)/${_install}.binstall.sh
    ${_installer} || return $(u.error "installer '${_installer}' for command '${_cmd}' failed")
    type -P ${_cmd} >/dev/null    
)
f.x u.have

u.haveP() ( u.have ${1?:"${FUNCNAME} expecting a command"}; )
f.x u.haveP

u.have.all() (
    : '${command} # succeeds iff ${command} is defined.'
    set -Eeuo pipefail
    for _c in $@; do u.have ${_c} || return 1; done
    return 0
)
f.x u.have.all

u.haveP.all() (
    : '${command} # succeeds iff ${command} is defined.'
    set -Eeuo pipefail
    for _c in $@; do u.haveP ${_c} || return 1; done
    return 0
)
f.x u.haveP.all


flatpak.have() (
    : '${command} # succeeds iff ${command} is defined.'
    set -Eeuo pipefail
    [[ -n "${1:-}" ]] && flatpak list | grep --fixed-strings --silent ${1:-}
)
f.x flatpak.have


# u.call
u.call() {
    : '${command} ... #> run a command against arguments, skip if ${command} nonexistant.'
    local _f=${1:?'expecting a command'}
    shift
    u.have ${_f} || return 0
    ${_f} "$@"
}
__u.call.complete() {
    local _command=$1 _word=$2 _previous_word=$3
    COMPREPLY=($(compgen -A function -- "$2"))

    COMPREPLY=($(f.match "$2") $(compgen -c "$2"))
}
f.x u.call


prompt.command.add() {
    local _f=${1:?'expecting a function'}
    u.have ${_f} || return $(u.error "function '${_f}' not found")
    [[ " ${PROMPT_COMMAND[@]} " =~ [[:space:]]${_f//./\.}[[:space:]] ]] || PROMPT_COMMAND+=(${_f})
}
f.x prompt.command.add
# prompt.command.add f.complete.init

__f.complete.for.complete() {
    local _command=$1 _word=$2 _previous_word=$3
    local -i _position=${COMP_CWORD} _arg_length=${#COMP_WORDS[@]}
    COMPREPLY=()

    if ((_position == 1)); then
        # if [[ -z "${_word}" && (( __bashenv_completer_prompted[_position] )) ]] ; then
        if [[ -z "${_word}" ]]; then
            echo >&2 -n "(required: command) "
        else
            COMPREPLY=($(complete -p | command sed -e 's|.* ||'))
            COMPREPLY=($(compgen -W '${COMPREPLY[@]}' -- "${_word}"))
        fi
    elif ((_position > 1)); then
        if ((__bashenv_completer_previous_position != _position)) && [[ -z "${_word}" ]] && ((!__bashenv_completer_prompted[_position])); then
            echo >&2 -n "(return) "
        fi
    fi
    let __bashenv_completer_prompted[_position]=_position
    let __bashenv_completer_previous_position=_position
}
f.x __f.complete.for.complete

bashenv.is.tracing() { grep --silent x <<< $-; }
f.x bashenv.is.tracing

bashenv.is.elf() ( file --mime-type ${1:?'expecting a pathname'} | grep --silent application/x-executable; )
f.x bashenv.is.elf



# Since associative arrays can't be passed as arguments, generate functions instead. Yuck.
# bashenv.A associate array "base"
u.f2v() ( local -u _name=${1//./_}; echo ${_name}; )
f.x u.f2v

u.f2aa() { echo __bashenv_${1//./_}; }; f.x u.f2aa
u.aa2f() {
    local _aa=${1:?"${FUNCNAME} expecting an associating array"}
    [[ "${_aa}" =~ __bashenv_([^_]+)_(.+) ]] && echo ${BASH_REMATCH[1]}.${BASH_REMATCH[2]} || return $(u.error "${FUNCNAME} '${_aa}' not expected as __something_else")
}; f.x u.aa2f

bashenv.A.reset() {
    local -ngx _An=${1:?"${FUNCNAME} expecting a global associative array name"}
    _An=()
}

bashenv.A.key() {
    local -ngx _An=${1:?"${FUNCNAME} expecting a global associative array name"}
    local _key=${2:?"${FUNCNAME} is expecting a key"}
    [[ -v _An["${_key}"] ]]
}

bashenv.A.keys() {
    local -ngx _An=${1:?"${FUNCNAME} expecting a global associative array name"}
    printf '%s\n' ${!_An[@]};
}
f.x bashenv.A.keys

bashenv.A.keymatch() {
    local -ngx _An=${1:?"${FUNCNAME} expecting a global associative array name"}
    local _re=${2:?"${FUNCNAME} is expecting a regular expression"}
    printf '%s\n' ${!_An[@]} | grep -E "${_re}"
}
f.x bashenv.A.keymatch



bashenv.A.value() {
    local -ngx _An=${1:?"${FUNCNAME} expecting a global associative array name"}
    local _key=${2:?"${FUNCNAME} is expecting a key"}
    [[ -v _An["${_key}"] ]] && echo ${_An["${_key}"]} || return $(u.error "No key '${_key}' in ${_An}.")
}
f.x bashenv.A.value

bashenv.A.values() {
    local -ngx _An=${1:?"${FUNCNAME} expecting a global associative array name"}
    printf '%s\n' ${_An[@]}
}
f.x bashenv.A.values


bashenv.A.items() {
    local -ngx _An=${1:?"${FUNCNAME} expecting a global associative array name"}
    local -r _fmt=${2:-'[%s]=%s\n'};
    for _key in "${!_An[@]}"; do printf "${_fmt}" ${_key} ${_An["${_key}"]}; done
}
f.x bashenv.A.items

bashenv.A.map() {
    local -ngx _An=${1:?"${FUNCNAME} expecting a global associative array name"}
    local _action=${2:-echo}
    u.have ${_action} || return $(u.error "${FUNCNAME} no action ${_action}")
    local -a _pair
    for _p in $(${FUNCNAME%.*}.items $1 '%s:%s\n'); do
        _pair=( ${_p/:/ } )
        # declare -p _pair
        local _key=${_pair[0]} _value=${_pair[1]}
        ${_action} ${_key} ${_value} || true
    done        
}
f.x bashenv.A.map


bashenv.mkA() {
    local _aa=${1:?"${FUNCNAME} expecting a global associative array name"}
    local -ngx _An=${_aa}
    local _prefix=$(u.aa2f ${_aa})

    for _method in ${_prefix}.{reset,key,keymatch,keys,value,values,items,map}; do
        eval $(printf '%s() { bashenv.A.${FUNCNAME##*.} $(u.f2aa ${FUNCNAME%%.*}) $1; };' ${_method}); f.x ${_method}
    done
}; f.x bashenv.mkA

# sourced.from
declare -Agx __bashenv_sourced_from
bashenv.mkA __bashenv_sourced_from

# sourced.action
declare -Agx __bashenv_sourced_action
bashenv.mkA __bashenv_sourced_action

# sourced.status
declare -Agx __bashenv_sourced_status
bashenv.mkA __bashenv_sourced_status

# sourced.when
declare -Agx __bashenv_sourced_when
bashenv.mkA __bashenv_sourced_when

# declare -Ax __bashenv_db
# bashenv.mkA __bashenv_db

bashenv.paths() {
    path.add.all $(home)/go/bin $(home)/opt/*/current/bin $(home)/.config/*/bin \
                 $(home)/bin $(home)/.local/bin \
                 $(bashenv.root)/bin $(bashenv.root)/.local/bin
    
}
f.x bashenv.paths


bashenv.init.libs() {
    bashenv.paths; for _l in $(bashenv.libs); do source "${_l}"; done
}
f.x bashenv.init.libs



bashenv.init() {
    local -i _trace=0
    for _a in "${@}"; do
        case "${_a}" in
            --trace) _trace=1;;
            --) shift; break;;
            --*) return $(u.error "${FUNCNAME} unknown switch '${_a}', stopping");; ## error on unknown switch
            *) break;;
        esac
        shift
    done

    # bashenv.paths; (( _trace )) && echo ${PATH} >&2

    # for _l in $(bashenv.libs); do
    #     (( _trace )) && printf '%s => ' ${_l} >&2
    #     source "${_l}"
    #     (( _trace )) && printf '%s\n' $? >&2
    # done
    bashenv.init.libs


    for _s in $(bashenv.sources); do
        (( _trace )) && printf '%s => ' ${_s} >&2
        source "${_s}"
        (( _trace )) && printf '%s\n' $? >&2
    done

    for _f in $(bashenv.env.functions); do
        (( _trace )) && printf '%s => ' ${_f} >&2
        ${_f} || true
        (( _trace )) && printf '%s\n' $? >&2        
    done
    # TODO mike@carif.io: fix return status
    f.status ${FUNCNAME} 0
}
f.x bashenv.init




bashenv.init.succeeded() { return $(f.status ${FUNCNAME/.succeeded/}); }
f.x bashenv.init.succeeded

bashenv.env.functions() (
    declare -Fpx | cut -f3 -d' ' | grep -e '\.env$'
)
f.x bashenv.env.functions

bashenv.env.start() {
    for f in $(bashenv.env.functions); do
        f.status $f &> /dev/null && continue
        $f
        local -i _status=$?
        f.status $f ${_status}
        (( ! _status )) || u.error "${_f} returned ${_status}"
    done
}
f.x bashenv.env.start


bashenv.session.functions() (
    declare -Fpx | cut -f3 -d' ' | grep -e '\.session$'
)
f.x bashenv.session.functions

bashenv.session.start() {
    for f in $(bashenv.session.functions); do
        f.status $f &> /dev/null && continue
        $f
        local -i _status=$?
        f.status $f ${_status}
        (( ! _status )) || u.error "${_f} returned ${_status}"
    done
}
f.x bashenv.session.start



bashenv.update() (
    : '# git pull the latest changes'
    git -C $(bashenv.root) pull;
)
f.x bashenv.update

bashenv.reload() {
    : '## simulate login'
    local _bash_profile="$(home)/.bash_profile"
    source "${_bash_profile}" || return $(u.error "source ${_bash_profile} failed.")
    local _bashrc="$(home)/.bashrc"
    source "${_bashrc}" || return $(u.error "source ${_bashrc} failed.")
}
f.x bashenv.reload

_template() (
    : 'add args here ## add comments here'
    set -Eeuo pipefail; shopt -s nullglob no-clobber
    false || return $(u.error "${FUNCNAME} tbs")
)
f.x _template

# u.map.tree
u.map.tree() {
    local _action=${1:?'expecting an action, e.g. source or guard'}
    local _folder=${2:?'expecting a folder'}
    [[ -d "${_folder}" ]] || return 0
    for _f in $(find "${_folder}" -type f -regex "[^#]+\.${_action}\.sh\$"); do ${_action} ${_f}; done
}
__u.map.tree.complete0() {
    local _command=$1 _word=$2 _previous_word=$3
    # return list of possible directories https://stackoverflow.com/questions/12933362/getting-compgen-to-include-slashes-on-directories-when-looking-for-files/40227233#40227233a
    COMPREPLY=($(compgen -d -- $2))
}
f.x u.map.tree

u.map.trees0() {
    local _kind=${1:?'expecting a file kind, e.g. lib, source or guard'}; shift
    for _f in $(find $@ -type f -regex "[^#]+\.${_action}\.sh\$"); do
        # ${_action} ${_f}
        echo source ${_f} || >&2 echo "${FUNCNAME}: ${_f} => $?"
    done
}
f.x u.map.trees0

u.map.trees() {
    # local _aamethod=${1:?"${FUNCNAME} expecting an associate array method"}
    # u.have ${_aamethod} || return $(u.error "${FUNCNAME} unknown method ${_aamethod}")
    local -i _depth=${1:?'expecting a depth'}; shift
    local _kind=${1:?'expecting a file kind, e.g. lib, source or guard'}; shift
    local _action=${1:?'expecting an action'}; shift
    local -i _status
    # traverse breadth first
    for _d in $(seq 1 ${_depth}); do
        for _f in $(find $@ -mindepth ${_d} -maxdepth ${_d} -type f -regex "[^#]+\.${_kind}\.sh\$"); do
            ${_action} "${_f}"
            _status=$?
            sourced.status "${_f}" ${_status} > /dev/null
            sourced.when "${_f}" $(date +"%s") > /dev/null
            sourced.action "${_f}" "${_action}" > /dev/null
            (( _status )) && echo "${FUNCNAME}: ${_action} ${_f} => ${_status}" >&2
        done        
    done
}
f.x u.map.trees

# find.regex() (
#     local -i _depth=1
#     local _regex='' # "[^#]+\.${_kind}\.sh\$"

#     for _a in "${@}"; do
#         case "${_a}" in
#             --depth=*) _depth="${_a##*=}";;
#             --regex=*) _regex="${_a##*=}";;
#             --) shift; break;;
#             --*) return $(u.error "${FUNCNAME} unknown switch '${_a}', stopping");;
#             *) break;;
#         esac
#         shift
#     done
    
#     (( _depth > 0 )) || return $(u.error "${FUNCNAME} depth ${_depth} < 1, stopping.")
#     [[ -z "${_regex}" ]] && return $(u.error "${FUNCNAME} expecting --regex=something, not supplied")

#     for _d in $(seq 1 ${_depth}); do find $@ -mindepth ${_d} -maxdepth ${_d} -type f -regex "${_regex}"; done
# )
# f.x find.regex

bashenv.libs() ( find $(bashenv.profiled) -mindepth 1 -maxdepth 1 -regex '^[^#]+\.lib\.sh$'; )
f.x bashenv.libs

bashenv.sources() ( find $(bashenv.profiled) -mindepth 1 -maxdepth 1 -regex '^[^#]+\.source\.sh$'; )
f.x bashenv.libs

u.or() (echo "$@" | cut -d' ' -f1)
f.x u.or

u.shell() {
    : '#> this shell, always bash. But the SHELL env variable can be unreliable'
    basename $(realpath /proc/$$/exe)
}
f.x u.shell

u.shell.login() { shopt -q login_shell; }
f.x u.shell.login

# Set window or tab title in shell, useful for organization.
# Note, a different way to set the running title is 'export TITLE="${somethings}".
_title() (
    if [[ -z "$1" ]]; then
        if [[ -z "${TITLE}" ]]; then
            printf "\e]0;%s %s\a" "${USER}" "${PWD}"
        else
            printf "\e]0;%s\a" "${TITLE}"
        fi
    else
        printf "\e]0;%s\a" "$*"
    fi
)
f.x _title

# dmesg --follow # will follow messages
dmesg() (
    sudo $(type -P dmesg) --human --time-format=iso --decode --color=always "$@" | less -R
)
f.x dmesg

dmesg.error() (
    dmesg --level=emerg,alert,crit,err "$@"
)
f.x dmesg.error

dmesg.user() (
    dmesg --user "$@"
)
f.x dmesg.user

u.folder() (
    : '[${_folder}] #> return the folder name'
    set -Eeuo pipefail
    local _folder="$(realpath -Ls ${1:-${PWD}})"
    echo "${_folder##*/}"
)
f.x u.folder


u.here() (printf $(realpath -Ls $(dirname ${BASH_SOURCE[${1:-1}]})))
f.x u.here

u.where() { realpath -Lms ${1:-${BASH_SOURCE}}/..; }
f.x u.where
u.map.mkall u.where # u.where.all

# u.xwalk() {
#     local _top=${1:?'expecting a root directory'}
#     shift || true
#     local _ext=${1:-sh}
#     shift || true
#     find -L ${_top} -path \*/enabled.d/\*.${_ext} -type f -executable -exec '{}' $* \;
# }
# f.x u.xwalk

u.mkurl() {
    local _self=${FUNCNAME[0]}
    local _url=${1:?"${FUNCNAME} expecting a url"}
    local _pn=${2:?"${FUNCNAME} expecting a pathname"}
    printf "#!/usr/bin/env xdg-open\n%s\n" ${_url} | install -m 0755 /dev/stdin ${_pn}
}
f.x u.mkurl

# never can remember the entire name
# if u.have com.github.johnfactotum.Foliate; then
#     foliate() { command com.github.johnfactotum.Foliate $* & }
#     # from epel
#     # nb: there are snap and flatpak installs as well. they suck.
#     f.x foliate # dnf install foliate
# fi

u.all-hosts() (arp $@ | tail -n+2 | cut -c1-25 | sort | uniq)
f.x u.all-hosts # hping3

# sudo dnf install -y uuid
# if u.have sos; then
#    sos.r() { sudo sos report --batch --case-id="${SUDO_USER}-$(uuidgen)" --description "${FUNCNAME}" $*; }; f.x sos.r
# fi


# pip from the current python directly; coordinate afterwards with asdf and bash
# hack
if u.have asdf; then
    asdf.pipi() {
        python -m pip install -U $*
        asdf reshim python
        hash -r
    }
    f.x asdf.pipi
fi

# pdf renaming
pdf.creationdate() { pdfinfo "${1:?"${FUNCNAME} expecting a pathname"}" | grep '^CreationDate:' | awk '{print $6}'; }
f.x pdf.creationdate # dnf install pdfinfo

pdf.author() (
    local _author="$(pdfinfo "${1:?"${FUNCNAME} expecting a pathname"}" | grep '^Author:' - | cut -d: -f2 - 2>/dev/null)"
    _author="${_author#"${_author%%[![:space:]]*}"}" 
    _author="${_author// /-}"
    echo "${_author,,}"
)
f.x pdf.author

pdf.author.lastname() (
    : '${_pathname}.pdf |> last name of first author'
    local -a _author=( $(pdfinfo "${1:?"${FUNCNAME} expecting a pathname"}" | grep '^Author:' - | cut -d: -f2 - | tr -s ' ' | cut -d' ' -f1-4 - 2>/dev/null) )
    local _lastname="${_author[-1]}"
    [[ and = "${_lastname}" ]] && _lastname="${_author[-2]}"
    echo ${_lastname,,}        
)
f.x pdf.author.lastname

pdf.title() (
    local _title="$(pdfinfo "${1:?"${FUNCNAME} expecting a pathname"}" | grep '^Title:' - | cut -d: -f2 - 2>/dev/null)"
    _title="${_title#"${_title%%[![:space:]]*}"}" 
    _title="${_title// /-}"
    echo ${_title,,}
)
f.x pdf.title

pdf.title.rename() (
    for _pathname in $*; do
        local _title="$(pdf.title "${_pathname}")"
        [[ -n "${_title}" ]] || return $(u.error "No title for ${_pathname}")
        local _suffix="${_pathname#*.}"
        local _folder="$(dirname "${_pathname}")"
        mv -v "${_pathname}" "${_folder}/${_title}.${_suffix}"
    done    
)
f.x pdf.title.rename
    


pdf.add-date() (
    : '${pathname} # adds a date to pathname, e.g. foo.kind.pdf => foo-${date}.kind.pdf'
    local _date="$(pdf.creationdate "${1:?"${FUNCNAME} expecting a date"}")"
    [[ -n "${_date}" ]] || return $(u.error "no creation date found for $1")
    local _suffix="${1#*.}"
    local _prefix="${1%%.*}"
    local _target="${_prefix}-${_date}.${_suffix}"
    mv -v $1 ${_target}
)
f.x pdf.add-date

pn.deparen() {
    for f in "$@"; do
        local _f="${f//\(/}"
        _f="${_f//\)/}"
        mv "$f" "${_f}" && printf "%s " "${_f}"
    done
}
f.x pn.deparen

pn.is.url() ( echo "${1:?"${FUNCNAME} expecting a name"}" | grep --silent --perl '[a-zA-Z]+://'; )
f.x pn.is.url


# for c in kind kubectl glab lab; do u.have ${c} && source <(${c} completion bash); done
# for c in /usr/share/bash-completion/completions/{docker,dhclient,nmcli,nmap,ip}; do u.have ${c} && source ${c}; done

# dnf install gcc-toolset-11
# src1 /opt/rh/gcc-toolset-11/enable

gnome.snapshot() {
    mkdir -p ~/Pictures/snapshot &>/dev/null
    local _snapshot==~/Pictures/snapshot/$(uuidgen).png
    command gnome-snapshot --area --file=${_snapshot}
    ln -srf ${_snapshot} ~/Pictures/snapshot/latest.png
    gimp ~/Pictures/snapshot/latest.png
}
f.x gnome.snapshot

dispatch() {
    local _action=${1:-start}
    shift || true
    ${_action} $*
}
f.x dispatch

sa.add.user() {
    : 'add.user doomemacs 2000 "passwd"'
    sudo adduser -G wheel -m -u ${2:?'expecting a uid'} ${1:?'expecting a username'}
    [[ -n "${3:-}" ]] && sudo passwd --stdin ${1} <<<"${3}"
}
f.x sa.add.user

# returns 0 iff command is running
is.running() {
    (($(ps aux | grep -F " ${1:?'expecting a command'} " | wc -l) > 1))
}
f.x is.running

# singleton ${_cmd} ... # runs command ${_cmd} ... once
u.singleton() {
    local _cmd=${1:? 'expecting a command'}; shift
    local -u _gate=${_cmd//./_}
    [[ -n "${!_gate}" ]] && return 0
    local _result=$(${_cmd} "$@") || $(u.error "${_cmd} $@ => $?")
    export ${_gate}="${_result}"
    echo "${_result}"
}
f.x u.singleton

# arp.scan -I eno1 > /etc/dsh/lan
# pdsh -g lan id
arp.scan() {
    sudo arp-scan -l $@ | tail -n+3 | head -n-3 | cut -f1 | sort | uniq
}
f.x arp.scan

mnt.iso() {
    : 'mnt.iso .iso [/optional/mountpoint/prefix] # mount .iso as a loopback device'
    local _iso=${1:?'expecting an iso'}
    local _mountpoint=${2:-/mnt/isofs/$(basename ${_iso} .iso)}
    sudo install -o ${USER} -g ${USER} -d ${_mountpoint}
    sudo mount -o loop ${_iso} ${_mountpoint}
}
f.x mnt.iso

url.exists() (curl --HEAD --silent ${1:?'expecting a url'} &>/dev/null)
f.x url.exists

sa.shutdown() (
    for _h in "$@"; do
        ssh root@${_h} { dnf upgrade -y && /usr/sbin/shutdown -h now }
    done
    sudo dnf upgrade -y && sudo /usr/sbin/shutdown -h now
)
f.x sa.shutdown

sa.shutdown.all() (dnf.off milhouse clubber)
f.x sa.shutdown.all

bashenv.mkinstaller() (
    local _kind="${1:?"${FUNCNAME} expecting a kind, like 'dnf'"}"
    local _pkg="${2:?"${FUNCNAME} expecting a pkg name, like 'emacs'"}"

    local -r _installd="$(bashenv.binstalld)"
    local -r _install="${_installd}/${_pkg}.${_kind}.binstall.sh"
    local -r _template="$(pn.first ${_installd}/_template.{${_kind},tbs}.binstall.sh)"
    [[ -r "${_install}" ]] || install "${_template}" "${_install}"
    local _pn=$(realpath ${_install})
    >&2 git -C "${_installd}" ${_pn}
    echo ${_pn} 
)
f.x bashenv.mkinstaller


# local -A _kinds=() _pkgs=()
# for _a in "${@}"; do
#     local _v="${_a##*=}"
#     case "${_a}" in
#         --kind=*) _kinds["${_v}"]=1;;
#         --pkg=*) _pkgs["${_v}"]=1;;
#         --) shift; break;;
#         --* | *) break;;
#     esac
#     shift
# done


source.mkguard() (
    : '${_name} # create ${_name}.source.sh in the right folder'
    set -Eeuo pipefail; shopt -s nullglob
    
    local -r _name=${1:?'expecting a name'}
    type -P ${_name} || $(u.error "${FUNCNAME} cannot find '${_name}' on PATH. Is it installed?")
    local -r _where="$(bashenv.root)/profile.d"
    local -r _guard="${_where}/${_name}.source.sh"
    [[ ! -r "${_guard}" ]] || return $(u.error "${_guard} already exists?")
    xzcat "${_where}/_template.source.sh.xz" | sed "s/\${g}/${_name}/g" > "${_guard}"
    >&2 git -C "$(bashenv.root)" add ${_guard}
    echo "${_guard}"
)
f.x source.mkguard

sourced.missing() {
    for _s in $(bashenv.sources); do sourced.from.key ${_s} || echo ${_s}; done;
}
f.x sourced.missing

# Probe for a particular value. Return it's "map" iff the key is known.
# Otherwise announce an error.
u.mkprobe() {
    local _name=${1:?"${FUNCNAME} expecting a function name"}; shift
    local _key=${1?"${FUNCNAME} expecting a key value operator"}; shift
    source /dev/stdin <<EOF
${_name}() (
    local -A _known=($@)
    local _key="\${1:-\$(${_key})}"
    [[ -v _known[\${_key}] ]] && echo \${_known[\${_key}]} || return \$(u.error "\${FUNCNAME} key '\${_key}' unknown.")
)
EOF
}
# probe the arch
u.mkprobe u.probe.arch 'uname -m' [x86_64]=x86_64 [aarch64]=arm64 [arm64]=arm64
# probe the os
u.mkprobe u.probe.os 'uname -s'  [Linux]=Linux [Darwin]=Darwin
# probe the target
u.mkprobe u.probe.target 'uname -s' [Darwin]=apple-darwin [Linux]=unknown-linux-gnu


# bashenv.lib.sh is treated differently at the end. it can be sourced in several ways
# remember that it's been sourced
sourced || {
  local _status=$?
  u.warn "${BASH_SOURCE} reported errors on source, continuing ..."
}
# ~/.bash_profile handles --login bash sessions
# ~/.bashrc handles --interactive bash sessions
# BASH_ENV handles scripts. See .local/bin/_template.sh for how to invoke
[[ -n "${BASH_ENV}" ]] || return ${_status:-0}
# initialize all the libraries
bashenv.init.libs
