#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh
binstalld.dispatch --kind=$(path.basename.part "$0" 1) --pkg=$(path.basename "$0") --url="https://github.com/ptomato/jasmine-gjs/releases/download/3.10.1/jasmine-gjs-3.10.1-1.fc39.noarch.rpm" "$@"


