realpath /proc/$$/exe | grep -Eq 'bash$' || return 0
# @pathname: /etc/profile.d/sh.local # automatically sourced *last* by /etc/profile
# note to test: PS4='+ $BASH_SOURCE:$LINENO: ' bash -xlic "" ## https://stackoverflow.com/questions/37777754/finding-a-missing-bash-profile

# function template:
# tmpl() { ... }
# decl tmpl [${pkg-list}]

# export VISUAL=emacs
export VISUAL=$(type -f ec &> /dev/null && echo 'ec' || echo 'emacsclient')
# history
export HISTSIZE=10000
export HISTFILESIZE=$(( 10 * HISTSIZE ))
shopt -s histappend
export HISTCONTROL=$HISTCONTROL:ignorespace:ignoredups

uhave() ( type -p $1 &> /dev/null; ); declare -fx uhave
function on_path? ( /usr/bin/which ${1:?'expecting an exec path'} >& /dev/null; ); declare -fx on_path?

or() ( echo "$@" | cut -d' ' -f1; ); declare -fx or

u.shell() {
  : 'return your login shell; the SHELL env variable can be unreliable'
  basename $(realpath /proc/$$/exe)
}; declare -fx u.shell




# currently broken
# if type -p xsos &> /dev/null; then
#    _c="$(dirname $(type -p xsos))/xsos-bash-completion.bash"
#    [[ -r "${_c}" ]] && source ${_c}
#    unset _c
# fi


# INSTALL=1 source /etc/profile.d/fns.sh # to install all prerequisites
# decl() {
#     declare -fx ${1:?'expecting a declared function name'} ; shift
#     (( $# )) || return 0
#     [[ -z "${INSTALL}" ]] || dnf install -y $@ &> /dev/null || true
# }
# decl decl


# Set window or tab title in shell, useful for organization.
# Note, a different way to set the running title is 'export TITLE="${somethings}".
_title() (
  if [[ -z "$1" ]] ; then
    if [[ -z "${TITLE}" ]]; then
        printf "\e]0;%s %s\a" "${USER}" "${PWD}"
    else
        printf "\e]0;%s\a" "${TITLE}"
    fi	
  else
    printf "\e]0;%s\a" "$*"
  fi
); declare -fx _title



# dmesg --follow # will follow messages
dmesg() {
    sudo dmesg --human --time-format=iso --decode --color=always "$@" | less -R
}; declare -fx dmesg

dmesg.error() {
    dmesg --level=emerg,alert,crit,err "$@"
}; declare -fx dmesg.error

dmesg.user() {
    dmesg --user "$@"
}; declare -fx dmesg.user


# dnf install -y net-tools
# emacs /etc/ethers
ether.wake() {
    sudo /usr/sbin/ether-wake $@
}; declare -fx ether.wake

ether.wake.all() (
  : 'ether.wake.all apollo mick clubber'
  local -a _all=(apollo mick clubber "$@")
  for h in ${_all}; do ether.wake ${h}; done
); declare -fx ether.wake.all


gnome.restart() (
    : 'https://www.linuxuprising.com/2020/07/how-to-restart-gnome-shell-from-command.html'
    busctl --user call org.gnome.Shell /org/gnome/Shell org.gnome.Shell Eval s 'Meta.restart("Restarting…")'
); declare -fx gnome.restart


here() ( printf $(realpath -Ls $(dirname ${BASH_SOURCE[${1:-1}]})); ); declare -fx here
# herefrom() { printf "%s:%s" $(realpath -Ls ${BASH_SOURCE[${1:-1}]}) ${BASH_LINENO[${1:-1}]}; }; declare -fx herefrom


# _map f list # apply f to each element in list returning a string of results
# plus1 { printf '%s' (( 1 + $1 )); }
# declare -a _list=( $(_map plus1 1 2 3) )

_map() (
    local _f=$1; shift
    for a in $@; do printf "%s " $(${_f} $a); done 
)
declare -fx _map


where1() { realpath -Lms ${1:-${BASH_SOURCE}}/..; }
declare -fx where1
where() { _map where1 $* ; }
declare -fx where


export -a SRC;
src1() { local _s=$(pn1 $1); [[ -f "${_s}" ]] && source ${_s} && SRC+=${_s} ; }
declare -fx src1

src0() {
    : "@usage: src ${_dir} # sources all .sh files in a tree; src ${_file} ..."
    local _ext=sh
    for _a in "$@"; do
	if [[ -d "${_a}" ]] ; then
	    for _f in $(find "${_a}" -name \*.${_ext}); do source ${_f}; done
	else
	    for _f in "$@"; do src1 ${_f}; done
	fi
    done    
}; declare -fx src0

