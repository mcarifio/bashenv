#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh

ASDF_NPM_DEFAULT_PACKAGES_FILE="$(pn.first ${ASDF_NPM_DEFAULT_PACKAGES_FILE} ${ASDF_DIR}/.default-npm-packages "$(home)/opt/asdf/current/.default-npm-packages)"\
 binstalld.dispatch --kind=$(path.basename.part "$0" 1) --pkg=$(path.basename "$(realpath -Lm "$0")") "$@"


