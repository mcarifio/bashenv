${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

bcompare() (
    QT_GRAPHICSSYSTEM=native command bcompare "$@"
)
# f.complete bcompare
f.x bcompare

bcompare.session() {
    true || $(u.error "${FUNCNAME} failed")
}
f.x bcompare.session

sourced || true


