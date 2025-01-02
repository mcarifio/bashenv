#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh

# https://linuxconfig.org/how-to-monitor-file-integrity-on-linux-using-osquery
binstalld.dispatch --kind=$(path.basename.part "$0" 1) \
		   --import=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg \
                   --add-repo=https://pkg.osquery.io/rpm/osquery-s3-rpm.repo \
                   --pkg=$(path.basename "$(realpath -Lm "$0")") \
		   "$@"


