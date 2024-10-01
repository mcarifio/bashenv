# f

# https://www.gnu.org/software/bash/manual/html_node/Programmable-Completion.html

# bashenv traffics (mostly) in bash functions that follow these conventions:
#   - they're named ${something}.{something} e.g f.complete. bash completes on .
#   - they are exported global for subshells
#   - they optionally have a completion function named __${fn}.complete which will help the user complete
#       fn's arguments
#   - the first line of the function definition is : 'text' which acts as a docstring

# name -> date
# unset __bashenv_loaded || true

declare -Ax __bashenv_fx=()

f.x() {
    : '${_f}... # export functions ${_f}...'
    for _f in "$@"; do
        declare -fx ${_f} && __bashenv_fx["${_f}"]="$(date +"%s")" || return $(u.error "${_f} not exported")
    done
}
f.x f.x

# handle function switches like --var or --var=value
# usage: --switch=*) eval case.update "${_a}";;
# usage: --switch) eval case.update "${_a}";;
case.update() {
    return $(u.error "${FUNCNAME} broken")
    local -r _switch=${1:?"${FUNCNAME} expecting a switch --left or --left=value"}
    local -r _true=${2:-1}
    local -r _prefix=${3:-_}

    # --var=value
    # usage: --left=*) eval $(sw.update ${_a}); >&2 echo ${_left};;
    # repl testing: [[ "literal" =~ --([^=]+)(=(.+))?$ ]] && declare -p BASH_REMATCH
    [[ "${_switch}" =~ --([^=]+)(=(.+))?$ ]] || return $(u.error "${FUNCNAME} '${_switch}' wrong format, expecting a switch --left or --left=value")
    printf '%s%s="%s"' ${_prefix} ${BASH_REMATCH[1]} ${BASH_REMATCH[3]:-${_true}}
}
f.x case.update