src() {
    for p in "$@"; do
       [[ -f "$p" ]] && source $p || for f in $(find "$p" -name \*.sh -type f 2>/dev/null); do source "${f}"; done
    done    
}; declare -fx src



error() {
    local -i _status=${1:-1} ; shift || true
    >&2 printf "{\"exec\": $0, \"status\": ${_status}, \"message\": \"$*\"}"
    exit ${_status}
}
declare -fx error

# TODO mcarifio@ciq.co: need a stacktrace here
# on_exit() {
#     local -i _status=$?
#     local _self=${FUNCNAME[0]}

#     # (( ${_status} )) || error ${_status} $*
#     exit ${_status}
# }
# declare -fx on_exit

xwalk() {
    local _top=${1:?'expecting a root directory'} ; shift || true
    local _ext=${1:-sh} ; shift || true
    find -L ${_top} -path \*/enabled.d/\*.${_ext} -type f -executable -exec '{}' $* \;
}
declare -fx xwalk

mkurl() {
    local _self=${FUNCNAME[0]}
    local _url=${1:?'expecting a url'}
    local _pn=${2:?'expecting a pathname'}
    printf "#!/usr/bin/env xdg-open\n%s" ${_url} | install -m 0755 /dev/stdin ${_pn}
}
declare -fx mkurl


# never can remember the entire name
if uhave com.github.johnfactotum.Foliate; then
   foliate() { command com.github.johnfactotum.Foliate $* & }
   # from epel
   # nb: there are snap and flatpak installs as well. they suck.
   declare -fx foliate # dnf install foliate
fi



all-hosts() ( arp $@ | tail -n+2 | cut -c1-25 | sort | uniq; )
declare -fx all-hosts # hping3


# sudo dnf install -y uuid
if uhave sos; then
   sosr() { sudo sos report --batch --case-id="${SUDO_USER}-$(uuidgen)" --description "${FUNCNAME}" $*; }
   declare -fx sosr
fi

# go repl
yaegi() { rlwrap command yaegi $@; }
declare -fx yaegi # rlwrap


# Can't get lazier than this.
if uhave okular; then
   ok() { okular $* & }
   declare -fx ok
fi
   

# pip from the current python directly; coordinate afterwards with asdf and bash
# hack
pipi() { python -m pip install -U $*; asdf reshim python; hash -r; }
declare -fx pipi

# pdf renaming
pdf.creationdate() { pdfinfo "$1" | grep '^CreationDate:'| awk '{print $6}'; }
declare -fx pdf.creationdate # dnf install pdfinfo

pdf.author() {
  local _author=$(pdfinfo "$1" | grep '^Author:' - | awk '{print $3}' - &> /dev/null )
  echo ${_author,,}
}
declare -fx pdf.author

pdf.add-date() {
  local _date=$(pdf.creationdate $1)
  if [[ -z "${_date}" ]] ; then
    >&2 printf "no creation date found for %s\n" $1
    return 1
  fi
  local _target=${1%%.pdf}-${_date}.pdf
  mv $1 ${_target}
  echo ${_target}
}
declare -fx pdf.add-date

pn.deparen() {
  for f in "$@"; do
    local _f="${f//\(/}"
    _f="${_f//\)/}"
    mv "$f" "${_f}" && printf "%s " "${_f}"
  done  
}
declare -fx pn.deparen

pdf.mv() {
  # if [[ -r "$1" ]]; then
  #   >&2 printf "'%s' not found\n" "$1"
  #   return 1
  # fi
  : pdf.mv ${_src} ${_location} [${_prefix}]
  local _src="$1"
  local _prefix="${2:-$(basename ${_src} .pdf)}"
  local _location="${3:-${PWD}}"
  local _date=$(pdf.creationdate "${_src}")
  if [[ -z "${_date}" ]] ; then
    >&2 printf "no creation date found for %s\n" "${_src}"
    return 1
  fi

  mv -v "${_src}" "$(md ${_location})/${_prefix}-${_date}.pdf"
}
declare -fx pdf.mv

