# skip if not bash
realpath /proc/$$/exe | grep -Eq 'bash$' || return 0

# if PS1 doesn't end with $p add it.
export p=''
[[ "${PS1}" =~ \\\$p[[:space:]]$ ]] || export PS1="${PS1:0:-1}p "