u.field() (
    local _record=${1:?"${FUNCNAME} expecting a record 0:1:2:..."}
    local -i _field=${2:-0}
    local -a _result=( ${_record//:/ } )
    echo "${_result[${_field}]}"
)
f.x u.field


u.error() (
    local -i _status=${2:-$?}; (( _status )) || _status=1
    : '${command} || return $(u.error this is a message)'

    set -Eeuo pipefail
    shopt -s extdebug
    printf >&2 '{status: %s, message: "%s", trace:"' ${_status} "$@"
    for _f in ${FUNCNAME[@]}; do
        local _where=( $(declare -F ${_f}) )
        printf >&2 '%s:%s@%s ' ${_where[2]:-main} ${_where[1]:-main} ${_where[0]:-0}
    done
    printf >&2 "\"}\n"
    return ${_status}
)
f.x u.error

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
    local _f=${1:?'expecting a bashenv function'}
    [[ function = $(type -t "${1}") ]]
}
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

# This is a pattern. It will make sense after you've seen it a few times.
# f.complete
f.complete() {
    : '${fn} [__${fn}.complete] # export ${fn} for subshells and connect to a completion fn __${fn}.complete iff it exists'
    local _f=${1:?'expecting a function'}
    local _fc=__${_f}.complete
    f.exists ${_f} || return $(u.error "no function '${_f}'")
    declare -gfx ${_f}
    __bashenv_fx["${_f}"]=$(date +"%s")
    f.exists ${_fc} || return 0
    declare -gfx ${_fc}
    complete -F ${_fc} ${_f}
}
__f.complete.complete() {
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
f.complete f.complete
# Unwound the circularity, you can now bash complete f.exists.
f.complete f.exists

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
}
f.x source.if

f.folder() (
    for _d in "$@"; do
        [[ -d "${_d}" ]] || continue
        echo "${_d}"
        return 0
    done
    echo >&2 "No folder found in '$@'"
    return 1
)
f.x f.folder

f.newest() (
    local _pattern="${1:?'expecting a pathname pattern'}"
    local _dir="${_pattern%/*}"
    local _name="${_pattern##*/}"
    find "${_dir}" -name "'${_name}'" -type f -printf '%T@ %p\n' | sort -n | tail -n 1 | cut -d' ' -f2-
)
f.x f.newest

# plus1, useful to test u.map next
example.plus1() (
    : '${number} #> 1 + ${number} # a useful example for u.map'
    echo $(($1 + 1))
)
__example.plus1.complete() {
    local _command=$1 _word=$2 _prev=$3
    printf >&2 "(int...) "
}
f.complete example.plus1

f.apply() (
    local _f=${1:?'expecting a function'}
    shift
    ${_f} "$@"
)
f.complete f.apply

loaded0() {
    : 'make an exported function ${name}.loaded that always succeeds.'
    local _name="$(path.basename ${1:?'expecting a name'})"
    local _predicate=${_name}.loaded
    local _pathname=${_name}.pathname
    eval "${_predicate}() ( return 0; )"
    f.x ${_predicate}
    eval "${_pathname}() (echo $(realpath -s $1); )"
    f.x ${_pathname}
}
f.x loaded0

declare -Aix __bashenv_sourced=()
sourced.reset() { __bashenv_sourced=(); }
f.x sourced.reset

sourced() {
    local _s=${1:-${BASH_SOURCE[1]}}
    [[ -z "${_s}" ]] && return $(u.error "${FUNCNAME} expecting a pathname")
    local _pn="$(realpath -Lm ${_s})"
    __bashenv_sourced["${_pn}"]=$(date +"%s")
}
f.x sourced

loaded() {
    local _s=${1:-${BASH_SOURCE[1]}}
    [[ -z "${_s}" ]] && return $(u.error "${FUNCNAME} expecting a pathname")
    local _pn="$(realpath -Lm ${_s})"
    __bashenv_sourced["${_pn}"]=$(date +"%s")
    echo fix ${BASH_SOURCE[1]}:${BASH_LINENO[1]} >&2    
}
f.x loaded


sourced.when() {
    local _s=${1:-${BASH_SOURCE[1]}}
    [[ -z "${_s}" ]] && return $(u.error "${FUNCNAME} expecting a pathname")
    local _pn="$(realpath -Lm ${_s})"
    local -i _timestamp=${__bashenv_sourced["${_pn}"]}
    echo ${_timestamp}
}
f.x sourced.when

sourced.pathnames() { for _pn in "${!__bashenv_sourced[@]}"; do printf '%s\n' ${_pn}; done; }
f.x sourced.pathnames

sourced.times() { for _pn in "${!__bashenv_sourced[@]}"; do printf '%s %s\n' ${_pn} ${__bashenv_sourced["${_pn}"]}; done; }
f.x sourced.times

f.loaded.list() (
    f.loaded | command grep -e "\.loaded$"
)
f.x f.loaded.list


# readline;
readline.bind() (
    local _key_sequence=${1:?'expecting a key sequence'}
    local _function=${2:?'expecting a bash function'}
    # grep --quiet --no-messages --fixed-strings \"${_key_sequence}\" >> ~/.inputrc
    bind -x $(printf '"%s":%s' ${_key_sequence} ${_function})
)
f.complete readline.bind



# u -- utility functions

# Not working. Doesn't side effect _options associative array.
u.parse() {
    : 'local -A _my_options=([one]=1 [two]=2); local -a _rest=( $(u.parse _my_options --one=won --three=3 -- x y) ) # see _u.parse.example()'
    local -n _options=${1:?'expecting an associative array'}; shift
    local -i _position=0
    local -a _line=( "$@" )
    if (( ${#_line[@]} )) ; then
        for _a in "${_line[@]}"; do
            case "${_a}" in
                --) shift; ((++_position)); break;;
                # --something=some_value => _options[something]=some_value
                --*=*) [[ "${_a}" =~ --([^=]+)=(.+) ]] && _options[${BASH_REMATCH[1]}]="${BASH_REMATCH[2]}";;
                # --something => _options[something]=1
	        --*) _options[${_a:2}]=1;;
                *) break;;
            esac
            shift
            ((++_position))
        done
    fi
    # printf '%s ' ${_line[@]:${_position}}
}
f.x u.parse

_u.parse.example() (
    declare -A _o=([author]=$USER)
    declare -a _rest=( $(u.parse _o --trace=1 --author=$HOSTNAME+$USER --foo=bar -- one two three) )
    printf '%s ' ${FUNCNAME}; declare -p _o
    printf '%s ' ${_rest[@]}
)



