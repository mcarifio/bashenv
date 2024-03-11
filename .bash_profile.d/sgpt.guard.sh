sgpt() (
    : 'python -m dbg -m ${FUNCNAME} "$@"'
    python -m ${FUNCNAME} "$@"
)
f.complete sgpt

# Shell-GPT integration BASH v0.2
_sgpt_bash() {
    if [[ -n "${READLINE_LINE}" ]]; then
        # >&2 echo "sgpt --shell --no-interaction '${READLINE_LINE}'..."
        READLINE_LINE="$(sgpt --shell  --no-interaction <<< \"${READLINE_LINE}\") ## sgpt '${READLINE_LINE}'"
        READLINE_POINT=${#READLINE_LINE}
    fi
}
declare -fx _sgpt_bash
