#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# --import= --repo= --copr= --pkg= --cmd=
binstall.$(path.basename.part $0 1) \
         --import=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg \
         --add-repo=https://packages.cloud.google.com/yum/repos/cloud-sdk-el9-$(arch) \
         --pkg=$(path.basename "$0") \
         --pkg=libxcrypt-compat.$(arch) \
         "$@"
# post install





#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh

# https://cloud.google.com/sdk/docs/install-sdk#rpm
exit $(u.error "$0 does not work" 1) 
binstalld.dispatch --kind=$(path.basename.part "$0" 1) \
                   --import=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg \
                   --add-repo=https://packages.cloud.google.com/yum/repos/cloud-sdk-el9-$(arch) \
                   --pkg=google-cloud-cli \
                   --pkg=libxcrypt-compat.$(arch) "$@"


