${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0


# Enumerate final options (which are the defaults since last option wins)
# See man 5 ssh_config for a list of the ssh options.
ssh.options.defaults() (
    set -Eeuo pipefail; shopt -s nullglob
    echo -n
)
f.x ssh.options.defaults

# untested
ssh.options.gh0() (
    set -Eeuo pipefail; shopt -s nullglob
    local -A _options=()
    _options+=( [HostName]=github.com  [User]=git )
    _options+=( [PreferredAuthenications]=publickey \
               [IdentitiesOnly]=yes \
               [IdentityFile]="$(path.exists "${HOME}/keys.d/git/${USER}-at-${_hostname}_id_rsa")" )
    for _k in ${!_options[@]}; do
        local _v="${_options[$_k]}"
        printf " [%s]=\"%s\"" ${_k} ${_v}
    done
)
f.x ssh.options.gh0

ssh.options.keypath() (
    : '${IdentityFile_pathname} # pathname of private key, usually _id_rsa; emit the ssh options for publickey auth only'
    set -Eeuo pipefail; shopt -s nullglob
    local _IdentityFile="${1:?"$(u.expecting pathname)"}"
    local _auths="${2:-publickey}"
    chmod --changes --silent 0600 "${_IdentityFile}"
    echo -n "PreferredAuthentications=${_auths}" "IdentitiesOnly=yes" "IdentityFile="${_IdentityFile}"" " "
)
f.x ssh.options.keypath
                

ssh.options.do() (
    : 'ssh options for Host do'
    set -Eeuo pipefail; shopt -s nullglob
    ssh.options.keypath "$(path.exists "${HOME}/.ssh/keys.d/quad/do_id_rsa")"
    echo -n "HostName=104.236.99.3" " "
)
f.x ssh.options.do

# simulate Host h0 h1 h3 ...:
ssh.host.aliases() {
    local _host="${1:? "${FUNCNAME} expecting a Host"}"; shift
    for _a in $@; do
        local _alias=ssh.options.${_a}
        eval "${_alias}() ( ssh.options.${_host}; ); f.x ${_alias};"
    done
}

# do is a Host for mike.carif.io
ssh.host.aliases do mike.carif.io

ssh.options4() (
    local _User=${1:?"${FUNCNAME} expecting a User"}; shift
    local _Host=${1:?"${FUNCNAME} expecting a Host"}; shift
    ssh.options.defaults
    f.apply.if ssh.options.defaults.${HOSTNAME}
    f.apply.if ssh.options.${_Host}
    echo -n "$@" " "
    echo -n "SendEnv=SSH_FROM" "User=${_User}" " "

)
f.x ssh.options4
 
ssh.o() (
    set -Eeuo pipefail; shopt -s nullglob
    local -A _options=()
    for _a in "${@}"; do
        local _k="${_a%%=*}"
        local _v="${_a##*=}"
        case "${_a}" in
	    *=*) _options["${_k}"]="${_v}";;
            *) return $(u.error "${_a} is in the wrong format");;
        esac
        shift
    done
    _prefix=' -o '                    
    for _k in ${!_options[@]}; do echo -n "${_prefix}${_k}"; [[ -v _options["${_k}"] ]] && echo -n "=${_options["${_k}"]} "; done
)
f.x ssh.o

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
    SSH_FROM="${USER}@${HOSTNAME}" command ${FUNCNAME} "${_args[@]:0:${_len}}" $(ssh.o $(ssh.options4 ${_User} ${_Host})) ${_Host}
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

