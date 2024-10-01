${1:-false} || u.have.all gh git || return 0
explore.mk() (
    : '${_topic} # creates gh:${USER}/explore.${_topic} in ~/explore/${_topic}'
    set -Eeuo pipefail
    local _topic=${1:?'expecting a topic'}; shift
    local _repo=explore.${_topic}
    local _folder="${HOME}/explore/${_topic}"
    gh repo create ${_repo} --public "$@" || true
    git clone gh:${USER}/${_repo} "${_folder}" || true
    [[ -d "${_folder}" && "${_folder}/.git" ]] && >&2 echo "Created topic ${_topic} in folder ${_folder} with git repo ${_repo}... "
)
f.x explore.mk # completion tbs


explore.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x explore.env

explore.session() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x explore.session

sourced || true
