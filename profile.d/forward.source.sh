# forward.* will forward a bash function call to another program e.g. python or deno.
# The caller wraps the program giving it a memorable name and completion of the arguments.
# If the program source is actually /dev/stdin, then the heavy lifting can be embedded in
# the bash function body. A little brittle but it has it uses. See python.guard.sh for
# some examples.

forward.to() (
    : '${_to} ${_pathname} # run ${_pathname} with ${_to}'
    local _to=${1:?'expecting a command'}; shift
    local _pathname=${1:?'expecting a pathname'}; shift
    u.have ${_to} || return $(u.error "${_to} not found")
    [[ -r "${_pathname}" ]] || return $(u.error "${_pathname} not readable")
    ${_to} "${_pathname}" "$@"
)
f.complete forward.to

forward.by() (
    local _pathname=${1:?'expecting a pathname'}; shift
    [[ -r "${_pathname}" ]] || return $(u.error "${_pathname} not readable")
    local _ext=${_pathname%%.*}
    local _target=forward.${_ext}
    u.have ${_target} || return $(u.error "target ${_target} undefined")
    ${_target} "${_pathname}" "$@"    
)
f.complete forward.by

forward.py() (
    local _pathname=${1:?'expecting a pathname'}; shift
    # local _command=${1:-python}; shift
    local _command=python    
    [[ -r "${_pathname}" ]] || return $(u.error "${_pathname} not readable")
    forward.to ${_command} "${_pathname}" "$@"
)
f.complete forward.py

forward.ts() (
    local _pathname=${1:?'expecting a pathname'}; shift
    # local _command=${1:-deno}; shift
    local _command=deno    
    [[ -r "${_pathname}" ]] || return $(u.error "${_pathname} not readable")
    forward.to ${_command} "${_pathname}" "$@"
)
f.complete forward.ts

forward.f() (
    : '# forward a call to this function to its python script co-located with the function source code, example.forward.f for an example'
    local -a _frame=( $(caller 0) )
    forward.py $(dirname $(realpath -s ${_frame[2]}))/${_frame[1]}.${_ext} "$@"
)
f.complete forward.f

example.forward.f() (
    : 'invokes python ${location}/example.forward.f.py $@'
    forward.f "$@"
)
declare -fx example.forward.f

