#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh

u.have git || install.dnf git
git clone https://github.com/asdf-vm/asdf.git ~/opt/asdf/current --branch v0.14.1
_guard="$(realpath -Lm $(u.here)/..)/$(path.basename $0).guard.sh"
[[ -r "${_guard}" ]] && >&2 echo "guard ${_guard} ## next step"



