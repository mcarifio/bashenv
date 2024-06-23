# wasmer.install.sh installs rust package `wasmer-cli` on all platforms.
install() (
    # local _id=$(os-release.id)
    # assume rust installed with rustup; rustup and cargo on PATH
    rustup upgrade
    cargo install wasmer-cli --features singlepass,cranelift
    >&2 echo "${BASH_SOURCE} installed on id ${_id}"
)

install "$@"

