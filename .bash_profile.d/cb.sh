realpath /proc/$$/exe | grep -Eq 'bash$' || return 0
type -p wl-copy &> /dev/null || return 0

cb.cp() ( wl-copy -n ; ); declare -fx cb.cp
cb.pn() ( path.pn1 $1 | cb.cp ; ); declare -fx cb.pn


