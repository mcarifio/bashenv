# .bash_profile

source $(realpath ${BASH_SOURCE}).lib.sh || true
u.map.tree source "$(bashenv.root)/.bash_profile.d"
u.map.tree guard "$(bashenv.root)/.bash_profile.d"
# guard.bash_profile.d
# source.bash_profile.d
path.add "$(path.login)"
