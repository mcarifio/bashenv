${1:-false} || u.haveP $(path.basename.part ${BASH_SOURCE} 0) || return 0

codium() ( command ${FUNCNAME} "$@"; )
f.x codium

# Install the codium extension associated with the guard e.g. 'go' or 'rustc'
# Install all the extensions by finding all installers matching a function name regular expression.
# In this way you can run the installers one at a time if you wish.
codium.install.extensions() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard=${FUNCNAME%%.*}
    ${_guard} --install-extension whitphx.awesome-emacs --force
    for _installer in $(f.match ^${_guard}\.extension\.install\.); do
        ${_installer} || true
    done
)
f.x codium.install.extensions


# Install the asdf codium extension if you have asdf on PATH. Override this check with
# codium.extension.install.asdf true.
codium.extension.install.asdf() (
    ${1:-false} || u.have ${FUNCNAME##*.} && ${FUNCNAME%%.*} --install-extension nguyenngoclong.asdf --force
)
f.x codium.extension.install.asdf


codium.extension.install.go() (
    ${1:-false} || u.have ${FUNCNAME##*.} && ${FUNCNAME%%.*} --install-extension golang.Go --force
)
f.x codium.extension.install.go

codium.extension.install.rustc() (
    ${1:-false} || u.have ${FUNCNAME##*.} && ${FUNCNAME%%.*} --install-extension rust-lang.rust --force
)
f.x codium.extension.install.rustc

codium.extension.install.python() (
    ${1:-false} || u.have ${FUNCNAME##*.} && ${FUNCNAME%%.*} --install-extension ms-python.python --force --install-extension ms-python.debugpy --force
)
f.x codium.extension.install.python

codium.extension.install.typescript() (
    ${1:-false} || u.have deno || u.have bun || u.have tsc && ${FUNCNAME%%.*} --install-extension ms-vscode.vscode-typescript-next --force
)
f.x codium.extension.install.typescript




codium.doc.urls() ( echo ; ) # urls here
f.x codium.doc.urls

codium.doc() (
    set -Eeuo pipefail; shopt -s nullglob
    for _u in $(${FUNCNAME}.urls); do xdg-open ${_u}; done
)
f.x codium.doc

codium.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x codium.env

codium.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    local -r _completions=/usr/share/bash-completion/completions
    source.if ${_completions}/${_cmd}.${_shell} ${_completions}/${_cmd}
}
f.x codium.session

codium.installer() (
    set -Eeuo pipefail # DO NOT shopt -s nullglob
    binstall.installer ${FUNCNAME%.*}
)
f.x codium.installer

codium.config.dir() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="${HOME}/.config/${_guard}"
    [[ -d "${_dir}" ]] || return $(u.error "${FUNCNAME} '${_dir}' not found")
    echo ${_dir}
)
f.x codium.config.dir

codium.config() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="$(${FUNCNAME}.dir)"
    local _config="${_dir}/${_guard}"
    [[ -r "${_config}" ]] || return $(u.error "${FUNCNAME} '${_config}' not found")
    echo "${_config}"
)
f.x codium.config

sourced || true
