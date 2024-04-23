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


# TODO mike@carif.io: fix this; invoke copyq.run() manually til then.
copyq._session() (
    copyq.run || return $(u.error "${FUNCNAME} failed") &
)
f.x copyq._session
# u.singleton copyq.session

loaded "${BASH_SOURCE}"
