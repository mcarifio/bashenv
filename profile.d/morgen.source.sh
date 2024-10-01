# usage: [guard | source] morgen.guard.sh [--install] [--verbose] [--trace]
_guard=$(path.basename ${BASH_SOURCE})
declare -A _option=([install]=0 [verbose]=0 [trace]=0)
_undo=''; trap -- 'eval ${_undo}; unset _option _undo; trap -- - RETURN' RETURN
local -a _rest=( $(u.parse _option "$@") )
if (( ${_option[trace]} )) && ! bashenv.is.tracing; then
    _undo+='set +x;'
    set -x
fi
if (( ${_option[install]} )); then
    if u.have ${_guard}; then
        >&2 echo ${_guard} already installed
    else
        # install snapd then install morgen
        case "$(os-release.id)" in
            fedora) dnf install snapd;;
            ubuntu) : ;;
            *) u.bad "${BASH_SOURCE} --install unknown for $(os-release.id)"
        esac
        snapd.install && snap.install morgen "$@"
    fi
fi

morgen.api.key() (
    : '#> mike@m00nlit.com api key, see https://platform.morgen.so/developers-api'
    echo "Yfg7dexl9GcGq+Uvm9WmCRvKkCLfnxTEDMkTLooRtcQ="
)
f.x morgen.api.key

morgen.run() (
    gio launch /var/lib/snapd/snap/morgen/current/meta/gui/morgen.desktop
)
f.x morgen.run

morgen.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x morgen.env

morgen.session() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x morgen.session

loaded "${BASH_SOURCE}"