zlib.title() {
  local _title=${1:?'expecting a pathname'}
  _title=${_title%%---*}
  if [[ "${_title}" =~ ^([^[[:punct:]]]+)$ ]] ; then
    _title=${BASH_REMATCH[1]}
  fi
  _title=${_title,,}
  _title=${_title// /-}
  echo ${_title}
}
declare -fx zlib.title

zlib.lastname0() {
  if [[ "$1" =~ [[:space:]]by[[:space:]][a-zA-Z]+[[:space:]]([a-zA-Z]+) ]] ; then
    echo ${BASH_REMATCH[1],,}
  fi
}

# fix later
zlib.lastname() {
  local _pathname=${1:?'need a pathname'}
  [[ -r "${_pathname}" ]] || { >&2 echo "'${_pathname}' not readable." ; return 1; }
  local _result=$(pdf.author "${_pathname}" &> /dev/null) || true
  [[ -n "${_lastname}" ]] && { echo ${_lastname}; return 0; }
  if [[ "${_pathname}" =~ ---([^[[:punct:]]+).*--- ]] ; then
    declare -a _name=( ${BASH_REMATCH[1],,} )
    echo ${_name[-1]}
  fi
}

zlib.date() {
  local _pathname=${1:?'need a pathname'}
  [[ -r "${_pathname}" ]] || { >&2 echo "'${_pathname}' not readable." ; return 1; }
  local _result=$(pdf.creationdate "${_pathname}" &> /dev/null) || true
  if [[ -n "${_result}" ]] ; then
    echo ${_result}
  elif [[ "${_pathname}" =~ ---([[:digit:]]{4}) ]] ; then
    echo ${BASH_REMATCH[1],,}
  fi
}
declare -fx zlib.date

zlib.mv() (
  # zlib.mv ${_src} ${_dir} [${_title} [${_lastname} [${_yyyy}]]]
  # zlib.mv [--dir=pathname] [--title=prefix] [--author=name] [--date=yyyy] doc.{epub,pdf}  

    set -Eeuo pipefail
    local _dir="${PWD}" _title="" _lastname="" _date=""
    if (( ${#@} )) ; then
        for _a in "${@}"; do
            case "${_a}" in
		--dir=*)  _dir="${_a#--dir=}";;
		--title=*)  _title="${_a#--title=}";;
		--lastname=*)  _lastname="${_a#--lastname=}";;
		--date=*)  _date="${_a#--date=}";;		
                --) shift; break;;
                *) break;;
            esac
            shift
        done
    fi

    
    local _src="${1:?'expecting a file name'}"
    [[ -e "${_src}" ]] || { >&2 echo "${_src} not found"; return 1; }

  [[ -e "${_dir}" && ! -d "${_dir}" ]] && { >&2 echo "${_dir} is a file"; return 1; }
  [[ ! -d "${_dir}" ]] && { >&2 echo "${_dir} does not exist"; return 1; }
  [[ -z "${_title}" ]] && _title=$(zlib.title "${_src}")
  [[ -z "${_lastname}" ]] && _lastname=$(zlib.lastname "${_src}")
  [[ -z "${_date}" ]] && _date=$(zlib.date "${_src}")
  local _ext=${_src##*.}
  local _dest="${_dir}/${_title}-${_lastname}-${_date}.${_ext}"

  if [[ "${_ext}" = pdf ]]; then
      mv "${_src}" "${_dest}"
      xz "${_dest}"
      >&2 echo "${_dest}" 
  else
      mv "${_src}" "${_dest}"
      >&2 echo "${_dest}" 
  fi
)
declare -fx zlib.mv


for c in kind kubectl glab lab; do uhave ${c} && source <(${c} completion bash); done
for c in /usr/share/bash-completion/completions/{docker,dhclient,nmcli,nmap,ip}; do uhave ${c} && source ${c}; done

drmi() { docker rmi -f $(docker images -f "dangling=true" -q); }; declare -fx drmi
# https://docs.docker.com/engine/security/rootless/
systemctl --user is-active docker &> /dev/null && export DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock

# dnf install gcc-toolset-11
# src1 /opt/rh/gcc-toolset-11/enable

gnome-snapshot() {
  mkdir -p ~/Pictures/snapshot &> /dev/null
  local _snapshot==~/Pictures/snapshot/$(uuidgen).png
  command gnome-snapshot --area --file=${_snapshot}
  ln -srf ${_snapshot} ~/Pictures/snapshot/latest.png
  gimp ~/Pictures/snapshot/latest.png
}; declare -fx gnome-snapshot


# packer -autocomplete-install || true
if uhave packer; then
   complete -C /usr/bin/packer packer
fi
   

# oci config
if uhave oci; then
   export OCI_CLI_SUPPRESS_FILE_PERMISSIONS_WARNING=True
   export OCI_CLI_CONFIG_FILE=${HOME}/.config/cloud/oci/config
