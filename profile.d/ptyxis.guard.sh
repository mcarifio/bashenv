# usage: [guard | source] ptyxis.guard.sh [--install] [--verbose] [--trace]

# Front matter. Parse the source command line. Install by platform if --install,
# trace (and revert) if --trace.
_guard=$(path.basename ${BASH_SOURCE})
declare -A _option=([install]=0 [verbose]=0 [summarize]=0 [trace]=0)
_undo=''; trap -- 'eval ${_undo}; unset _option _undo; trap -- - RETURN' RETURN

# declare -a _rest=( $(u.parse _option "$@") )
&> /dev/null u.parse _option "$@"
# declare -p _option

if (( ${_option[trace]} )) && ! bashenv.is.tracing; then
    _undo+='set +x;'
    set -x
fi

# install by distro id by (runtime) dispatching to distro install function
# eval "${_guard}.install() ( ${_guard}.install.\$(os-release.id); )"
ptyxis.install() (
    set -uEeo pipefail
    u.have flatpak || sudo dnf install -y flatpak || return $(u.error "${FUNCNAME} failed to install flatpak")
    flatpak install --assumeyes --or-update --user \
            --from https://nightly.gnome.org/repo/appstream/org.gnome.Ptyxis.Devel.flatpakref || return $(u.error "${FUNCNAME} failed")
    >&2 echo "ptyxis --preferences # configure font and login shell"
)
f.x ptyxis.install

# source ${_guard}.guard.sh --install
if (( ${_option[install]} )) && ! u.have ${_guard}; then
    ${_guard}.install || return $(u.error "${_guard}.install failed")
fi


# _guard itself

# not working
ptyxis() (
    : '# run the ptyxis terminal'
    set -uEeo pipefail
    # configuration: ~/.var/app/org.gnome.Ptyxis.Devel/**
    flatpak run org.gnome.Ptyxis.Devel &
)
f.x ptyxis


ptyxis.doc() (
    set -uEeo pipefail
    xdg-open "https://gitlab.gnome.org/chergert/ptyxis"
)
f.x ptyxis.doc

ptyxis.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x ptyxis.env

ptyxis.session() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x ptyxis.session

loaded "${BASH_SOURCE}"
