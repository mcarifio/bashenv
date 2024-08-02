# assume path.sh sourced
path.add ~/.cargo/bin

cargo.update.all() (
    set -Eeuo pipefail
    install.cargo cargo-update || true
    # for p in $(cargo install --list | grep -o '^[^ ]*'); do
    #     cargo install $p || true
    # done
    cargo install-update -a
)
f.x cargo.update.all




