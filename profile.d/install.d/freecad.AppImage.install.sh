#!/usr/bin/env bash
set -Eeuo pipefail; shopt -s nullglob
[[ "$0" = */bashdb ]] && shift
source $(dirname "$0")/_defaults.install.sh # override these as needed

_install dnf mesa-libGL mesa-libGLU mesa-dri-drivers mesa-vulkan-drivers mesa-libEGL mesa-libgbm
_installx --kind=$(path.basename.part "$0" 1) --pkg=$(path.basename "$0") https://github.com/FreeCAD/FreeCAD/releases/download/0.21.2/FreeCAD-0.21.2-Linux-x86_64.AppImage "$@"

