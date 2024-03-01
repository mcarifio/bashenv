snap() (
    sudo command ${FUNCNAME} "$@"
)
f.complete snap $(complete -p snap | cut -d' ' -f3)

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
