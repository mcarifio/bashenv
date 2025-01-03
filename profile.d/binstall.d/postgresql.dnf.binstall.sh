#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh

hash() (
    printf md5
    echo -n ${1:?"${FUNCNAME} expecting a password"}${2:-${USER}} | md5sum | cut -d' ' -f1
)

main() (
    # kind of installer to run
    local _kind=$(path.basename.part "$0" 1)
    # keys to import with rpm --import
    local -a _imports=()
    # repos to addrepo (urls)
    local -a _repos=()
    # coprs to add in ${owner}/${pkg} format
    local -a _coprs=()
    # packages to install
    local -a _pkgs=( $(path.basename "$0"){,-server} )
    # commands to test after installation
    local -a _cmds=()

    binstall.${_kind:-dnf} \
             $(u.switches import ${_imports[@]}) \
             $(u.switches add-repo ${_repos[@]}) \
             $(u.switches copr ${_coprs[@]}) \
             $(u.switches pkg ${_pkgs[@]}) \
             $(u.switches cmd ${_cmds[@]}) \
             "$@"

    # postinstall here
    sudo systemctl enable --now postgresql
    for _u in ${USER} root; do
        sudo -u postgres createuser --echo --superuser ${_u} || true
        sudo -u postgres psql -c "alter user ${_u} WITH password '$(hash 123456 ${_u})';" || true
    done
    sudo cp /var/lib/pgsql/data/pg_hba{,.dist}.conf
    sudo xz /var/lib/pgsql/data/pg_hba.dist.conf
    # sed 's/127.0.0.1\/32\s+ident/127.0.0.1\/32\ttrust/;s/::1/128\s+ident/::1/128\ttrust/' /var/lib/pgsql/data/pg_hba.conf
    # TODO mike@carif.io: ssh configuration
    sudo systemctl restart postgresql
    for _u in ${USER} root; do
        local _pu=$(psql -tA --quiet --username=${_u} psql --command='select current_user from user;')
        [[ "${_u}" = "${_pu}" ]] || >&2 echo "warning psql expecting user ${_u}, got user ${_pu}, continuing..."
    done
)

main "$@"
