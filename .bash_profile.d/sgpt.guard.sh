sgpt() (
    : 'python -m dbg -m ${FUNCNAME} "$@"'
    python -m ${FUNCNAME} "$@"
)
f.complete sgpt

# Shell-GPT integration BASH v0.2
_sgpt_bash() {
if [[ -n "$READLINE_LINE" ]]; then
    READLINE_LINE=$(sgpt --shell <<< "$READLINE_LINE" --no-interaction)
    READLINE_POINT=${#READLINE_LINE}
fi
}
declare -fx _sgpt_bash
