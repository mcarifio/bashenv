[[ -d "${HOME}/.elan/bin" ]] || return 0
path.add "${HOME}/.elan/bin"
source <(elan completions $(u.shell))
loaded "${BASH_SOURCE}"
