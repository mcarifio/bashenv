#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh

main() (

    # gross, https://linuxcapable.com/install-vscodium-on-fedora-linux/
    # rpmkeys --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
    printf "[gitlab.com_paulcarroty_vscodium_repo]\nname=download.vscodium.com\nbaseurl=https://download.vscodium.com/rpms/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg\nmetadata_expire=1h" | sudo tee -a /etc/yum.repos.d/vscodium.repo

    # kind of installer to run
    local _kind=$(path.basename.part "$0" 1)
    # keys to import with rpm --import
    local -a _imports=( https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg )
    # repos to addrepo (urls)
    local -a _repos=()
    # coprs to add in ${owner}/${pkg} format
    local -a _coprs=()
    # packages to install
    local -a _pkgs=( $(path.basename "$0") )
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
    true
)

main "$@"


#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh

# https://linuxconfig.org/how-to-monitor-file-integrity-on-linux-using-osquery
binstalld.dispatch --kind=$(path.basename.part "$0" 1) \
		   --import=https://pkg.osquery.io/rpm/GPG \
                   --add-repo=https://pkg.osquery.io/rpm/osquery-s3-rpm.repo \
                   --pkg=$(path.basename "$(realpath -Lm "$0")") \
		   "$@"


