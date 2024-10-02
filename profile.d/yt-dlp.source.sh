${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

yt-dlp() (
    command ${FUNCNAME} -f bestaudio+bestvideo "$@" ## urls
)
f.x yt-dlp


yt-dlp.doc.urls() ( echo "https://github.com/yt-dlp/yt-dlp"; ) # urls here
f.x yt-dlp.doc.urls

yt-dlp.doc() (
    set -Eeuo pipefail; shopt -s nullglob
    for _u in $(${FUNCNAME}.urls); do xdg-open ${_u}; done
)
f.x yt-dlp.doc

yt-dlp.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x yt-dlp.env

yt-dlp.session() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x yt-dlp.session


yt-dlp.installer() (
    set -Eeuo pipefail # DO NOT shopt -s nullglob
    binstall.installer ${FUNCNAME%.*}
)
f.x yt-dlp.installer

sourced || true
