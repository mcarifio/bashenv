#!/usr/bin/env bash
set -Eeuo pipefail

install() (
    local _appimage=$(install.AppImage "$@")
    install.check ${_appimage} || return $(u.error "Could not install ${_appimage}")
)
install cursor file://$(f.newest "~/Downloads/cursor-*.AppImage")
