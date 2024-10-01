path.add /home/linuxbrew/.linuxbrew/bin
${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

brew.env() {
    export HOMEBREW_NO_ENV_HINTS="$(path.pn ${BASH_SOURCE})"
}
f.x brew.env

# `brew shellenv` *side effects* the bash environment so it's at the start of each session.
# This seems broken to me.
brew.session() {
    source <(brew shellenv) || return $(u.error "${FUNCNAME} failed")
}
f.x brew.session

# try to run once to avoid adding brew to PATH multiple times
u.singleton brew.session

sourced
