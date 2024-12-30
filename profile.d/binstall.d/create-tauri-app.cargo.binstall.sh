#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh
_pkg="$(path.basename "$(realpath -Lm "$0")")"
_cmd="cargo-${_pkg}"

_os_release=$(os-release.id)
case ${_os_release} in
    fedora) dnf install webkit2gtk4.1-devel openssl-devel curl wget file libappindicator-gtk3-devel librsvg2-devel;;
    ubuntu) >&2 echo "${_os_release} prerequisites for ${_pkg} needed, continuing...";;
esac

binstalld.dispatch --kind=$(path.basename.part "$0" 1) \
                   --pkg="${_pkg}" \
                   --cmd="${_cmd}" \
                   --version "^2.0.0" "$@"

path.alias ${_cmd} tauri



