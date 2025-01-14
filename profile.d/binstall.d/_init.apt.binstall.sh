#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# [--uri=]* [--suite=]* [--component=]* [_components=]* [--signed-by=]* [--pkg=]* [--check] [--cmd=*]
binstall.$(path.basename.part $0 1) \
         $(u.switches pkg tree curl emacs doas keepassx plocate thunderbird terminator mtools dosfstools gparted \
                      btrfs-{assistant,progs} chromium-browser etherwake eza foliate fzf gthumb hardinfo2 krita meld obs-studio okular pandoc \
                      python-is-python3 ripgrep solaar tldr torbrowser-launcher vlc xonsh zoxide ) \
         "$@"
# post install
