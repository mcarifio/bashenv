# use just instead?

eval "pj.root()( echo '$(realpath ${BASH_SOURCE%/*}/../..)';)"; declare -fx pj.root
eval "pj.name()( echo '$(basename $(realpath ${BASH_SOURCE%/*}/../..))';)"; declare -fx pj.name
eval "pj.user() ( echo '${USER}'; )"; declare -fx pj.user
# eval "pj.user.email() ( echo 'mike@carif.io'; )"; declare -fx pj.user.email

pj.bin() ( echo $(pj.root)/pj/bin; ); declare -fx pj.bin

pj.path.add() {
    for _p in "$@"; do
	case ":${PATH}:" in 
	    *:"$1":*) ;;
	    *) PATH=$1:$PATH;;
	esac
    done
}; declare -fx pj.path.add

pj.path.add "$(pj.bin)"

pj.fns() (
    local -r _module=${FUNCNAME%%.*}
    local -r _prefix=${1:-${_module}}
    declare -F| cut -c13-|grep -e "^${_prefix}\."
); declare -fx pj.fns

pj.undo() {
    for _f in $(pj.fns) ${FUNCNAME}; do unset ${_f}; done
}; declare -fx pj.undo


_envrc.bad.arg() {
    : '_envrc.bad.arg ${name} ${got} ${why} # announce bad argument to stderr and return 1'
    # usage: local _arg=${1:?$(_envrc.bad.arg _arg "${1-}" "expecting first arg"})}
    local -r _name="${1:?'expecting a name'}" _got="${2-}" _why="${3:-'no reason given'}"
    local -ar _caller=( $(caller 0) ); local -r _where="${_caller[1]}@${_caller[2]}:${_caller[0]}"
    >&2 echo -e "${_where}: ${_why} for ${_name}, got '${_got}'"
    return 1
}; declare -fx _envrc.bad.arg

envrc.reload() {
    : 'envrc.reload # reload this source file'
    local -r _pathname="$(envrc.pathname)"
    source "${_pathname}" "$@" && >&2 echo "${_pathname} reloaded"
}; declare -fx envrc.reload

pj.browser.open() (
    : 'pj.browser.open ${_url} # opens my default browser in the required url'
    set -Eeuo pipefail; shopt -s nullglob
    # local -r _url="${1:?$(_envrc.bad.arg _url "${1-}" 'expecting a envrc url')}"
    for _url in "$@"; do
	xdg-open  "${_url}" && >&2 printf "opening url '%s'\n" "${_url}"
    done
); declare -fx pj.browser.open

pj.mkbookmark() {
    : 'pj.mkbookmark ${name} ${url} # create a "bookmark" function'
    local -r _module=${FUNCNAME%%.*}
    local -r _kind=$(echo ${FUNCNAME##*.} | cut -c3-)
    local _name=${1:?$(_envrc.bad.arg _name "${1-}" 'expecting a bookmark name')}
    local _url="${2:?$(_envrc.bad.arg _url "${1-}" 'expecting a url')}"
    local -r _fn="${_module}.${_kind}.${_name}"
    local -r _remember="${_module}_${_kind}s"
    eval "${_fn}()(pj.browser.open \"${_url}\"; )"
    declare -fx ${_fn}
    # TODO mcarifio@ciq.com: not working
    # eval "${_remember}[${_fn}]=\"${_url}\""
}; declare -fx pj.mkbookmark

pj.mkbookmark $(pj.name).git "tbs"
# pj.mkbookmark $(pj.name).doc $(pj.name).git/doc

url4() (
    local -r _name="${1:?$(_envrc.bad.arg _name "${1-}" 'expecting a function name')}"
    [[ "$(type -t ${_name})" = function ]] || return 1
    type ${_name} | grep -Po '(?<=jira.browser.open )"[^"]+"'
); declare -fx url4


pj.bookmarks() (
    local -r _module=${FUNCNAME%%.*}
    for _f in $(pj.fns ${_module}.bookmark); do type ${_f}; done
)

pj.loaded() (
    : 'pj.loaded # is defined and returns 0 when called if $(jira.pathname) was sourced to completion'
    return 0;
); declare -fx pj.loaded
