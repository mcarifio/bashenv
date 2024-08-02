# usage: [guard | source] bcompare.guard.sh [--install] [--verbose] [--trace]
_guard=$(path.basename ${BASH_SOURCE})

bcompare() (
    QT_GRAPHICSSYSTEM=native command bcompare "$@"
)
f.complete bcompare

bcompare.session() {
    true || $(u.error "${FUNCNAME} failed")
}
f.complete bcompare.session
bcompare.session

loaded "${BASH_SOURCE}"


