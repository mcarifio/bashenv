#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh

# https://cloud.google.com/sdk/docs/install-sdk#rpm
exit $(u.error "$0 does not work" 1) 
binstalld.dispatch --kind=$(path.basename.part "$0" 1) \
                   --import=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg \
                   --add-repo=https://packages.cloud.google.com/yum/repos/cloud-sdk-el9-$(arch) \
                   --pkg=google-cloud-cli \
                   --pkg=libxcrypt-compat.$(arch) "$@"


