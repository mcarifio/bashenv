#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# binstall.dnf --pkg=mesa-libGL mesa-libGLU mesa-dri-drivers mesa-vulkan-drivers mesa-libEGL mesa-libgbm
# --url= --pkg= --cmd=
binstall.$(path.basename.part $0 1) \
         --url=https://github.com/FreeCAD/FreeCAD/releases/download/0.21.2/FreeCAD-0.21.2-Linux-x86_64.AppImage \
         --pkg=$(path.basename "$0") \
         "$@"
# post install
