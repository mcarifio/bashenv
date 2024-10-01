${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

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

sourced
