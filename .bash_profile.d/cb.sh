running.bash && u.have wl-copy || return 0
cb.cp() ( wl-copy -n ; ); declare -fx cb.cp
cb.pn() ( path.pn1 $1 | cb.cp ; ); declare -fx cb.pn


