running.bash && u.have $(basename ${BASH_SOURCE} .sh) || return 0

ssh.scan() {
  for ip in $(arp.scan $@); do ssh ${ip} id > /dev/null && echo ${ip}; done
}; declare -fx ssh.scan


ssh.keygen() (
    : 'ssh.keygen [--trace] [-m=PEM] [--file=some/path/name] [--comment="${string}"] [--password="${password}"] ...'
    set -uEeo pipefail; shopt -s nullglob
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
    
); declare -fx ssh.keygen



# ssh when ~/.ssh/config.d/hosts.d/${_remote_host}.host.conf isn't around.
ssh.mkpair() (
    : 'ssh.mkpair [${_remote_host:-tbs} [${_remote_user:-${USER}}]] |> create key in ${HOME}/.ssh/keys.d/quad, copy .pub to clipboard'
    local _remote_host="${1:-tbs}"
    local _remote_user="${2:-${USER}}"
    local _keyfile="${HOME}/.ssh/keys.d/quad/${USER}@${HOSTNAME}4${_remote_user}@${_remote_host}_id_rsa"
    local _pub="${_keyfile}.pub"
    local _comment="${HOSTNAME}:${_pub}"
    ssh-keygen -q -N ''   -f "${_keyfile}" -C "${_comment}"
    wl-copy -n < "${_pub}" && >&2 echo "'${_pub}' copied to clipboard"
); declare -fx ssh.mkpair


ssh.User() (
    if [[ "$1" =~ ^([^@]*)@ ]] ; then
        echo ${BASH_REMATCH[1]}
    else
        echo ${USER}
    fi
); declare -fx ssh.User

ssh.HostName() (
    if [[ "$1" =~ @(.*)$ ]] ; then
        echo ${BASH_REMATCH[1]}
    else
        echo "$1"
    fi
); declare -fx ssh.HostName

ssh.IdentityFile() (
    local _remote_user=$1
    local _remote_host=$2
    local _f=~/.ssh/keys.d/quad/${USER}@${HOSTNAME}4${_remote_user}@${_remote_host}_id_rsa
    [[ -r ${_f} ]] && { echo ${_f}; return 0; }
    local _f=~/.ssh/keys.d/quad/${_remote_user}@${_remote_host}_id_rsa
    [[ -r ${_f} ]] && { echo ${_f}; return 0; }
    local _f=~/.ssh/keys.d/quad/${_remote_host}_id_rsa
    [[ -r ${_f} ]] && { echo ${_f}; return 0; }
)

ssh.ssh() (
    : 'ssh.ssh [${user}@]?${host} $*'
    local _target=${1:?"${FUNCNAME} expecting a host"}; shift
    local _remote_user=$(ssh.User ${_target})
    local _remote_host=$(ssh.HostName ${_target})
    local _IdentityFile=$(ssh.IdentityFile ${_remote_host} ${_remote_user})
    local _options=""
    [[ -n "${_IdentityFile}" ]] && _options+="-o IdentityFile=${_IdentityFile}"
    (set -x; command ssh "$@" "${_options}" ${_target})
); declare -fx ssh.ssh


ssh.x() (
    local -r _host=${1:?'expecting a host'}; shift
    ssh -fY ${_host} env GDK_BACKEND=x11 "$@"
); declare -fx ssh.x

ssh.terminator() (
    local -r _host=${1:?'expecting a host'}; shift
    ssh.x ${_host} terminator --hidden --title=\${USER}@\${HOSTNAME} --name=\${USER}@\${HOSTNAME} "$@"
); declare -fx ssh.terminator

ssh.terminator.all() (
    for _host in "$@"; do ssh.terminator ${_host} ; done
); declare -fx ssh.terminator.all
