source /etc/bashrc

# TODO mike@carif.io: better way to handle this?
[[ -n "${SSH_CONNECTION}" ]] && return 0

# not a login shell and bashenv.init didn't succeed
shopt -q login_shell || bashenv.init.succeeded &> /dev//null || source ~/.bash_profile

# run all bashenv functions of the form ${something}.session.
bashenv.session.start


[ -f "/home/mcarifio/.local/share/ghcup/env" ] && . "/home/mcarifio/.local/share/ghcup/env" # ghcup-env