# usage: [guard | source] dnf.guard.sh [--install] [--verbose] [--trace]
_guard=$(path.basename ${BASH_SOURCE})
declare -A _option=([install]=0 [verbose]=0 [trace]=0)
_undo=''; trap -- 'eval ${_undo}; unset _option _undo; trap -- - RETURN' RETURN
local -a _rest=( $(u.parse _option "$@") )
if (( ${_option[trace]} )) && ! bashenv.is.tracing; then
    _undo+='set +x;'
    set -x
fi
if (( ${_option[install]} )); then
    if u.have ${_guard}; then
        >&2 echo ${_guard} already installed
    else
        u.bad "${BASH_SOURCE} --install # not implemented"
    fi
fi


# https://github.com/vslobodyan/gnome-active-window/blob/master/gnome-active-window#L64
gnome.lg() {
    : 'send something to gnome looking glass (debugger?)'
    local ret=$(gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/Shell --method org.gnome.Shell.Eval "$1")
    [[ "${ret:0:8}" = "(true, '" ]] || { >&2 echo "bad output from Gnome looking glass: $ret"; return 1; }
    [[ -n "${ret:8:-2}" ]] && echo "${ret:8:-2}"
}
f.complete gnome.lg

loaded "${BASH_SOURCE}"




