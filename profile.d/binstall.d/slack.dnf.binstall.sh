#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh
binstalld.dispatch --kind=$(path.basename.part "$0" 1) --pkg=$(path.basename "$(realpath -Lm "$0")") --url="https://downloads.slack-edge.com/desktop-releases/linux/x64/4.39.95/slack-4.39.95-0.1.el8.x86_64.rpm" "$@"


