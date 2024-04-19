source /etc/bashrc

&> /dev/null bashenv.loaded || source ~/.bash_profile

# run all bashenv functions of the form ${something}.session.
bashenv.session.start

[[ -f /usr/share/bash-prexec ]] && source /usr/share/bash-prexec
[[ "$(command -v atuin)" ]] && eval "$(atuin init bash)"
