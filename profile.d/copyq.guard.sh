copyq() (
     QT_QPA_PLATFORM=xcb command copyq "$@"
)
f.x copyq

copyq.session() (
    true || return $(u.error "${FUNCNAME} failed")
)
f.x copyq.session
copyq.session

loaded "${BASH_SOURCE}"
