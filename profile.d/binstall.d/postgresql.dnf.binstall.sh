#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh

hash() (
    printf md5
    echo -n ${1:?'expecting a password}${2:-${USER}} | md5sum | cut -d' ' -f1
)

post.install() (
    sudo systemctl enable --now postgresql
    for _u in ${USER} root; do
        sudo -u postgres createuser --echo --superuser ${_u}
        sudo -u postgres psql -c "alter user ${_u} WITH password '$(hash 123456 ${_u})';"
    done
    sudo cp /var/lib/pgsql/data/pg_hba{,.dist}.conf
    sudo xz /var/lib/pgsql/data/pg_hba.dist.conf
    # sed 's/127.0.0.1\/32\s+ident/127.0.0.1\/32\ttrust/;s/::1/128\s+ident/::1/128\ttrust/' /var/lib/pgsql/data/pg_hba.conf
    # TODO mike@carif.io: ssh configuration
    sudo systemctl restart postgresql
)
binstall.dnf --url="https://download.postgresql.org/pub/repos/yum/reporpms/F-$(os-release.major)-$(arch)/pgdg-$(os-release.id)-repo-latest.noarch.rpm"
binstalld.dispatch --kind=$(path.basename.part "$0" 1) --pkg=$(path.basename "$(realpath -Lm "$0")") --postinstall=post.install postgresql-server "$@"


