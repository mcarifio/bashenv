path.add ~/.cargo/bin
${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

cargo.update.all() (
    set -Eeuo pipefail
    install.cargo cargo-update || true
    cargo install-update -a
)
f.x cargo.update.all

sourced



