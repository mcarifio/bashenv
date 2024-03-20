ssh.scan() {
    set -Eeuo pipefail
    for ip in $(arp.scan $@); do ssh ${ip} id > /dev/null && echo ${ip}; done
}
f.complete ssh.scan


ssh.keygen() (
    : 'ssh.keygen [--trace] [-m=PEM] [--file=some/path/name] [--comment="${string}"] [--password="${password}"] ...'
    set -uEeo pipefail
    shopt -s nullglob
    local _file="${PWD}/${FUNCNAME}"
    local _comment="${HOSTNAME}:${_file}"
    local _password=''
    local _trace='+x'
    
    if (( ${#@} )) ; then
        for _a in "${@}"; do
            case "${_a}" in
		--file=*) _file=${_a#--file=};;
		--comment=*) _comment=${_a#--comment=};;
		--password=*) _password=${_a#--password=};;
		--trace) _trace='-x';;
		
                --) shift; break;;
                *) break;;
            esac
            shift
        done
    fi

    # TODO mike@carif.io: doesn't work
    xz --compress --force --verbose "${_file}*" || true
    # to convert to PEM: ssh.keygen --file=some/path/id_rsa -p -m PEM
    (set ${_trace}; ssh-keygen -f "${_file}" -C "${_comment}" -N "${_password}" "$@"; )
    
)
f.complete ssh.keygen



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
f.complete ssh.mkpair


ssh.User() (
    set -Eeuo pipefail
    if [[ "$1" =~ ^([^@]*)@ ]] ; then
        echo ${BASH_REMATCH[1]}
    else
        echo ${USER}
    fi
)
f.complete ssh.User

ssh.HostName() (
    if [[ "$1" =~ @(.*)$ ]] ; then
        echo ${BASH_REMATCH[1]}
    else
        echo "$1"
    fi
)
f.complete ssh.HostName

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
f.complete ssh.IdentityFile

ssh.ssh0() (
    : 'ssh.ssh [${user}@]?${host} $*'
    local _target=${1:?"${FUNCNAME} expecting a host"}; shift
    local _remote_user=$(ssh.User ${_target})
    local _remote_host=$(ssh.HostName ${_target})
    local _IdentityFile=$(ssh.IdentityFile ${_remote_host} ${_remote_user})
    local _options=""
    [[ -n "${_IdentityFile}" ]] && _options+="-o IdentityFile=${_IdentityFile}"
    (set -x; command ssh "$@" "${_options}" ${_target})
)
f.complete ssh.ssh0


ssh.i() (
    : 'ssh.i [${user}:-${USER}]@${host} $* ## ssh to destination with an explicit IdentityFile based on the destination itself'
    set -Eeuo pipefail
    local _destination=${1:?'expecting a destination'}; shift
    local _host=${_destination#*@} _user=${_destination%@*}
    [[ -z "${_user}" ]] && _user=${USER}
    local _keys_d=~/.ssh/keys.d
    local _id_rsa=${_keys_d}/${_user}@${_host}_id_rsa
    if [[ -r ${_id_rsa} ]] ; then
        command ssh ${SSH_ARGS} -o IdentitiesOnly=true -o IdentityFile=${_id_rsa} ${_destination} "$@"
    else
        >&2 echo "IdentityFile ${_id_rsa} not found"
    fi
)
f.complete ssh.i


ssh.x() (
    set -Eeuo pipefail
    local -r _host=${1:?'expecting a host'}; shift
    ssh -fY ${_host} env GDK_BACKEND=x11 "$@"
)
f.complete ssh.x

ssh.terminator() (
    set -Eeuo pipefail
    local -r _host=${1:?'expecting a host'}; shift
    ssh.x ${_host} terminator --hidden --title=\${USER}@\${HOSTNAME} --name=\${USER}@\${HOSTNAME} "$@"
); f.complete ssh.terminator

ssh.terminator.all() (
    set -Eeuo pipefail
    u.map ssh.terminator "$@"
)
f.complete ssh.terminator.all

# ssh.env() {
#     # echo ${FUNCNAME}
#     return 0 
# }; f.complete ssh.env

