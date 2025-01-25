${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0


# Enumerate final options (which are the defaults since last option wins)
# See man 5 ssh_config for a list of the ssh options.
ssh.options.defaults() (
    set -Eeuo pipefail; shopt -s nullglob
    ## echo -n " RemoteCommand='set | grep SSH_' "
)
f.x ssh.options.defaults


# TODO mike@carif.io: most variation here re: getting the right private key
ssh.options.keypath() (
    : '${IdentityFile_pathname} # pathname of private key, usually _id_rsa; emit the ssh options for publickey auth only'
    set -Eeuo pipefail; shopt -s nullglob
    local _IdentityFile="${1:?"$(u.expect pathname)"}"
    local _auths="${2:-publickey}"
    chmod --changes --silent 0600 "${_IdentityFile}"
    echo -n "PreferredAuthentications=${_auths} IdentitiesOnly=yes IdentityFile='${_IdentityFile}' "
)
f.x ssh.options.keypath
                

ssh.options.do() (
    : 'ssh options for Host do'
    set -Eeuo pipefail; shopt -s nullglob

    local _l=${USER}
    # local _r=${someone:-${_l}}
    local _d=$(getent passwd ${1:-${SUDO_USER:-${_l}}} | cut -d: -f6)
    local _h=104.236.99.3

    echo -n "HostName=${_h} "
    ssh.options.keypath "$(path.exists "${_d}/.ssh/keys.d/quad/do_id_rsa")"
)
f.x ssh.options.do

ssh.options.gh() (
    set -Eeuo pipefail; shopt -s nullglob

    local _l=${USER}
    local _r=git
    local _h=github.com
    local _d=$(getent passwd ${1:-${SUDO_USER:-${_l}}} | cut -d: -f6)

    echo -n "RequestTTY=no User=${_r} HostName=${_h} "
    ssh.options.keypath "$(path.exists "${_d}/.ssh/keys.d/${_l}@${_h}_id_rsa")"
)
f.x ssh.options.gh


# simulate Host h0 h1 h3 ...:
ssh.host.aliases() {
    local _host="${1:?$(u.expect host)}"; shift
    for _a in $@; do
        local _alias=ssh.options.${_a}
        eval "${_alias}() ( ssh.options.${_host} \"$@\"; ); f.x ${_alias};"
    done
}
f.x ssh.host.aliases
ssh.host.aliases do mike.carif.io # ssh.host.mike.carif.io forwards call to host.alias.do 

ssh.options4() (
    local _Host=${1:?$(u.expect Host)}; shift
    local _User=${1:-${USER}}; shift || true
    echo -n "SendEnv=SSH_FROM User='${_User}' HostName='${_Host}' $@ "
    ssh.options.defaults; f.apply.if ssh.options.defaults.${HOSTNAME}; f.apply.if ssh.options.${_Host}
)
f.x ssh.options4
 

ssh.o.fmt() (
    local _key="${1:?$(u.expect key)}"
    local _value="${2:?$(u.expect value)}"
    local _prefix="${3:-" -o "}" _suffix=" "
    echo -n "${_prefix}${_key}"; [[ -n "${_value}" ]] && echo -n "=${_value}"; echo -n "${_suffix}"
)
f.x ssh.o.fmt

ssh.o() (
    set -Eeuo pipefail; shopt -s nullglob
    
    local -A _options=()
    for _a in "${@}"; do
        # if _a == "Key=value" then _k=Key and _v=value
        local _k="${_a%%=*}"
        local _v="${_a##*=}"
        case "${_a}" in
	    *=*) _options["${_k}"]="${_v}";; # last assignment wins
            *) return $(u.error "${_a} is in the wrong format");;
        esac
        shift
    done
    for _k in ${!_options[@]}; do ${FUNCNAME}.fmt ${_k} ${_options["${_k}"]}; done
)
f.x ssh.o

sshfs.o.fmt() (
    local _key="${1:?$(u.expect key)}"
    local _value="${2:?$(u.expect value)}"
    local _prefix="${3:-''}" _suffix=","
    echo -n "${_prefix}${_key}"; [[ -n "${_value}" ]] && echo -n "=${_value}"; echo -n "${_suffix}"
)
f.x sshfs.o.fmt

sshfs.o() (
    set -Eeuo pipefail; shopt -s nullglob
    
    local -A _options=()
    for _a in "${@}"; do
        # if _a == "Key=value" then _k=Key and _v=value
        local _k="${_a%%=*}"
        local _v="${_a##*=}"
        case "${_a}" in
	    *=*) _options["${_k}"]="${_v}";; # last assignment wins
            *) return $(u.error "${_a} is in the wrong format");;
        esac
        shift
    done
    for _k in ${!_options[@]}; do ${FUNCNAME}.fmt ${_k} ${_options["${_k}"]}; done
)
f.x sshfs.o

