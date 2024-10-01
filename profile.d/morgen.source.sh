${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

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

sourced || true
