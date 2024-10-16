#!/usr/bin/env bash

source.all $(realpath -Lm $(u.here)/..)/$(path.basename.part $0 2).source.sh $(u.here)/binstalld.lib.sh 
binstalld.dispatch --kind=$(path.basename.part "$0" 1) --pkg=$(path.basename "$(realpath -Lm "$0")") "$@"


