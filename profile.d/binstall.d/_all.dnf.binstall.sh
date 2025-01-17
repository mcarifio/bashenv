#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# [--import=]* [--repo=]* [--copr=]* [--pkg=]* [--cmd=]*

# _all.merged.binstall.sh and _all.dnf.binstall.sh.list contain the list of packages to install 
binstall.$(path.basename.part $0 1) \
         $(u.switches pkg $(< ${0//.$(path.basename.part $0 1)./.merged.}) $(< $0.list)) \
         "$@"
# post install





