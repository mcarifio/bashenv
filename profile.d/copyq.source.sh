${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0


# is "my" copyq running?
copyq.running() ( pgrep -U $(id -u) -x ${FUNCNAME%.*} &> /dev/null; )

copyq.run() (
    set -Eeuo pipefail; shopt -s nullglob

    copyq.running && return 0
    
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
    [[ -z "${DISPLAY}" ]] && return $(u.error "${FUNCNAME} need a windowing system") 1
    copyq.run || return $(u.error "${FUNCNAME} failed") &
)
f.x copyq.env

sourced

