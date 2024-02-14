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


# User specific aliases and functions
[[ function = $(type -t source.bashrc.d) ]] && source.bashrc.d || >&2 echo "source.bashrc.d undefined?"
[[ function = $(type -t source.bash_completion.d) ]] && source.bash_completion.d || >&2 echo "source.bash_completion.d undefined?"


