source.if /etc/bashrc

# TODO mike@carif.io: better way to handle this?
[[ -n "${SSH_CONNECTION}" ]] && return 0

# not a login shell and bashenv.init didn't succeed
# shopt -q login_shell || bashenv.init.succeeded &> /dev//null || source ~/.bash_profile

# run all bashenv functions of the form ${something}.session.
# [[ -n "${BASH_ENV}" ]] && source "${BASH_ENV}" || u.warn "source ${BASH_ENV} => $?"
bashenv.session.start || >&2 echo "bashenv.session.start => $?"

# [ -f "/home/mcarifio/.local/share/ghcup/env" ] && . "/home/mcarifio/.local/share/ghcup/env" # ghcup-env