fi

main() {
    local _action=${1:-start} ; shift || true
    ${_action} $*    
}; declare -fx main


add.user() {
  : 'add.user doomemacs 2000 "passwd"'
  sudo adduser -G wheel -m -u ${2:?'expecting a uid'} ${1:?'expecting a username'}
  [[ -n "${3:-}" ]] && sudo passwd --stdin ${1} <<< "${3}"
}
declare -fx add.user

if uhave bcompare; then
   bcompare() { QT_GRAPHICSSYSTEM=native command bcompare "$@"; }
   declare -fx bcompare
fi


if uhave copyq; then
  copyq() {
     QT_QPA_PLATFORM=xcb command copyq $*
  }; declare -fx copyq
fi

if uhave alacritty; then
  sudo.alacritty() (
    local _title=${1:?'expecting a title'}; shift
    sudo -E alacritty --title "${_title}" --option window.dimensions.{lines=50,columns=300} --command "$@"
  ); declare -fx sudo.alacrity

  watch.input() (
    sudo.alacritty ${FUNCNAME} /mopt/showmethekey/current/bin/showmethekey-cli &
  ); declare -fx watch.input

  watch.dmesg() (
    sudo.alacritty ${FUNCNAME} dmesg -HT --color=always --follow &
  ); declare -fx watch.dmesg
fi
    

# returns 0 iff command is running
is.running() {
    (( $(ps aux | grep -F " ${1:?'expecting a command'} " | wc -l) > 1 ))
}; declare -fx is.running


# singleton ${cmdline} # runs command iff not yet running
p.singleton() {
    local _cmd=${1:? 'expecting a command'}; shift
    is.running $(type -p ${_cmd}) && return 0
    ${_cmd} "$@"
    echo $!
}; declare -fx p.singleton


# arp.scan -I eno1 > /etc/dsh/lan
# pdsh -g lan id
arp.scan() {
  sudo arp-scan -l $@ | tail -n+3 | head -n-3 | cut -f1 |sort | uniq
}
declare -fx arp.scan

mnt.iso() {
    : 'mnt.iso .iso [/optional/mountpoint/prefix] # mount .iso as a loopback device'
    local _iso=${1:?'expecting an iso'}
    local _mountpoint=${2:-/mnt/isofs/$(basename ${_iso} .iso)}
    sudo install -o ${USER} -g ${USER} -d ${_mountpoint}
    sudo mount -o loop ${_iso} ${_mountpoint}
}
declare -fx mnt.iso


# arp.scan -I eno1 > /etc/dsh/lan
# pdsh -g lan id
arp.scan() {
  sudo arp-scan -l $@ | tail -n+3 | head -n-3 | cut -f1 |sort | uniq
}
declare -fx arp.scan



url.exists() ( curl --HEAD --silent ${1:?'expecting a url'} &> /dev/null; ); declare -fx url.exists

# a better whois, note the spelling
wh0is() (
    local _name=${1:?'expecting a domain name, e.g. carif.io'}
    if whois ${_name} &> /dev/null; then
        echo "${_name} registered."
        local _url="http://${_name}"        
        url.exists "${_url}" && type -t b.personal &> /dev/null && b.personal "${_url}"
    else
        echo "${_name} available."
    fi	
); declare -fx wh0is






function f.defined? {
  : 'f.defined? ${function} ... # true if all functions are defined'
  type -t -- "$@" > /dev/null
}; declare -fx f.defined?

dnf.off() (
    for _h in "$@"; do
        ssh root@${_h} { dnf upgrade -y && shutdown -h now }
    done
    sudo dnf upgrade -y && sudo shutdown -h now
); declare -fx dnf.off

dnf.off.all() ( dnf.off mick paulie clubber; ); declare -fx dnf.off.all

tbird.logged() ( NSPR_LOG_MODULES=SMTP:4,IMAP:4 NSPR_LOG_FILE=/tmp/thunderbird-$$.log thunderbird; ); declare -fx tbird.logged

pyz() {
    local -r _url=${1:?'expecting a url'} ; shift
    wget ${_url} || return 1
    local -r _pyz=$(basename ${_url})
    python ${_pyz} "$@"
} ; declare -fx pyz

    


# https://www.linuxuprising.com/2020/07/how-to-restart-gnome-shell-from-command.html
gnome.restart() (
    busctl --user call org.gnome.Shell /org/gnome/Shell org.gnome.Shell Eval s 'Meta.restart("Restarting…")'
); declare -fx gnome.restart

