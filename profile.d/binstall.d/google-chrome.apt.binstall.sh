#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# [--ppa=]* [--uri=]* [--suite=]* [--component=]* [_components=]* [--signed-by=]* [--pkg=]* [--cmd=*] [--check]
echo 'deb [arch=amd64 signed-by=/usr/share/keyring/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
binstall.$(path.basename.part $0 1) \
         --signed-by=https://packages.cloud.google.com/apt/doc/apt-key.gpg \
         --pkg=$(path.basename "$0") \
         --check "$@"
# post install
