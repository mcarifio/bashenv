# .bashrc

# Source global definitions
# src /etc/bashrc
source /etc/bashrc

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=
# guard.bashrc.d || true
# source.bashrc.d || true
u.map.tree source $(bashenv.root)/.bashrc.d
u.map.tree guard $(bashenv.root)/.bashrc.d



