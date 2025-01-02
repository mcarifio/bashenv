#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh
binstalld.dispatch --kind=$(path.basename.part "$0" 1) --pkg=vivaldi-stable --add-repo=https://repo.vivaldi.com/archive/vivaldi-fedora.repo  "$@"


