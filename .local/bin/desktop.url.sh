#!/usr/bin/env bash

desktop.url() (
    set -Eeuo pipefail; shopt -s nullglob
    local _url="${1:?"${FUNCNAME} expecting a url"}"
    local _basename="${2:?"${FUNCNAME} expecting a .desktop basename"}"
    local _pathname="${XDG_DATA_HOME:-${HOME}/.local/share/applications}/${_basename}.desktop"
    install --mode=0775 /dev/stdin "${_pathname}" <<EOF
[Desktop Entry]
Version=1.0
Type=Link
Name=${_basename}
URL=${_url}
Icon=web-browser
EOF
    >&2 echo "'${_pathname}' created"    
)
declare -fx desktop.url

[[ "${BASH_SOURCE[0]}" == "$0" ]] && $(basename $0 .sh) "$@"

