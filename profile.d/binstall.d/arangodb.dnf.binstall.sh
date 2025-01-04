#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh

# https://docs.arangodb.com/3.13/get-started/on-premises-installation/
# https://hub.docker.com/_/arangodb/
# --import= --repo= --copr= --pkg= --cmd=
binstall.$(path.basename.part $0 1) \
         --import=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg \
         --repo=https://download.arangodb.com/arangodb312/RPM/arangodb.repo \
         --pkg=$(path.basename "$0") "$@"
