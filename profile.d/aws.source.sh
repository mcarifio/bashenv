${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0
# @see: { https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html }

# export a pathname as an environment variable iff the pathname is readable by this user.
# make this a utility function for others to use. But define it before first use
# (which could prove to be a little confusing).

# export AWS_CONFIG_FILE=~/.config/aws/config
path.name AWS_CONFIG_FILE ~/.config/aws/config

# export AWS_SHARED_CREDENTIALS_FILE=~/.config/aws/credentials
path.name AWS_SHARED_CREDENTIALS_FILE ~/.config/aws/credentials

sourced
