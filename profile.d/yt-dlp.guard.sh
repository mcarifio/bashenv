_guard=$(path.basename ${BASH_SOURCE})

_yt-dlp.parse() (
    : '## example: parse callers arglist'
    set -uEeo pipefail
    shopt -s nullglob
    declare -A _ytdlp_options=([file]="${PWD}/${FUNCNAME}" [comment]="${HOSTNAME}:and_some_stuff" [trace]=0)
    local -a _rest=( $(u.parse _ytdlp_options --foo=bar --user=${USER} --trace 1 2 3) )
    printf '%s ' ${FUNCNAME}; declare -p _ytdlp_options; printf '%s ' ${_rest[@]}
)


yt-dlp() (
    command ${FUNCNAME} -f bestaudio+bestvideo "$@" ## urls
)
f.x yt-dlp

# TODO mike@carif.io: logic needs fixing
f.x _yt-dlp.parse

yt-dlp.docs() (
    set -Eeuo pipefail
    local -nu _docs=${FUNCNAME%.*}_urls # e.g. UV_DOCS
    set -x; xdg-open ${_docs:-} "$@" https://github.com/yt-dlp/yt-dlp
)


yt-dlp.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x yt-dlp.env

yt-dlp.session() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x yt-dlp.session

loaded "${BASH_SOURCE}"