# TODO mike@carif.io: rename u.map to f.map
# u.map
u.map() {
    : '${f} ${item} ... # apply $f to each item in the list echoing the result'
    local _f=${1:?'expecting a function'}; shift
    for _a in "$@"; do ${_f} ${_a} || return $(u.error "${_f} ${_a}"); done
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
f.complete u.map

# u.map.mkall
u.map.mkall() {
    : '${f} # defines a global function ${f}.all that applies $f} to each argument and returns the result'
    local _f=${1:?'expecting a function'}
    shift
    local _all=${_f}.all
    # local _completer=''
    # f.exists __${_f}.complete && _completer=__f${_f}.complete
    eval $(printf '%s() { u.map %s "$@"; }; f.complete %s %s' ${_all} ${_f} ${_all})
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
f.complete u.map.mkall


# f.loaded
# f.loaded() {
#     : '#> return all functions loaded (so far)'
#     printf '%s\n' ${!__bashenv_loaded[@]}
# }
# f.complete f.loaded

# f.loaded.match
# f.loaded.match() {
#     : '${prefix:-""} #> echo all bashenv functions matching ${prefix} '
#     f.loaded | command grep -e "^$1"
# }
# __f.loaded.match.complete() {
#     local _command=$1 _word=$2 _previous_word=$3
#     local -i _position=${COMP_CWORD} _arg_length=${#COMP_WORDS[@]}
#     COMPREPLY=()
#     if ((_position == 1)); then
#         COMPREPLY=($(f.loaded.match "$2"))
#     else
#         echo >&2
#         f.doc >&2 f.loaded.match
#         echo >&2 "f.loaded.match takes one argument, currently ${_previous_word}"
#         echo -n "${COMP_LINE} "
#     fi
# }
# f.complete f.loaded.match

# f.doc
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
f.complete f.doc

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
f.complete home

# Return the full pathname of the bashenv root directory, usually something like ${HOME}/bashenv.
# Depends on where you placed it however.
eval "bashenv.root() ( echo $(dirname $(realpath ${BASH_SOURCE})); )"
f.complete bashenv.root
eval "bashenv.lib() ( echo $(realpath -P ${BASH_SOURCE}); )"
f.complete bashenv.lib

bashenv.profiled() ( find $(bashenv.root) -mindepth 1 -maxdepth 1 -name profile*.d -type d; )
f.x bashenv.profiled


path() (echo ${PATH} | tr ':' '\n')
f.complete path

path.name() {
    : '${_name} ${_pathname} ## export ${_name} iff ${_pathname} exists'
    local _name=${1:?'expecting an env name'}
    local _pathname=${2:?'expecting a readable pathname'}
    [[ -r "${_pathname}" ]] && export ${_name}=${_pathname} || return $(u.error "${_pathname} not readable.")
}
f.complete path.name

path.login() (
    : '#> Enumerates interesting directories under $(home) to be added to PATH'
    printf '%s:' $(home)/opt/*/current/bin $(home)/.config/*/bin ~/.local/bin
)
f.complete path.login

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
f.complete path.add
u.map.mkall path.add # path.add.all

f.complete path.login

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
f.complete path.walk

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
f.complete path.hpn
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
# f.complete path.basename0

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
f.complete path.md

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
f.complete path.mkcd

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

path.mpcd() (cd $(dirname $(path.mp ${1:?'expecting a pathname'})))
f.x path.mpcd

path.readable() { [[ -r "$1" ]]; }
f.x path.readable
u.map.mkall path.readable




# u.have
# u.have is the heart of guard()
# u can have a command in various ways: on PATH, as a flatpak or as a snap (ubutu)
u.have() (
    : '${command} # succeeds iff ${command} is defined.'
    set -Eeuo pipefail
    type -p ${1?:'expecting a command'} >/dev/null
)
f.x u.have

u.have.all() (
    : '${command} # succeeds iff ${command} is defined.'
    set -Eeuo pipefail
    for _c in $@; do u.have ${_c} || return 1; done
    return 0
)
f.x u.have.all

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
f.complete u.call


prompt.command.add() {
    local _f=${1:?'expecting a function'}
    u.have ${_f} || return $(u.error "function '${_f}' not found")
    [[ " ${PROMPT_COMMAND[@]} " =~ [[:space:]]${_f//./\.}[[:space:]] ]] || PROMPT_COMMAND+=(${_f})
}
f.complete prompt.command.add
prompt.command.add f.complete.init

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
f.complete f.complete.for

## guard

# guard.for() {
#     : 'guard.for ${command}... # returns 0 iff all ${commands} are on PATH '
#     u.have "${1:?'expecting a command'}" $2
# }
# f.x guard.for

# _guard() {
#     : '_guard ${pathname} [${command}] # source ${pathname} iff ${command} resolves'
#     local _pathname=${1:-'expecting a pathname'}
#     shift
#     local _for=${2:-$(path.basename ${_pathname})}
#     shift
#     local _flatpak=${3:-}
#     shift
#     guard.for ${_for} || return 0
#     source ${_pathname} "$@" || return $(u.error "${_pathname} => $?")
#     u.call ${_for}.env "$@" || return $(u.error "${_for}.env => $?")
# }
# f.x _guard
# guard() {
#     : 'guard ${pathname} [${command}] # source ${pathname} iff ${command} resolves. print errors but ignores return values'
#     # guard has a private helper _guard which simplifies the calling expression.
#     _${FUNCNAME} "$@" || true
# }
# f.complete guard

# # lib() is a hack to make map.tree work
# lib() {
#     source ${1:?'expecting a lib file like foo.lib.sh'} || return $(u.error "${FUNCNAME} ${_pathname} => $?")
# }
# f.x lib

# bashenv.*



bashenv.install.exe() (
    set -Eeuo pipefail
    local _url=${1:-'expecting a url'}
    local _target="${2:-$(path.mp \"${HOME}/.local/bin/$(basename \"${_url}\")\")}"
    wget "${_url}" -O "${_target}"
    chmod +x "${_target}"
)
f.complete bashenv.install.exe

bashenv.install.zip() (
    : '${_url} ${_folder} ## fetch and unzip a remote zip file, moving all executables to ${_folder}'
    set -Eeuo pipefail
    local _url=${1:-'expecting a url'}
    local _folder="${2:-$(path.mp \"${HOME}/.local/bin\")}"
    # _tmp, a working folder in /tmp, to unzip ${_url}
    local _tmp="$(mktemp --suffix=${FUNCNAME})"
    # _tmp always removed regardless of success
    trap -- "rm -rf ${_tmp}; trap - RETURN;" RETURN
    curl -sSL "${_url}" | bsdtar -C "${_tmp}" -s '|[^/]*/||' -xf -
    for _f in "${_tmp}/*"; do bashenv.is.elf "${_f}" && install --target-directory="${_folder}" "${_f}"; done
)
f.complete bashenv.install.zip


bashenv.is.tracing() { grep --silent x <<< $-; }
f.x bashenv.is.tracing

bashenv.is.elf() ( file --mime-type ${1:?'expecting a pathname'} | grep --silent application/x-executable; )
f.x bashenv.is.elf

bashenv.source.kind() {
    : '[--depth=$i] [--kind=${extension}] [--action=${command}]'
    
    local -i _depth=1
    local _kind=source
    local _action=source

    for _a in "${@}"; do
        case "${_a}" in
            --depth=*) _depth="${_a##*=}";;
            --kind=*) _kind="${_a##*=}";;
            --action=*) _action="${_a##*=}";;
            --) shift; break;;
            --*) return $(u.error "${FUNCNAME} unknown switch '${_a}', stopping");;
            *) break;;
        esac
        shift
    done
    
    (( _depth > 0 )) || return $(u.error "${FUNCNAME} depth ${_depth} < 1, stopping.")
    u.map.trees ${_depth} ${_kind} ${_action} $@
}
f.x bashenv.source.kind

