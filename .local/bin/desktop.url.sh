#!/usr/bin/env bash

desktop.url() (
    set -Eeuo pipefail; shopt -s nullglob
    local _url="${1:?"${FUNCNAME} expecting a url"}"
    local _basename=${_url##*/}; _basename=${_basename%*.}
    local _pathname="${XDG_DESKTOP:-${HOME}/Desktop}/${_basename}.desktop"
    install --mode=0775 /dev/stdin "${_pathname}" <<EOF
[Desktop Entry]
Version=1.0
Type=Link
Name=${_basename}
URL=${_url}
Icon=web-browser
EOF
    >&2 echo "Created '${_pathname}'"    
)
declare -fx desktop.url

[[ "${BASH_SOURCE[0]}" == "$0" ]] && $(basename $0 .sh) "$@"

