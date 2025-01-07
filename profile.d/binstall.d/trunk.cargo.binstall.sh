#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh

_os_release=$(os-release.id)
case ${_os_release} in
    fedora) ;; # binstall.dnf --pkg=... ;;
    ubuntu) ;; # binstall.apt --pkg=... ;;
    *) ;; # >&2 echo "${_os_release} prerequisites for ${_pkg} needed? Continuing..." ;;
esac

# trunk installs yew-cli, see https://yew.rs/docs/getting-started/introduction
rustup target add wasm32-unknown-unknown
# --pkg= [--cmd=]*
binstall.$(path.basename.part $0 1) \
         --pkg=$(path.basename "$0") \
         "$@"
# post install

