sgpt() (
    : 'python -m dbg -m ${FUNCNAME} "$@"'
    python -m ${FUNCNAME} "$@"
)
f.complete sgpt

# Shell-GPT integration BASH v0.2
_sgpt_readline() {
    [[ -z "${READLINE_LINE}" ]] && return 0
    # >&2 echo ${READLINE_LINE}
    READLINE_LINE="$(sgpt --shell  --no-interaction <<< \"${READLINE_LINE}\") ## sgpt '${READLINE_LINE}' "
    READLINE_POINT=${#READLINE_LINE}
}
f.x _sgpt_readline

sgpt.session() {
    bind -x '"\C-xl"':_sgpt_readline || u.error
}
f.x sgpt.session
sgpt.session

loaded "${BASH_SOURCE}"

