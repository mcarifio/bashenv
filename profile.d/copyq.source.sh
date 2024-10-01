${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

copyq.run() (
    set -Eeuo pipefail
    local _flatpak=com.github.hluk.copyq
    if u.have copyq ; then
        QT_QPA_PLATFORM=xcb command copyq "$@"
    elif flatpak.have ${_flatpak}; then
        QT_QPA_PLATFORM=xcb flatpak run ${_flatpak} "$@"
    else
        false || u.error "${FUNCNAME%%.*} not found"
    fi            
)
f.x copyq.run

# TODO mike@carif.io: fix this; invoke copyq.run() manually til then.
copyq.env() (
    copyq.run || return $(u.error "${FUNCNAME} failed") &
)
f.x copyq.env

sourced

