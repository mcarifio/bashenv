# https://github.com/vslobodyan/gnome-active-window/blob/master/gnome-active-window#L64
gnome.lg() {
    : 'send something to gnome looking glass (debugger?)'
    local ret=$(gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/Shell --method org.gnome.Shell.Eval "$1")
    [[ "${ret:0:8}" = "(true, '" ]] || { >&2 echo "bad output from Gnome looking glass: $ret"; return 1; }
    [[ -n "${ret:8:-2}" ]] && echo "${ret:8:-2}"
}
declare -fx gnome.lg

