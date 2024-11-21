#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh
binstalld.dispatch --kind=$(path.basename.part "$0" 1) --pkg=arangodb3 --import=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg --add-repo=https://download.arangodb.com/arangodb312/RPM/arangodb.repo --no-best --allowerasing arangodb3-client "$@" # arangodb3-client 


