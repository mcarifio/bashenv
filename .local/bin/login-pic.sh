#!/usr/bin/env bash

set -Eeuo pipefail; shopt -s nullglob

main() (
    local _png="${1:-${HOME}/Pictures/$(hostname).png}"
    local _tmp="/tmp/$(basename ${_png})"
    convert -size 512x512 -background white -fill black -gravity center -pointsize 128 label:"$(hostname)" "${_tmp}"
    cp -v --backup=numbered "${_tmp}" "${_png}"
    # TODO mike@carif.io: deduce the correct gsetting. this one's wrong.
    gsettings set org.gnome.desktop.account picture-uri "file://$(realpath ${_png})" || return $(u.error "${_png} needs manual setup")
)

main "$@"

