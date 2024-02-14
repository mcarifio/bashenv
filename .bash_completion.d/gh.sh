type -p gh &> /dev/null || return 0
# u.shell depends on load order
source <(gh completion -s $(u.shell 2>/dev/null || echo bash))

