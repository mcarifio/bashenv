# usage: [guard | source] bcompare.guard.sh [--install] [--verbose] [--trace]
_guard=$(path.basename ${BASH_SOURCE})
declare -A _option=([install]=0 [verbose]=0 [trace]=0)
_undo=''; trap -- 'eval ${_undo}; unset _option _undo; trap -- - RETURN' RETURN
local -a _rest=( $(u.parse _option "$@" )
if (( ${_option[trace]} )) && ! bashenv.is.tracing; then
    _undo+='set +x;'
    set -x
fi
if (( ${_option[install]} )); then
    if u.have ${_guard}; then
        >&2 echo ${_guard} already installed
    else
        u.bad "${BASH_SOURCE} --install # not implemented"
    fi
fi

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


