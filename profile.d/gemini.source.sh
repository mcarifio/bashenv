${1:-false} || u.have $(path.basename.part ${BASH_SOURCE} 0) || return 0

gemini() ( NODE_OPTIONS="--no-deprecation" command gemini "$@"; )
f.x gemini

gemini.env() {
    : '# called (once) by .bash_profile'
    # https://aistudio.google.com/apikey
    export GEMINI_API_KEY="AIzaSyApaiTBGsNwpHusDARhdvPVXu5t8P9CY0s"
}
f.x gemini.env

sourced || true
