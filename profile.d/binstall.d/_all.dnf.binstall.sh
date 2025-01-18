#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh


# yuck
sudo tee -a /etc/yum.repos.d/vscodium.repo << EOF
[gitlab.com_paulcarroty_vscodium_repo]
name=download.vscodium.com
baseurl=https://download.vscodium.com/rpms/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
metadata_expire=1h
EOF


# [--import=]* [--repo=]* [--copr=]* [--pkg=]* [--cmd=]*
# --skip-unavailable if some packages are missing
_installer=$(path.basename.part $0 1)
binstall.${_installer} $(binstall.external-switches "$0" import repo copr pkg cmd) "$@" || \
    u.warn "$0@${LINENO}: ${_installer} => $?, continuing... "
# post install

# if you installed the docker service
if systemctl list-unit-files | grep docker; then
    >&2 echo "$0@${LINENO}: Looks like docker was installed. Configuring..."
    sudo systemctl enable --now docker || { journalctl --no-pager -xeu docker; u.warn "$0@${LINENO}: docker service not enabled, continuing..."; }
    sudo systemctl enable --now containerd || { journalctl --no-pager -xeu containerd; u.warn "$0@${LINENO}: containerd service not enabled, continuing..."; }
    sudo usermod -aG docker $USER || true
    systemctl status --no-pager --output=short docker
    systemctl status --no-pager --output=short containerd
fi


# if you installed the postgresql server
if systemctl list-unit-files | grep postgresql; then
    >&2 echo "$0@${LINENO}: Looks like postgresql-server was installed. Configuring..."
    sudo postgresql-setup --initdb || true
    sudo systemctl enable --now postgresql || { journalctl --no-pager -xeu postgresql; exit $(u.error "$0@${LINENO}: cannot enable the postgresql service"); }

    hash() (
        printf md5
        echo -n ${1:?"${FUNCNAME}@${LINENO}: expecting a password"}${2:-${USER}} | md5sum | cut -d' ' -f1
    )


    for _u in ${USER} root; do
        sudo -u postgres createuser --echo --superuser ${_u} || true
        sudo createdb --owner=${_u} ${_u} || true
        sudo -u postgres psql -c "alter user ${_u} WITH password '$(hash 123456 ${_u})';" || true
    done

    sudo systemctl stop postgresql || { journalctl --no-pager -xeu postgresql; exit $(u.error "$0@${LINENO}: cannot stop the postgresql service"); }
    
    sudo cp -v --backup=numbered /var/lib/pgsql/data/pg_hba{,.dist}.conf
    sudo xz --force /var/lib/pgsql/data/pg_hba.dist.conf
    # sed 's/127.0.0.1\/32\s+ident/127.0.0.1\/32\ttrust/;s/::1/128\s+ident/::1/128\ttrust/' /var/lib/pgsql/data/pg_hba.conf
    # TODO mike@carif.io: ssh configuration
    sudo systemctl restart postgresql || { journalctl --no-pager -xeu postgresql; exit $(u.error "$0@${LINENO}: cannot restart the postgresql service"); }

    _pu=$(psql -tA --quiet --username=${USER} --command='select current_user from user;')
    [[ "${USER}" = "${_pu}" ]] || >&2 u.warn "$0@${LINENO}:warning psql expecting user ${USER}, got user ${_pu}, continuing..."

    >&2 echo "$0@${LINENO}: postgresql configuration complete"
fi    




