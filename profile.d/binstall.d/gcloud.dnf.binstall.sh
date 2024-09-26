#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh
binstalld.dispatch --kind=$(path.basename.part "$0" 1) --pkg=google-cloud-cli --import=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg --add-repo=https://packages.cloud.google.com/yum/repos/cloud-sdk-el9-$(arch) libxcrypt-compat.$(arch) "$@"