# bashenv.A associate array "base"
u.f2v() ( local -u _name=${1//./_}; echo ${_name}; )
f.x u.f2v

u.f2aa() { echo __${1//./_}; }; f.x u.f2aa
u.aa2f() {
    local _aa=${1:?"${FUNCNAME} expecting an associating array"}
    [[ "${_aa}" =~ __([^_]+)_(.+) ]] && echo ${BASH_REMATCH[1]}.${BASH_REMATCH[2]} || return $(u.error "${FUNCNAME} '${_aa}' not expected as __something_else")
}; f.x u.aa2f

bashenv.A() {
    local -nx _An=${1:?"${FUNCNAME} expecting a global associative array name"}
    local _key=${2:?"${FUNCNAME} expecting a key"}
    [[ -z "${3:-}" ]] || _An["${_key}"]="$3"
    echo ${_An["${_key}"]}
}
f.x bashenv.A

bashenv.A.keys() {
    local -nx _An=${1:?"${FUNCNAME} expecting a global associative array name"}
    printf '%s\n' ${!_An[@]};
}
f.x bashenv.A.keys

bashenv.A.values() {
    local -nx _An=${1:?"${FUNCNAME} expecting a global associative array name"}
    printf '%s\n' ${_An[@]}
}
f.x bashenv.A.values

bashenv.A.items() {
    local -nx _An=${1:?"${FUNCNAME} expecting a global associative array name"}
    local -r _fmt=${2:-'[%s]=%s\n'};
    for _key in "${!_An[@]}"; do printf "${_fmt}" ${_key} ${_An["${_key}"]}; done
}
f.x bashenv.A.items

bashenv.A.map() {
    local -nx _An=${1:?"${FUNCNAME} expecting a global associative array name"}
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
    local -nx _An=${_aa}
    local _prefix=$(u.aa2f ${_aa})
    eval $(printf '%s() { bashenv.A $(u.f2aa ${FUNCNAME}) ${1:?"${FUNCNAME} expecting a key"} ${2:-}; };' ${_prefix}); f.x ${_prefix}
    eval $(printf '%s() { %s=(); };' ${_prefix}.reset ${_aa}); f.x ${_prefix}.reset
    eval $(printf '%s() { bashenv.A.${FUNCNAME##*.} $(u.f2aa ${FUNCNAME%%.*}) ${2:-echo}; };' ${_prefix}.map); f.x ${_prefix}.map

    for _method in ${_prefix}.{keys,values,items}; do
        eval $(printf '%s() { bashenv.A.${FUNCNAME##*.} $(u.f2aa ${FUNCNAME%%.*}) $1; };' ${_method}); f.x ${_method}
    done
}; f.x bashenv.mkA

# sourced.from
declare -Ax __sourced_from
bashenv.mkA __sourced_from

declare -Ax __sourced_action
bashenv.mkA __sourced_action

# 
# sourced.status
declare -Ax __sourced_status
bashenv.mkA __sourced_status
# sourced.status() { bashenv.A $(u.f2aa ${FUNCNAME}) ${1:?"${FUNCNAME} expecting a key"} ${2:-}; }; f.x sourced.status
# sourced.status.reset() { __sourced_status=(); }; f.x sourced.status.reset
# sourced.status.keys() { bashenv.A.${FUNCNAME##*.} $(u.f2aa ${FUNCNAME%.*}); }; f.x sourced.status.keys
# sourced.status.values() { bashenv.A.${FUNCNAME##*.} $(u.f2aa ${FUNCNAME%.*}); };f.x sourced.status.values
# sourced.status.items() {  bashenv.A.${FUNCNAME##*.} $(u.f2aa ${FUNCNAME%.*}); }; f.x sourced.status.items
# sourced.status.map() { bashenv.A.${FUNCNAME##*.} $(u.f2aa ${FUNCNAME%.*}) ${2:-echo}; }; f.x sourced.status.map

# sourced.when
declare -Ax __sourced_when
bashenv.mkA __sourced_when
# sourced.when() { bashenv.A $(u.f2aa ${FUNCNAME}) ${1:?"${FUNCNAME} expecting a key"} ${2:-}; }; f.x sourced.when
# sourced.when.reset() { __sourced_db_when=(); }; f.x sourced.when.reset
# sourced.when.keys() { bashenv.A.${FUNCNAME##*.} $(u.f2aa ${FUNCNAME%.*}); }; f.x sourced.when.keys
# sourced.when.values() { bashenv.A.${FUNCNAME##*.} $(u.f2aa ${FUNCNAME%.*}); };f.x sourced.when.values
# sourced.when.items() {  bashenv.A.${FUNCNAME##*.} $(u.f2aa ${FUNCNAME%.*}); }; f.x sourced.when.items
# sourced.when.map() { bashenv.A.${FUNCNAME##*.} $(u.f2aa ${FUNCNAME%.*}) ${2:-echo}; }; f.x sourced.when.map

declare -Ax __bashenv_db
bashenv.mkA __bashenv_db
# bashenv.db() { bashenv.A $(u.f2aa ${FUNCNAME}) ${1:?"${FUNCNAME} expecting a key"} ${2:-}; }
# f.x bashenv.db

# # bashenv.db.keys0() { printf '%s\n' ${!__bashenv_db[@]}; }
# # f.x bashenv.db.keys0

# bashenv.db.keys() { bashenv.A.${FUNCNAME##*.} $(u.f2aa ${FUNCNAME%.*}); }
# f.x bashenv.db.keys

                    
# # bashenv.db.values0() { printf '%s\n' ${__bashenv_db[@]}; }
# # f.x bashenv.db.values0

# bashenv.db.values() { bashenv.A.${FUNCNAME##*.} $(u.f2aa ${FUNCNAME%.*}); }
# f.x bashenv.db.values


# # bashenv.db.items0() {
# #     local -r _delim=${1:-:};
# #     for _key in "${!__bashenv_db[@]}"; do printf '%s%s%s\n' ${_key} ${_delim} ${__bashenv_db["${_key}"]}; done; }
# # f.x bashenv.db.items0

# bashenv.db.items() {  bashenv.A.${FUNCNAME##*.} $(u.f2aa ${FUNCNAME%.*}); }
# f.x bashenv.db.items

# # bashenv.db.map0() {
# #     local _action=${1:?"${FUNCNAME} expecting an action"}
# #     u.have ${_action} || return $(u.error "${FUNCNAME} no action ${_action}")
# #     for _p in $(bashenv.db.items); do
# #         local -a _pair=( ${_p/: } )
# #         local _key=${_pair[0]} _value=${_pair[1]}
# #         ${_action} ${_key} ${_value} || true
# #     done        
# # }
# # f.x bashenv.db.map0

# bashenv.db.map() { bashenv.A.${FUNCNAME##*.} $(u.f2aa ${FUNCNAME%.*}) ${2:-echo}; }
# f.x bashenv.db.map


bashenv.init() {
    sourced.status.reset; sourced.when.reset
    bashenv.source.kind --depth=1 --kind=lib --action=source $(bashenv.root)
    bashenv.source.kind --depth=2 --kind=source --action=source $(bashenv.profiled)
    sourced.status ${FUNCNAME} 0
    sourced.when ${FUNCNAME} $(date +"%s")
    echo $(date +"%s")
}
f.x bashenv.init

#     # export $(u.f2v ${FUNCNAME})=$(date +"%s")
# bashenv.loaded0() {
#     local _e=$(u.f2v ${FUNCNAME})
#     [[ -n "$1" ]] && export ${_e}=$(date +"%s")
#     local -i _result=$(eval $(printf 'echo ${%s}' ${_e}))
#     return $(( ! _result ))
# }
# f.x bashenv.loaded0


bashenv.loaded() {
    local -i _init="$(sourced.history bashenv.init)"
    return $(( ! _init ))
}
f.x bashenv.loaded

bashenv.session.functions() (
    declare -Fpx | cut -f3 -d' ' | grep -e '\.session$'
)
f.x bashenv.session.functions

bashenv.session.start() {
    for f in $(bashenv.session.functions); do $f || u.error "$f failed"; done
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
f.complete u.map.tree

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
    for _depth in $(seq 1 ${_depth}); do
        for _f in $(find $@ -mindepth ${_depth} -maxdepth ${_depth} -type f -regex "[^#]+\.${_kind}\.sh\$"); do
            ${_action} "${_f}"
            _status=$?
            { sourced.status "${_f}" ${_status}; sourced.when "${_f}" $(date +"%s"); sourced.action "${_f}" "${_action}"; } &> /dev/null
            (( _status )) && echo "${FUNCNAME}: ${_action} ${_f} => ${_status}"
        done        
    done
}
f.x u.map.trees

u.or() (echo "$@" | cut -d' ' -f1)
f.x u.or

u.shell() {
    : '#> this shell, always bash. But the SHELL env variable can be unreliable'
    basename $(realpath /proc/$$/exe)
}
f.x u.shell

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
    sudo dmesg --human --time-format=iso --decode --color=always "$@" | less -R
)
f.complete dmesg

dmesg.error() (
    dmesg --level=emerg,alert,crit,err "$@"
)
f.complete dmesg.error

dmesg.user() (
    dmesg --user "$@"
)
f.complete dmesg.user

# dnf install -y net-tools
# emacs /etc/ethers
ether.wake() (
    sudo /usr/sbin/ether-wake "$@"
)
__ether.wake.complete() {
    local _command=$1 _word=$2 _previous_word=$3
    # return list of possible directories https://stackoverflow.com/questions/12933362/getting-compgen-to-include-slashes-on-directories-when-looking-for-files/40227233#40227233a
    COMPREPLY=($(compgen -A hostname))
}
f.complete ether.wake
u.map.mkall either.wake

gnome.restart() (
    : 'https://www.linuxuprising.com/2020/07/how-to-restart-gnome-shell-from-command.html, only works for X'
    busctl --user call org.gnome.Shell /org/gnome/Shell org.gnome.Shell Eval s 'Meta.restart("Restarting…")'
)
f.x gnome.restart

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

u.xwalk() {
    local _top=${1:?'expecting a root directory'}
    shift || true
    local _ext=${1:-sh}
    shift || true
    find -L ${_top} -path \*/enabled.d/\*.${_ext} -type f -executable -exec '{}' $* \;
}
f.x u.xwalk

u.mkurl() {
    local _self=${FUNCNAME[0]}
    local _url=${1:?'expecting a url'}
    local _pn=${2:?'expecting a pathname'}
    printf "#!/usr/bin/env xdg-open\n%s" ${_url} | install -m 0755 /dev/stdin ${_pn}
}
f.x u.mkurl

# never can remember the entire name
if u.have com.github.johnfactotum.Foliate; then
    foliate() { command com.github.johnfactotum.Foliate $* & }
    # from epel
    # nb: there are snap and flatpak installs as well. they suck.
    f.x foliate # dnf install foliate
fi

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
pdf.creationdate() { pdfinfo "$1" | grep '^CreationDate:' | awk '{print $6}'; }
f.x pdf.creationdate # dnf install pdfinfo

pdf.author() {
    local _author=$(pdfinfo "$1" | grep '^Author:' - | awk '{print $3}' - &>/dev/null)
    echo ${_author,,}
}
f.x pdf.author

pdf.add-date() {
    local _date=$(pdf.creationdate $1)
    if [[ -z "${_date}" ]]; then
        printf >&2 "no creation date found for %s\n" $1
        return 1
    fi
    local _target=${1%%.pdf}-${_date}.pdf
    mv $1 ${_target}
    echo ${_target}
}
f.x pdf.add-date

pn.deparen() {
    for f in "$@"; do
        local _f="${f//\(/}"
        _f="${_f//\)/}"
        mv "$f" "${_f}" && printf "%s " "${_f}"
    done
}
f.x pn.deparen



pdf.mv() {
    # if [[ -r "$1" ]]; then
    #   >&2 printf "'%s' not found\n" "$1"
    #   return 1
    # fi
    : pdf.mv ${_src} ${_location} [${_prefix}]
    local _src="$1"
    local _prefix="${2:-$(basename ${_src} .pdf)}"
    local _location="${3:-${PWD}}"
    local _date=$(pdf.creationdate "${_src}")
    if [[ -z "${_date}" ]]; then
        printf >&2 "no creation date found for %s\n" "${_src}"
        return 1
    fi

    mv -v "${_src}" "$(md ${_location})/${_prefix}-${_date}.pdf"
}
f.x pdf.mv

zlib.title() {
    local _title=${1:?'expecting a pathname'}
    _title=${_title%%---*}
    if [[ "${_title}" =~ ^([^[[:punct:]]]+)$ ]]; then
        _title=${BASH_REMATCH[1]}
    fi
    _title=${_title,,}
    _title=${_title// /-}
    echo ${_title}
}
f.x zlib.title

zlib.lastname0() {
    if [[ "$1" =~ [[:space:]]by[[:space:]][a-zA-Z]+[[:space:]]([a-zA-Z]+) ]]; then
        echo ${BASH_REMATCH[1],,}
    fi
}

# fix later
zlib.lastname() {
    local _pathname=${1:?'need a pathname'}
    [[ -r "${_pathname}" ]] || {
        echo >&2 "'${_pathname}' not readable."
        return 1
    }
    local _result=$(pdf.author "${_pathname}" &>/dev/null) || true
    [[ -n "${_lastname}" ]] && {
        echo ${_lastname}
        return 0
    }
    if [[ "${_pathname}" =~ ---([^[[:punct:]]+).*--- ]]; then
        declare -a _name=(${BASH_REMATCH[1],,})
        echo ${_name[-1]}
    fi
}

zlib.date() {
    local _pathname=${1:?'need a pathname'}
    [[ -r "${_pathname}" ]] || {
        echo >&2 "'${_pathname}' not readable."
        return 1
    }
    local _result=$(pdf.creationdate "${_pathname}" &>/dev/null) || true
    if [[ -n "${_result}" ]]; then
        echo ${_result}
    elif [[ "${_pathname}" =~ ---([[:digit:]]{4}) ]]; then
        echo ${BASH_REMATCH[1],,}
    fi
}
f.x zlib.date

zlib.mv() (
    # zlib.mv ${_src} ${_dir} [${_title} [${_lastname} [${_yyyy}]]]
    # zlib.mv [--dir=pathname] [--title=prefix] [--author=name] [--date=yyyy] doc.{epub,pdf}

    set -Eeuo pipefail
    local _dir="${PWD}" _title="" _lastname="" _date=""
    if ((${#@})); then
        for _a in "${@}"; do
            case "${_a}" in
            --dir=*) _dir="${_a#--dir=}" ;;
            --title=*) _title="${_a#--title=}" ;;
            --lastname=*) _lastname="${_a#--lastname=}" ;;
            --date=*) _date="${_a#--date=}" ;;
            --)
                shift
                break
                ;;
            *) break ;;
            esac
            shift
        done
    fi

    local _src="${1:?'expecting a file name'}"
    [[ -e "${_src}" ]] || {
        echo >&2 "${_src} not found"
        return 1
    }

    [[ -e "${_dir}" && ! -d "${_dir}" ]] && {
        echo >&2 "${_dir} is a file"
        return 1
    }
    [[ ! -d "${_dir}" ]] && {
        echo >&2 "${_dir} does not exist"
        return 1
    }
    [[ -z "${_title}" ]] && _title=$(zlib.title "${_src}")
    [[ -z "${_lastname}" ]] && _lastname=$(zlib.lastname "${_src}")
    [[ -z "${_date}" ]] && _date=$(zlib.date "${_src}")
    local _ext=${_src##*.}
    local _dest="${_dir}/${_title}-${_lastname}-${_date}.${_ext}"

    if [[ "${_ext}" = pdf ]]; then
        mv "${_src}" "${_dest}"
        xz "${_dest}"
        echo >&2 "${_dest}"
    else
        mv "${_src}" "${_dest}"
        echo >&2 "${_dest}"
    fi
)
f.x zlib.mv

for c in kind kubectl glab lab; do u.have ${c} && source <(${c} completion bash); done
for c in /usr/share/bash-completion/completions/{docker,dhclient,nmcli,nmap,ip}; do u.have ${c} && source ${c}; done

# dnf install gcc-toolset-11
# src1 /opt/rh/gcc-toolset-11/enable

gnome.snapshot() {
    mkdir -p ~/Pictures/snapshot &>/dev/null
    local _snapshot==~/Pictures/snapshot/$(uuidgen).png
    command gnome-snapshot --area --file=${_snapshot}
    ln -srf ${_snapshot} ~/Pictures/snapshot/latest.png
    gimp ~/Pictures/snapshot/latest.png
}
f.complete gnome.snapshot

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

function f.defined? {
    : 'f.defined? ${function} ... # true if all functions are defined'
    type -t -- "$@" >/dev/null
}
f.x f.defined?

sa.shutdown() (
    for _h in "$@"; do
        ssh root@${_h} { dnf upgrade -y && /usr/sbin/shutdown -h now }
    done
    sudo dnf upgrade -y && sudo /usr/sbin/shutdown -h now
)
f.x sa.shutdown

sa.shutdown.all() (dnf.off milhouse clubber)
f.x sa.shutdown.all

tbird.logged() (NSPR_LOG_MODULES=SMTP:4,IMAP:4 NSPR_LOG_FILE=/tmp/thunderbird-$$.log thunderbird)
f.x tbird.logged

source.mkguard() (
    : '${_name} # create ${_name}.guard.sh in the right folder'
    set -Eeuo pipefail; shopt -s nullglob
    local -r _name=${1:?'expecting a name'}
    local -r _kind=${2:-tbs}
    local -r _where="$(bashenv.root)/profile.d"
    local -r _installd="${_where}/install.d"
    local -r _guard="${_where}/${_name}.source.sh"
    local -r _install="${_installd}/${_name}.${_kind}.install.sh"
    [[ -f "${_guard}" ]] && return $(u.error "${_guard} already exists?")
    xzcat "${_where}/_template.source.sh.xz" | sed "s/\${g}/${_name}/g" > "${_guard}"
    [[ -r "${_install}" ]] || cp --no-clobber "${_installd}/_template.tbs.install.sh" "${_install}"
    >&2 git -C "$(bashenv.root)" status ${_guard} ${_install}
    echo "${_guard}"
)
f.x source.mkguard

guard.missing() (
    set -Eeuo pipefail; shopt -s nullglob
    local -i _installer=0

    if (( ${#@} )) ; then
        for _a in "${@}"; do
            case "${_a}" in
                --install) _installer=1;;
                --) shift; break;;
                *) break;;
            esac
            shift
        done
    fi
    
    local _cmd=''
    for _f in $(bashenv.folders); do
        for _g in ${_f}/*.guard.sh; do
            _cmd="$(path.basename ${_g%*/})"
            u.have ${_cmd} && continue
            printf '%s ' ${_cmd}
            (( _installer )) || { echo; continue; }
            printf '# '
            printf '%s ' $(find $(bashenv.root) -name ${_cmd}.\*.install.sh -type f)
            echo
        done
    done | sort | uniq
)
f.x guard.missing

# bashenv.loaded || echo "bashenv not loaded"
# loaded "${BASH_SOURCE}"
sourced

