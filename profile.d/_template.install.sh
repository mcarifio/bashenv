# _template.install.sh will install _template depending on the distro id.
install() (
    local _id=$(os-release.id)
    case ${_id} in
        fedora) sudo /usr/bin/dnf install --assumeyes "${$@}";;
        ubuntu) sudo /usr/bin/apt install -y "${$@}";;
        *) u.bad "${BASH_SOURCE} cannot install on id ${_id}"
    esac
    >&2 echo "${BASH_SOURCE} installed on id ${_id}"
)

install "$@"

