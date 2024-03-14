snap() (
    sudo command ${FUNCNAME} "$@"
)
f.complete snap

snapd.install() (
    dnf install epel-release || true
    systemctl enable --now snapd.socket || true
    sudo ln -s /var/lib/snapd/snap /snap || true
    &> /dev/null systemctl is-active snapd
)
f.complete snapd.install

snap.install() (
    snap install "$@"
)
f.complete snap.install
