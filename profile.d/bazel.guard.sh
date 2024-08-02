# usage: [guard | source] ${guard}.guard.sh [--install] [--verbose] [--trace]
# creation: guard=something envsubst < _template.guard.sh > something.guard.sh

# Front matter. Parse the source command line. Install by platform if --install,
# trace (and revert) if --trace.
_guard=$(path.basename ${BASH_SOURCE})

# not working
_bazel.parse() (
    : '## example: parse callers arglist'
    set -uEeo pipefail
    shopt -s nullglob
    declare -A _bazel_options=([file]="${PWD}/${FUNCNAME}" [comment]="${HOSTNAME}:and_some_stuff" [trace]=0)
    local -a _rest=( $(u.parse _bazel_options --foo=bar --user=${USER} --trace 1 2 3) )
    printf '%s ' ${FUNCNAME}; declare -p _bazel_options; printf '%s ' ${_rest[@]}
)

# TODO mike@carif.io: logic needs fixing
f.x _bazel.parse


bazel.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x bazel.env

bazel.session() {
    local _root="$(asdf which bazel)"
    local _completion="${_root%%/bin/bazel}/lib/bazel/bin/bazel-complete.bash"
    source ${_completion} || return $(u.error "${FUNCNAME} failed loading ${_completion}")
}
f.x bazel.session

loaded "${BASH_SOURCE}"
