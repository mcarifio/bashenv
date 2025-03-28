# https://unix.stackexchange.com/questions/403181/how-to-pin-a-package-in-dnf-fedora
# dnf install 'dnf-command(versionlock)'

${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

dnf() ( sudo $(type -P ${FUNCNAME}) --assumeyes $@; )
f.x dnf

dnf.gh.release-rpm() (
    local _owner_project=${1:?"${FUNCNAME} expecting a github owner/project"}
    local _release=${2:-latest}
    curl -s https://api.github.com/repos/${_owner_project}/releases/${_release} | jq -r '.assets[] | select(.name | endswith("x86_64.rpm")) | .browser_download_url'    
)
f.x dnf.gh.release-rpm;

dnf.find-pkgs() (
    : '${_name} |> return all pkgs names start with ${_name}'
    # example usage: binstall.dnf $(u.switches pkg $(dnf.find-pkgs p7zip))
    for _name in "$@"; do
        dnf list 2>/dev/null | awk "{if (match(\$1, /^(${_name}[^\\.]*)\\./, m)){ print m[1];}}"
    done
)
f.x dnf.find-pkgs

dnf.src.rpm() (
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
f.x dnf.src.rpm

dnf.files() (
    : ' ${_pkg} # lists all files for a package; see also rpm -ql ${_pkg}'
    command dnf repoquery --installed -l ${1:?'expecting a package'}
)
f.x dnf.files

# lock the kernel to a specific version. update in a more controlled way.
dnf.lock-kernel() (
    local _v=${1:-$(uname -r)}
    sudo dnf versionlock kernel-${_v} kernel-{core,modules,devel,tools,abi-stablelists}-${_v}
)
f.x dnf.lock-kernel

# what package does a command come from?
rpm.from() (
    : '${_cmd} # what package does ${_cmd} come from?'
    rpm -qf $(type -P ${1:?'expecting a command'}) --qf '%{NAME}'
)
f.x rpm.from

rpm.extract() {
    local _rpm_file=${1:?'expecting an rpm file'}
    rpm2cpio ${_rpm_file} | cpio -idmv
}
f.x rpm.extract

dnf.from() (
    : '{_cmd} # returns the repo id a package originated from'
    dnf repoquery --qf "%{repoid}" ${1:?'expecting a package'}
)
f.x dnf.from

fedora.upgrade() (
    local -i _next_version=${1:-$(( $(os-release.version) + 1 ))}
    >&2 echo "upgrade from version $(os-release.version) to ${_next_version}"
    dnf upgrade --allowerasing -y
    dnf install dnf-plugin-system-upgrade -y
    dnf system-upgrade download -y --nogpgcheck --releasever=${_next_version}
    dnf system-upgrade reboot
)
f.x fedora.upgrade

dnf.id.last() (
    dnf history list last|tail -n1|cut -d'|' -f1
)
f.x dnf.id.last

dnf.missing() (
    for _p in "$@"; do
        rpm -q ${_p} > /dev/null || echo -n "${_p} "
    done
)
f.x dnf.missing

dnf.install() (
    local _missing=$(dnf.missing "$@")
    if [[ -n "${_missing}" ]] ; then
        dnf upgrade --nobest --skip-broken
        dnf install --nobest --skip-broken ${_missing}
    fi
)
f.x dnf.install

dnf.is-installed() (
    : '${_pkg} ## returns 0 iff ${_pkg} is installed (works with versions)'
    dnf list installed ${1:?"${FUNCNAME} expecting a package"} &> /dev/null
)
f.x dnf.is-installed

dnf.transaction2binstall() (
    >&2 echo "${FUNCNAME} redo in python"
    return 1
    local _range=${1:-last} # range ${_max}..{_min} e.g last..last-3
    dnf history list ${_range} | tail -n+2 | \
        awk '{if ("install" == $3) { for (i=4; i<=NF-4; i++) if ($i == "-y" || $i == "--assumeyes") continue; printf "%s ", $i; print ""}}'
    # local _binstalld="$(bashenv.profiled)/binstall.d"
    # for _t in $(dnf history ${_range}); do
    #     2>/dev/null ln -srv ${_binstalld}/{_template,${_p}}.${FUNCNAME}.binstall.sh
    # done
)
f.x dnf.transaction2binstall

sourced || true
