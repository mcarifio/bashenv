#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh
binstalld.dispatch --kind=$(path.basename.part "$0" 1) --pkg=$(path.basename "$(realpath -Lm "$0")")-ce --pkg=docker-ce-cli --pkg=containerd.io --pkg=docker-buildx-plugin --pkg=docker-compose-plugin --signed-by=https://download.docker.com/linux/ubuntu/gpg --component=$(os-release.version_codename) --component=stable --uri=https://download.docker.com/linux/ubuntu --name=$(path.basename.part "$0") "$@"

