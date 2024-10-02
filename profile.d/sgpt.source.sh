${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

# Shell-GPT integration BASH v0.2
_sgpt_readline() {
    [[ -z "${READLINE_LINE}" ]] && return 0
    # >&2 echo ${READLINE_LINE}
    READLINE_LINE="$(sgpt --shell  --no-interaction <<< \"${READLINE_LINE}\") ## sgpt '${READLINE_LINE}' "
    READLINE_POINT=${#READLINE_LINE}
}
f.x _sgpt_readline

sgpt() (
    : 'python -m dbg -m ${FUNCNAME} "$@"'
    python -m ${FUNCNAME} "$@"
)
f.x sgpt


sgpt.session() {
    bind -x '"\C-xl"':_sgpt_readline || return $(u.error "${FUNCNAME} failed")
}
f.x sgpt.session

sgpt.installer() ( ls -1 $(bashenv.profiled)/binstall.d/*shell_gpt*.*.binstall.sh; )
f.x sgpt.installer

sourced || true


