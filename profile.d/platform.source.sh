# usage: [guard | source] template.guard.sh [--install] [--verbose] [--trace]

# Front matter. Parse the source command line. Install by platform if --install,
# trace (and revert) if --trace.
_guard=$(path.basename ${BASH_SOURCE})

# not working
platform.parse() (
    : '## example: parse callers arglist'
    set -uEeo pipefail
    shopt -s nullglob
    declare -A platform_options=([file]="${PWD}/${FUNCNAME}" [comment]="${HOSTNAME}:and_some_stuff" [trace]=0)
    local -a _rest=( $(u.parse platform_options --foo=bar --user=${USER} --trace 1 2 3) )
    printf '%s ' ${FUNCNAME}; declare -p platform_options; printf '%s ' ${_rest[@]}
)
# TODO mike@carif.io: logic needs fixing
f.x platform.parse


platform.upgrade() (
    set -uo pipefail

    # rpm-ostree | dnf upgrade first, might effect what's above it.
    u.have rpm-ostree && sudo $(type -P rpm-ostree) upgrade || dnf upgrade --allowerasing

    # TODO mike@carif.io: how to upgrade jetbrains via their toolbox without human intervention?
    local _jetbrains_toolbox="${HOME}/.local/share/JetBrains/Toolbox/bin/jetbrains-toolbox"
    [[ -x "${_jetbrains_toolbox}" ]] && >&2 echo "${_jetbrains_toolbox} upgrade # tbs"

    u.have snap && snap refresh
    u.have cargo && cargo.update.all
    u.have brew && brew update -y
    u.have flatpak && flatpak upgrade -y
)
f.x platform.upgrade




platform.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x platform.env

platform.session() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x platform.session

loaded "${BASH_SOURCE}"
