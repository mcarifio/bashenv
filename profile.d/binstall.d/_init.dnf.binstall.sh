#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# [--import=]* [--repo=]* [--copr=]* [--pkg=]* [--cmd=]*
binstall.$(path.basename.part $0 1) \
         $(u.switches pkg tree curl emacs doas keepassx plocate thunderbird terminator mtools dosfstools gparted) \
         "$@"
# post install





