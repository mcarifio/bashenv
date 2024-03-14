morgen.api.key() (
    : '#> mike@m00nlit.com api key, see https://platform.morgen.so/developers-api'
    echo "Yfg7dexl9GcGq+Uvm9WmCRvKkCLfnxTEDMkTLooRtcQ="
)
f.complete morgen.api.key

morgen.run() (
    gio launch /var/lib/snapd/snap/morgen/current/meta/gui/morgen.desktop
)
f.complete morgen

morgen.env() {
    # echo ${FUNCNAME}
    return 0 
}
f.complete morgan.env

# source (not guard) systemctl.guard.sh, snap.guard.sh, this file and run morgen.install()
morgen.install() (
    snapd.install && snap.install morgen "$@"
)
f.complete morgen.install

