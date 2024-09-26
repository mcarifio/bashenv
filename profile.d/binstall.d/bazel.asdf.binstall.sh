#!/usr/bin/env bash
# dnf copr vbatts/bazel
source $(u.here)/binstalld.lib.sh
binstalld.dispatch --kind=$(path.basename.part $0 1) --pkg=$(path.basename $0)


