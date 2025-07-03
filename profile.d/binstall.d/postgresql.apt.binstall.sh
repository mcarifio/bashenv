#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# [--ppa=]* [--uri=]* [--suite=]* [--component=]* [_components=]* [--signed-by=]* [--pkg=]* [--cmd=*] [--check]
binstall.$(path.basename.part $0 1) \
         --signed-by=https://www.postgresql.org/media/keys/ACCC4CF8.asc \
         --uri=http://apt.postgresql.org/pub/repos/apt \
         --component=plucky-pgdg --component=main \
         --pkg=$(path.basename "$0") 
# post install

postinstall() (
    sudo systemctl enable --now postgresql
    for _u in "$@"; do
        sudo -u postgres psql -c "CREATE ROLE ${_u} WITH LOGIN PASSWORD '123456' SUPERUSER;"
        sudo -u ${_u} psql -c "select current_user from user;"
    done
)

postinstall root ${USER}