ssh() (
    set -Eeuo pipefail; shopt -s nullglob
    local -a _args=( $@ )
    local -i _len=$(( ${#_args[@]} - 1 ))
    # declare -p _args _len
    (( _len >= 0 )) || return $(u.error "${FUNCNAME} expecting a Host")
    local _Host="${_args[${_len}]}"
    local _User="${USER}"
    [[ "${_Host}" =~ ^([^@]*)@(.+)$ ]] && {
        # declare -p BASH_REMATCH
        _User="${BASH_REMATCH[1]}"
        _Host="${BASH_REMATCH[2]}"
    }
    local _options="$(ssh.o $(ssh.options4 ${_Host} ${_User}))"
    [[ -v ${FUNCNAME^^}_TRACE ]] && >&2 echo $(u.color.green ${FUNCNAME} "${_args[@]:0:${_len}}" ${_options} ${_Host})
    SSH_FROM="${USER}@${HOSTNAME}" command ${FUNCNAME} "${_args[@]:0:${_len}}" ${_options} ${_Host}
)
f.x ssh


ssh.scan() {
    set -Eeuo pipefail
    for ip in $(arp.scan $@); do ssh ${ip} id > /dev/null && echo ${ip}; done
}
f.x ssh.scan


ssh.keygen() (
    : 'ssh.keygen [--trace] [-m=PEM] [--file=some/path/name] [--comment="${string}"] [--password="${password}"] ...'
    set -uEeo pipefail; shopt -s nullglob
    local _file="${PWD}/${FUNCNAME}"
    local _comment="${HOSTNAME}:${_file}"
    local _password=''
    local _trace='+x'
    
    for _a in "${@}"; do
        local _k="${_a%%=*}"
        local _v="${_a##*=}"
        case "${_a}" in
	    --file=*) _file="${_v}";;
	    --comment=*) _comment="${_v}";;
	    --password=*) _password="${_v}";;
	    --trace) _trace='-x';;		
            --) shift; break;;
            *) break;;
        esac
        shift
    done

    # TODO mike@carif.io: doesn't work
    xz --compress --force --verbose "${_file}*" || true
    # to convert to PEM: ssh.keygen --file=some/path/id_rsa -p -m PEM
    (set ${_trace}; ssh-keygen -f "${_file}" -C "${_comment}" -N "${_password}" "$@"; )
    
)
f.x ssh.keygen



# ssh when ~/.ssh/config.d/hosts.d/${_remote_host}.host.conf isn't around.
ssh.mkpair() (
    : 'ssh.mkpair [${_remote_host:-tbs} [${_remote_user:-${USER}}]] |> create key in ${HOME}/.ssh/keys.d/quad, copy .pub to clipboard'
    set -Eeuo pipefail
    local _remote_host="${1:-tbs}"
    local _remote_user="${2:-${USER}}"
    local _keyfile="${HOME}/.ssh/keys.d/quad/${USER}@${HOSTNAME}4${_remote_user}@${_remote_host}_id_rsa"
    local _pub="${_keyfile}.pub"
    local _comment="${HOSTNAME}:${_pub}"
    ssh-keygen -q -N ''   -f "${_keyfile}" -C "${_comment}"
    wl-copy -n < "${_pub}" && >&2 echo "'${_pub}' copied to clipboard"
)
f.x ssh.mkpair


ssh.IdentityFile() (
    set -Eeuo pipefail
    local _remote_user=$1
    local _remote_host=$2
    local _f=~/.ssh/keys.d/quad/${USER}@${HOSTNAME}4${_remote_user}@${_remote_host}_id_rsa
    [[ -r ${_f} ]] && { echo ${_f}; return 0; }
    local _f=~/.ssh/keys.d/quad/${_remote_user}@${_remote_host}_id_rsa
    [[ -r ${_f} ]] && { echo ${_f}; return 0; }
    local _f=~/.ssh/keys.d/quad/${_remote_host}_id_rsa
    [[ -r ${_f} ]] && { echo ${_f}; return 0; }
)
f.x ssh.IdentityFile



ssh.x() (
    set -Eeuo pipefail
    local -r _host=${1:?'expecting a host'}; shift
    ssh -fY ${_host} env GDK_BACKEND=x11 "$@"
)
f.x ssh.x

ssh.terminator() (
    set -Eeuo pipefail
    local -r _host=${1:?'expecting a host'}; shift
    ssh.x ${_host} terminator --hidden --title=\${USER}@\${HOSTNAME} --name=\${USER}@\${HOSTNAME} "$@"
); f.x ssh.terminator

ssh.terminator.all() (
    set -Eeuo pipefail
    u.map ssh.terminator "$@"
)
f.x ssh.terminator.all

ssh.env() {
    : 'turn off motd and other login notifications for ${USER}'
    touch ${HOME}/.hushlogin
}
f.x ssh.env

ssh.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    local -r _completions=/usr/share/bash-completion/completions
    source.if ${_completions}/${_cmd}.${_shell} ${_completions}/${_cmd}
}
f.x ssh.session

ssh.installer() ( ls -1 $(bashenv.profiled)/binstall.d/*openssh-clients*.*.binstall.sh; )
f.x ssh.installer

sourced || true

