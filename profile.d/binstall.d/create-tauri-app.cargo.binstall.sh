#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/binstalld.lib.sh

_kind="$(path.basename.part "$0" 1)"
_pkg="$(path.basename "$(realpath -Lm "$0")")"
_cmd="cargo-${_pkg}"

_os_release=$(os-release.id)
case ${_os_release} in
    fedora) dnf install webkit2gtk4.1-devel openssl-devel curl wget file libappindicator-gtk3-devel librsvg2-devel ;;
    ubuntu) >&2 echo "${_os_release} prerequisites for ${_pkg} needed? Continuing..." ;;
    *) >&2 echo "${_os_release} prerequisites for ${_pkg} needed? Continuing..." ;;
esac

binstalld.dispatch --kind=""${_kind}" \
                   --pkg="${_pkg}" \
                   --cmd="${_cmd}" \
                   --version "^2.0.0" "$@"

path.alias ${_cmd} tauri



