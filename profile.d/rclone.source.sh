${1:-false} || u.have $(path.basename.part ${BASH_SOURCE} 0) || return 0

rclone() (
    command ${FUNCNAME} "$@"
)
f.x rclone

rclone.doc.urls() (
    local -A _urls=(
        [start]=""
        [doc]=""
        [vcs]=""
        [blog]=""
        [irc]=""
    )
    echo ${_urls[${1:-@}]}
)
f.x rclone.doc.urls

rclone.doc() (
    set -Eeuo pipefail; shopt -s nullglob
    for _u in $(${FUNCNAME}.urls); do xdg-open ${_u}; done
)
f.x rclone.doc

rclone.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x rclone.env


# rclone mounters
# TODO ;
rclone.mount() (
    : '${_mountspec} ${_mountpoint} ## e.g. mnt-gdrive-mcarifio:/ ${HOME}/mnt/gdrive/carif.io'
    rclone mount "${1:?"${FUNCNAME}@${BASH_LINENO}: expecting an rclone mountpoint"}" "${2:?"${FUNCNAME}@${BASH_LINENO}: expecting a target directory"}" \
           --vfs-cache-mode full --drive-export-formats docx --drive-export-formats xlsx --drive-import-formats docx --drive-import-formats xlsx
)

rclone.mount.carif() {
    export CARIF=$(path.md ${HOME}/mnt/gdrive/carif.io)
    ${FUNCNAME%.*} mnt-gdrive-mcarifio:/ ${CARIF}
}
f.x rclone.mount.carif

rclone.mount.m00nlit() {
    export M00NLIT=$(path.md ${HOME}/mnt/1drive/m00nlit.com)
    ${FUNCNAME%.*} mnt-gdrive-mcarifio:/ ${M00NLIT}
}
f.x rclone.mount.m00nlit

all.rclone.mount() {
    : 'mount every rclone "endpoint" that has an "abstracting" mounting function, e.g. rclone.mount.carif()'
    local _prefix=${FUNCNAME#*.}
    local _re="^${_prefix//./\\.}\\."
    for _f in $(declare -pxF | cut -d ' ' -f3 | grep -E "${_re}"); do
        ${_f} "$@" || >&2 echo "${_f} $@ => $?"
    done
}
f.x all.rclone.mount

rclone.mountpoints() (
    mount --type=fuse.rclone
)
f.x rclone.mountpoints



rclone.session() {
    : '# called by .bashrc'
    source <(rclone genautocomplete bash /dev/stdout ${1:-$(u.shell)})
}
f.x rclone.session

rclone.installer() (
    set -Eeuo pipefail # DO NOT shopt -s nullglob
    realpath -Lm $(binstall.installer ${FUNCNAME%.*})
)
f.x rclone.installer

rclone.config.dir() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="${HOME}/.config/${_guard}"
    [[ -d "${_dir}" ]] || return $(u.error "${FUNCNAME} '${_dir}' not found")
    echo ${_dir}
)
f.x rclone.config.dir

rclone.config() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="$(${FUNCNAME}.dir)"
    local _config="${_dir}/${_guard}"
    [[ -r "${_config}" ]] || return $(u.error "${FUNCNAME} '${_config}' not found")
    echo "${_config}"
)
f.x rclone.config


sourced || true
