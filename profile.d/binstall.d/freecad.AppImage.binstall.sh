#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh
binstall.dnf --pkg=mesa-libGL mesa-libGLU mesa-dri-drivers mesa-vulkan-drivers mesa-libEGL mesa-libgbm
binstalld.dispatch --kind=$(path.basename.part "$0" 1) --pkg=$(path.basename "$0") --url=https://github.com/FreeCAD/FreeCAD/releases/download/0.21.2/FreeCAD-0.21.2-Linux-x86_64.AppImage "$@"
