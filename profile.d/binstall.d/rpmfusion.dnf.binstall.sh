#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh



# https://rpmfusion.org/Configuration
dnf config-manager setopt fedora-cisco-openh264.enabled=1

binstalld.dispatch --kind=$(path.basename.part "$0" 1) \
                   --pkg=https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm "$@"
binstalld.dispatch --kind=$(path.basename.part "$0" 1) \
                   --pkg=https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm "$@"


