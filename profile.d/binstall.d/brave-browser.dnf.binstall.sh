#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh
binstalld.dispatch --kind=$(path.basename.part "$0" 1) --pkg=$(path.basename "$(realpath -Lm "$0")") \
		   --import=https://brave-browser-rpm-release.s3.brave.com/brave-core.asc \
		   --add-repo=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo \
		   "$@"


