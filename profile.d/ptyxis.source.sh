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

# _guard itself

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
