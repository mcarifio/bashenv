#!/usr/bin/env bash
set -Eeuo pipefail

# ${guard}.install.sh will install ${guard} in various ways. You'll choose and
# then customize the one you want, typically by modifying `install()` to call
# the right helper function, e.g. `glab.install.sh` calls bash function `install()`
# which calls `install.asdf()`. It's a little crufty with all the boilerplate,
# but the script and functions are short.

# install {_template,${guard}}.install.sh



post.install() (
    sudo systemctl enable --now postgresql
    for _u in ${USER} root; do
        sudo -u postgres createuser --echo --superuser ${_u}
        sudo -u postgres psql -c "alter user ${_u} WITH password '123456';"
    done
    sudo cp /var/lib/pgsql/data/pg_hba{,.dist}.conf
    sudo xz /var/lib/pgsql/data/pg_hba.dist.conf
    # sed 's/127.0.0.1\/32\s+ident/127.0.0.1\/32\ttrust/;s/::1/128\s+ident/::1/128\ttrust/' /var/lib/pgsql/data/pg_hba.conf
    # TODO mike@carif.io: ssh configuration
    sudo systemctl restart postgresql
)
    



# install() ( install.$(os.release ID) "$@"; )
install() (
    install.distro "$@"
    post.install "$@"
)

# install "$@"
# install $(path.basename ${BASH_SOURCE}) "$@"
install $(path.basename ${BASH_SOURCE}) "$@"

