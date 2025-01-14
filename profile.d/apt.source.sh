${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

apt() (
    sudo $(type -P ${FUNCNAME}) -y "$@"
)

f.x apt

# do the rest below later
return 0

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



apt.files() (
    : ' ${_pkg} # lists all files for a package; see also rpm -ql ${_pkg}'
    command dpkg --listfiles ${1:?'expecting a package'}
)
f.x dnf.files

# lock the kernel to a specific version. update in a more controlled way.
apt.lock-kernel() (
    local _v=${1:-$(uname -r)}
    sudo dnf versionlock kernel-${_v} kernel-{core,modules,devel,tools,abi-stablelists}-${_v}
)
f.x apt.lock-kernel

# what package does a command come from?
deb.from() (
    : '${_cmd} # what package does ${_cmd} come from?'
    rpm -qf $(type -P ${1:?'expecting a command'}) --qf '%{NAME}'
)
f.x deb.from

deb.extract() {
    local _rpm_file=${1:?'expecting an rpm file'}
    rpm2cpio ${_rpm_file} | cpio -idmv
}
f.x deb.extract

apt.from() (
    : '{_cmd} # returns the repo id a package originated from'
    dnf repoquery --qf "%{repoid}" ${1:?'expecting a package'}
)
f.x apt.from

ubuntu.upgrade() (
    local -i _next_version=${1:-$(( $(os-release.version) + 1 ))}
    >&2 echo "upgrade from version $(os-release.version) to ${_next_version}"
    dnf upgrade --allowerasing -y
    dnf install dnf-plugin-system-upgrade -y
    dnf system-upgrade download -y --nogpgcheck --releasever=${_next_version}
    dnf system-upgrade reboot
)
f.x ubuntu.upgrade

ubuntu.id.last() (
    dnf history list last|tail -n1|cut -d'|' -f1
)
f.x ubuntu.id.last

apt.missing() (
    for _p in "$@"; do
        rpm -q ${_p} > /dev/null || echo -n "${_p} "
    done
)
f.x apt.missing

apt.install.missing() (
    local _missing=$(apt.missing "$@")
    if [[ -n "${_missing}" ]] ; then
        dnf upgrade --nobest --skip-broken
        dnf install --nobest --skip-broken ${_missing}
    fi
)
f.x apt.install

function apt.is-installed (
    : '${_pkg} ## returns 0 iff ${_pkg} is installed (works with versions)'
    dnf list installed ${1:?"${FUNCNAME} expecting a package"} &> /dev/null
)
f.x apt.is-installed

sourced || true



