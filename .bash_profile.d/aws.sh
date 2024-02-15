running.bash && u.have asdf || return 0
# You probably installed this using asdf, not dnf: asdf.plugin+install awscli

# @see: { https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html }

# export a pathname as an environment variable iff the pathname is readable by this user.
# make this a utility function for others to use. But define it before first use
# (which could prove to be a little confusing).
u.export-pn() {
    local _name=${1:?'expecting an env name'}
    local _pn=${2:?'expecting a readable pathname'}
    [[ -r "${_pn}" ]] && export ${_name}=${_pn} || { >&2 echo "${_pn} not readable."; return 1; }
}
declare -fx u.export-pn


# export AWS_CONFIG_FILE=~/.config/aws/config
u.export-pn AWS_CONFIG_FILE ~/.config/aws/config

# export AWS_SHARED_CREDENTIALS_FILE=~/.config/aws/credentials
u.export-pn AWS_SHARED_CREDENTIALS_FILE ~/.config/aws/credentials

