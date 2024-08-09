# cargo.source.sh sources ~/.cargo/env which adds cargo to PATH. Don't assume it however.
path.add ~/.cargo/bin

cargo.update.all() (
    set -Eeuo pipefail
    install.cargo cargo-update || true
    cargo install-update -a
)
f.x cargo.update.all




