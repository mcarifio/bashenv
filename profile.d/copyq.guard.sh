copyq() (
     QT_QPA_PLATFORM=xcb command copyq "$@"
)
f.complete copyq

copyq.session() (
    true || u.error
)
f.complete copyq.session
copyq.session

