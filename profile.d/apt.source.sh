${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

apt() (
    sudo $(type -P ${FUNCNAME}) "$@"
    sudo apt-mark auto "$@"
)
f.x apt

apt.btrfs.snapshots() (
    btrfs subvolume list /snapshots/apt/prehook
    echo "installations:"
    printf '\t%s\n' /snapshots/apt/prehook/*/packages.list.log
)
f.x apt.btrfs.snapshots

apt.src.deb() (
  : '${src_rpm} [${destination_dir:-$PWD/src.rpm}] # extract source rpm to an (optional) destination directory'
  local _src_rpm=${1:?'expecting a package or .src.rpm file'}
  local _file_src_rpm=''; [[ -r ${_src_rpm} ]] && _file_src_rpm=$(file --brief ${_src_rpm} | cut -f1 -d' ') # RPM

  # if the .src.rpm isn't local...
  if [[ "${_file_src_rpm}" != RPM ]] ; then
    # ... then fetch it first.
    _src_rpm=${_src_rpm%.src.rpm}
    local _destdir=/tmp/${FUNCNAME}
    command dnf download --source --destdir ${_destdir} ${_src_rpm} || return 1
    _src_rpm=${_destdir}/$(dnf repoquery --qf "%{SOURCERPM}" ${_src_rpm})
  fi
  _destdir=${2:-${PWD}/${_src_rpm%.rpm}} # where to extract the .src.rpm
  _src_rpm=$(realpath ${_src_rpm})
  sudo chown ${USER}:${USER} -R ${_src_rpm}
  rpm2cpio ${_src_rpm} | 2>/dev/null cpio -idm -D ${_destdir}
  for _tar in ${_destdir}/*.tar.* ${_destdir}/*.t?z; do &> /dev/null tar -xaf --one-top-level -C "${_destdir}" "${_tar}"; done
  >&2 echo "${_src_rpm} extracted to ${_destdir}"
)
f.x apt.src.deb

apt.installedp() (
    : '${_pkg}* ## returns 0 iff all packages installed'
    command dpkg-query --show "$@" &> /dev/null
)
f.x apt.installedp

apt.installed() (
    : '${_pkg}* ## returns 0 iff all packages installed'
    command dpkg-query --show --showformat '${Package}\n' "$@"
)
f.x apt.installed

apt.files() (
    : ' ${_pkg} # lists all files for a package; see also rpm -ql ${_pkg}'
    command dpkg --listfiles ${1:?'expecting a package'}
)
f.x apt.files

# lock the kernel to a specific version. update in a more controlled way.
apt.lock-kernel() (
    local _v=${1:-$(uname -r)}
    sudo dnf versionlock kernel-${_v} kernel-{core,modules,devel,tools,abi-stablelists}-${_v}
)
f.x apt.lock-kernel

# what package does a command come from?
apt.from() (
    : '${_cmd} # what package does ${_cmd} come from?'
    dpkg --search $(type -P ${1:?'expecting a command'})
)
f.x apt.from

deb.extract() {
    local _rpm_file=${1:?'expecting an rpm file'}
    rpm2cpio ${_rpm_file} | cpio -idmv
}
f.x deb.extract

apt.release-upgrade() (
    set -Eeuo pipefail; shopt -s nullglob
    local -i _next_version=${1:-$(( $(os-release.version) + 1 ))}
    >&2 echo "upgrade from version $(os-release.version) to ${_next_version}"
    u.have do-release-upgrade || apt install update-manager-core
    sudo do-release-upgrade 
    >&2 echo 'sudo reboot ## next'
)
f.x apt.release-upgrade

apt.missing() (
    for _p in "$@"; do
        apt.installedp ${_p} || echo -n "${_p} "
    done
)
f.x apt.missing

apt.install.missing() (
    binstall.apt $(u.switches pkg $(apt.missing "$@"))
)
f.x apt.install.missing

sourced || true



