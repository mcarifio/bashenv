# You probably installed this using asdf, not dnf: asdf.plugin+install awscli

# @see: { https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html }

# export a pathname as an environment variable iff the pathname is readable by this user.
# make this a utility function for others to use. But define it before first use
# (which could prove to be a little confusing).

# usage: [guard | source] _template.guard.sh [--install] [--verbose] [--trace]
_guard=$(path.basename ${BASH_SOURCE})

# export AWS_CONFIG_FILE=~/.config/aws/config
path.name AWS_CONFIG_FILE ~/.config/aws/config

# export AWS_SHARED_CREDENTIALS_FILE=~/.config/aws/credentials
path.name AWS_SHARED_CREDENTIALS_FILE ~/.config/aws/credentials

loaded "${BASH_SOURCE}"
