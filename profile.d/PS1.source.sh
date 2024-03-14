# if PS1 doesn't end with $p add it.
[[ -n "${p}" ]] && return 0
export p=' '
PS1="${PS1:0:-1}p "


