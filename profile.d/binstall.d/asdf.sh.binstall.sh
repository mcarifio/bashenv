#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
u.have git || binstall.dnf git
git clone https://github.com/asdf-vm/asdf.git ~/opt/asdf/current --branch v0.14.1
source $(u.here)/../$(path.basename $0).source.sh"
binstall.check asdf
