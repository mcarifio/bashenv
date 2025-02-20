#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# https://code.visualstudio.com/docs/setup/linux
# [--debconf=] [--ppa=]* [--uri=]* [--suite=]* [--component=]* [_components=]* [--signed-by=]* [--pkg=]* [--cmd=*] [--check]
binstall.$(path.basename.part $0 1) \
         --debconf="code code/add-microsoft-repo boolean true" \
         --pkg="https://vscode.download.prss.microsoft.com/dbazure/download/stable/e54c774e0add60467559eb0d1e229c6452cf8447/code_1.97.2-1739406807_amd64.deb"
# post install
