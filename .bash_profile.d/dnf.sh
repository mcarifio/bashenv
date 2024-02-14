realpath /proc/$$/exe | grep -Eq 'bash$' || return 0

# dnf and decl must come first
# https://unix.stackexchange.com/questions/403181/how-to-pin-a-package-in-dnf-fedora
# dnf install 'dnf-command(versionlock)'
dnf() (
    : "sudo dnf ..."
    sudo /usr/bin/dnf "$@" -y --allowerasing
); declare -fx dnf

dnf.src.rpm() (
  : "${FUNCNAME[0]} \${src.rpm} [\${destination_dir:-$PWD/src.rpm}] # extract source rpm to an (optional) destination directory"
  local _src_rpm=${1:?'expecting a package or .src.rpm file'}
  local _file_src_rpm=''
  [[ -r ${_src_rpm} ]] && _file_src_rpm=$(file --brief ${_src_rpm} | cut -f1 -d' ') # RPM

  # if the .src.rpm isn't local...
  if [[ "${_file_src_rpm}" != RPM ]] ; then
    # ... then fetch it first.
    _src_rpm=${_src_rpm%.src.rpm}
    local _destdir=/tmp/${FUNCNAME[0]}
    dnf download --source --destdir ${_destdir} ${_src_rpm} || return 1
    _src_rpm=${_destdir}/$(dnf repoquery --qf "%{SOURCERPM}" ${_src_rpm})
  fi
  _destdir=${2:-${PWD}/${_src_rpm%.rpm}} # where to extract the .src.rpm
  _src_rpm=$(realpath ${_src_rpm})
  sudo chown ${USER}:${USER} -R ${_src_rpm}
  rpm2cpio ${_src_rpm} | 2>/dev/null cpio -idm -D ${_destdir}
  for _tar in ${_destdir}/*.tar.* ${_destdir}/*.t?z; do &> /dev/null tar -xaf --one-top-level -C "${_destdir}" "${_tar}"; done
  >&2 ${_src_rpm} extracted to ${_destdir}
); declare -fx dnf.src.rpm



dnf.files() (
    : "dnf.files lists all files for a package; see also rpm -ql ${package}"
    command dnf repoquery --installed -l ${1:?'expecting a package'}
); declare -fx dnf.files

# lock the kernel to a specific version. update in a more controlled way.
dnf.lock-kernel() (
    local _v=${1:-$(uname -r)}
    sudo dnf versionlock kernel-${_v} kernel-{core,modules,devel,tools,abi-stablelists}-${_v}
); declare -fx dnf.local-kernel

# what package does a command come from?
dnf.for() (
    rpm -qf $(type -p ${1:?'expecting a command'}) --qf '%{NAME}'
); declare -fx dnf.for

rpm.extract() {
    local _rpm_file=${1:?'expecting an rpm file'}
    rpm2cpio ${_rpm_file} | cpio -idmv
}; declare -fx rpm.extract

dnf.from() (
    : "dnf.from returns the repo id a package originated from"
    dnf repoquery --qf "%{repoid}" ${1:?'expecting a package'}
); declare -fx dnf.from



fc.upgrade() (
    local -i _next_version=${1:-$(( $(os-release.version) + 1 ))}
    >&2 echo "upgrade from version $(os-release.version) to ${_next_version}"
    dnf upgrade --allowerasing -y
    dnf install dnf-plugin-system-upgrade -y
    dnf system-upgrade download -y --nogpgcheck --releasever=${_next_version}
    dnf system-upgrade reboot
); declare -fx fc.upgrade
