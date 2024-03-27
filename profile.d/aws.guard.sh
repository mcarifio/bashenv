# You probably installed this using asdf, not dnf: asdf.plugin+install awscli

# @see: { https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html }

# export a pathname as an environment variable iff the pathname is readable by this user.
# make this a utility function for others to use. But define it before first use
# (which could prove to be a little confusing).


# usage: source _template.guard.sh [--install] [--verbose] [--trace]
_guard=$(path.basename ${BASH_SOURCE})
declare -A _option=([install]=0 [verbose]=0 [summarize]=0 [trace]=0)
_undo=''
trap -- 'eval ${_undo}; unset _option _undo; trap -- - RETURN' RETURN

if (( ${#@} )) ; then
    for _a in "$@"; do
        case "${_a}" in
            # --something=some_value => _option[something]=some_value
            --*=*) [[ "${_a}" =~ --([^=]+)=(.+) ]] && _option[${BASH_REMATCH[1]}]="${BASH_REMATCH[2]}";;
            # --something => _option[something]=1
	    --*) _option[${_a:2}]=1;;
            --) shift; break;;
            *) break;;
        esac
        shift
    done
fi
if (( ${_option[trace]} )) && ! bashenv.is.tracing; then
    _undo+='set +x;'
    set -x
fi
if (( ${_option[install]} )); then
    if u.have ${_guard}; then
        >&2 echo ${_guard} already installed
    else
        u.bad "${BASH_SOURCE} --install # not implemented"
    fi
fi






# export AWS_CONFIG_FILE=~/.config/aws/config
path.name AWS_CONFIG_FILE ~/.config/aws/config

# export AWS_SHARED_CREDENTIALS_FILE=~/.config/aws/credentials
path.name AWS_SHARED_CREDENTIALS_FILE ~/.config/aws/credentials

aws.loaded() ( return 0; )
f.x aws.loaded
