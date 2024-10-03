source /etc/bashrc

# TODO mike@carif.io: better way to handle this?
[[ -n "${SSH_CONNECTION}" ]] && return 0

&> /dev/null bashenv.initialized || source ~/.bash_profile

# run all bashenv functions of the form ${something}.session.
bashenv.session.start
