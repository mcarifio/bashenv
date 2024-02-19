running.bash() { realpath /proc/$$/exe | grep -Eq 'bash$' || return 1; }; declare -fx running.bash
# has() ( &> /dev/null type ${1?:'expecting a command'} || return 1; ); declare -fx has
# has.all() ( for _a in "$@"; do has $_a; done; ); declare -fx has.all
u.have() ( &> /dev/null type ${1?:'expecting a command'} || return 1; ); declare -fx u.have
u.have.all() ( for _a in "$@"; do has $_a; done; ); declare -fx u.have.all
# uhave() { >&2 echo ${BASH_SOURCE[@]}; }; declare -fx uhave
u.call() {
    local _f=${1:?'expecting a command'}; shift
    u.have ${_f} || return 0
    ${_f} "$@"
}; declare -fx u.call

home() (
    : 'home [${user}] #> the login directory of the optional user.'
    getent passwd ${1:-${SUDO_USER:-${USER}}} | cut -d: -f6
); declare -fx home

# Return the full pathname of the bashenv root directory, usually something like ${HOME}/bashenv.
# Depends on where you placed it however.
eval "bashenv.root() ( echo $(dirname $(realpath ${BASH_SOURCE})); )"; declare -fx bashenv.root

path.login() (
    : 'path.login will return interesting directories under ${HOME}'
    printf '%s:' $(home)/opt/*/current/bin $(home)/.config/*/bin
); declare -fx path.login

path.add() {
    : 'path.add ${folder} [after] ## adds ${folder} to PATH iff not already there'
    case ":${PATH}:" in
        *:"$1":*)
            ;;
        *)
            if [ "$2" = "after" ] ; then
                PATH=$PATH:$1
            else
                PATH=$1:$PATH
            fi
    esac
}; declare -fx path.add


path.walk() (
    : 'path.walk ${folder} [${min} [${max}]] #> all directories under ${folder}'
    local -r _root=${1:-${PWD}}
    local -ri _maxdepth=${2:-1}
    local -ri _mindepth=${3:-1}
    find . -mindepth ${_mindepth} -maxdepth ${_maxdepth} -type d -regex '.*/[^\.]+$'
); declare -fx path.walk

path.pn1() ( realpath -Lms ${1:-${PWD}}; ); declare -fx path.pn1
path.pn() ( _map path.pn1 $* ; ); declare -fx path.pn
# full pathname 1
path.fpn1() ( echo -n ${HOSTNAME}:; realpath -Lms ${1:-${PWD}}; ); declare -fx path.fpn1
# full pathname
path.fpn() ( _map path.fpn1 $* ; ); declare -fx path.fpn

path.basename() (
    local _pn=${1:?'expecting a pathname'}
    local _result=${_pn##*/}
    echo ${_result%%.*}
); declare -fx path.basename

path.md() (
    : 'path.md ## make a directory and return its pathname, e.g cp foo $(path.md /tmp/foo)/bar'
    local _d=$(path.pn1 $1)
    [[ -d "$_d" ]] || mkdir -p ${_d}
    printf "%s" ${_d}
); declare -fx path.md

path.mkcd() {
    local _d=$(path.md $1); [[ -z "${_d}" ]] || cd -Pe ${_d}
}; declare -fx path.mkcd

path.mp() ( local _p=$(printf "%s/%s" $(md $1/..) ${1##*/}); printf ${_p}; ); declare -fx path.mp
path.mpt() ( local _p=$(printf "%s/%s" $(md $1/..) ${1##*/}); touch ${_p}; printf ${_p}; ); declare -fx path.mpt
path.mpcd() ( cd $(dirname $(mp ${1:?'expecting a pathname'})); ); declare -fx path.mpcd

source.guard() {
    local _for=${1:?'expecting a command'}
    running.bash || return 1
    u.have ${_for} || return 1
}; declare -fx source.guard

source.guarded_source() {
    local _pathname=${1:-'expecting a pathname'}; shift
    local _for=${2:-$(path.basename ${_pathname})}; shift
    source.guard ${_for} || return 0
    source ${_pathname}
    u.call ${_for}.env "$@"
}; declare -fx source.guarded_source

_template() ( echo ${FUNCNAME}; ); declare -fx _template
 
source.all() {
    for _a in $@; do
	source "${_a}" || >&2 echo "'${_a}' => $?" || true
    done
}; declare -fx source.all

source.find() {
    local -r _root="${1:?'expecting a folder'}"
    source.all $(find "${_root}" -regex '[^#]+\.source\.sh$')
}; declare -fx source.find

source.bash_profile.d() {
    source.find $(bashenv.root)/.bash_profile.d
}; declare -fx source.bash_profile.d

source.bashrc.d() {
    source.find $(bashenv.root)/.bashrc.d
}; declare -fx source.bashrc.d

source.bash_completion.d() {
    source.find $(bashenv.root)/.bash_completion.d
}; declare -fx source.bash_completion.d

u.or() ( echo "$@" | cut -d' ' -f1; ); declare -fx u.or

u.shell() {
  : 'return your login shell; the SHELL env variable can be unreliable'
  basename $(realpath /proc/$$/exe)
}; declare -fx u.shell




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
    : 'https://www.linuxuprising.com/2020/07/how-to-restart-gnome-shell-from-command.html, only works for X'
    busctl --user call org.gnome.Shell /org/gnome/Shell org.gnome.Shell Eval s 'Meta.restart("Restarting…")'
); declare -fx gnome.restart


u.here() ( printf $(realpath -Ls $(dirname ${BASH_SOURCE[${1:-1}]})); ); declare -fx u.here

# u.map f list # apply f to each element in list returning a string of results
# plus1 { printf '%s' (( 1 + $1 )); }
# declare -a _list=( $(u.map plus1 1 2 3) )

u.map() (
    local _f=$1; shift
    for a in $@; do printf "%s " $(${_f} $a); done 
)
declare -fx u.map


u.where1() { realpath -Lms ${1:-${BASH_SOURCE}}/..; }
declare -fx u.where1
u.where() { u.map u.where1 $* ; }
declare -fx u.where


u.error() {
    local -i _status=${1:-1} ; shift || true
    >&2 printf "{\"exec\": $0, \"status\": ${_status}, \"message\": \"$*\"}"
    exit ${_status}
}
declare -fx u.error

u.xwalk() {
    local _top=${1:?'expecting a root directory'} ; shift || true
    local _ext=${1:-sh} ; shift || true
    find -L ${_top} -path \*/enabled.d/\*.${_ext} -type f -executable -exec '{}' $* \;
}
declare -fx u.xwalk

u.mkurl() {
    local _self=${FUNCNAME[0]}
    local _url=${1:?'expecting a url'}
    local _pn=${2:?'expecting a pathname'}
    printf "#!/usr/bin/env xdg-open\n%s" ${_url} | install -m 0755 /dev/stdin ${_pn}
}
declare -fx u.mkurl


# never can remember the entire name
if u.have com.github.johnfactotum.Foliate; then
   foliate() { command com.github.johnfactotum.Foliate $* & }
   # from epel
   # nb: there are snap and flatpak installs as well. they suck.
   declare -fx foliate # dnf install foliate
fi



u.all-hosts() ( arp $@ | tail -n+2 | cut -c1-25 | sort | uniq; )
declare -fx u.all-hosts # hping3


# sudo dnf install -y uuid
if u.have sos; then
   sosr() { sudo sos report --batch --case-id="${SUDO_USER}-$(uuidgen)" --description "${FUNCNAME}" $*; }
   declare -fx sosr
fi

# go repl
yaegi() { rlwrap command yaegi $@; }
declare -fx yaegi # rlwrap


# pip from the current python directly; coordinate afterwards with asdf and bash
# hack
if u.have asdf; then
    asdf.pipi() { python -m pip install -U $*; asdf reshim python; hash -r; }
    declare -fx asdf.pipi
fi


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


for c in kind kubectl glab lab; do u.have ${c} && source <(${c} completion bash); done
for c in /usr/share/bash-completion/completions/{docker,dhclient,nmcli,nmap,ip}; do u.have ${c} && source ${c}; done

if u.have podman ; then
    podman.remove-images() { podman rmi -f $(docker images -f "dangling=true" -q); }; declare -fx podman.remove-images
fi



# dnf install gcc-toolset-11
# src1 /opt/rh/gcc-toolset-11/enable

gnome.snapshot() {
  mkdir -p ~/Pictures/snapshot &> /dev/null
  local _snapshot==~/Pictures/snapshot/$(uuidgen).png
  command gnome-snapshot --area --file=${_snapshot}
  ln -srf ${_snapshot} ~/Pictures/snapshot/latest.png
  gimp ~/Pictures/snapshot/latest.png
}; declare -fx gnome.snapshot


# packer -autocomplete-install || true
if u.have packer; then
   complete -C /usr/bin/packer packer
fi
   

# oci config
if u.have oci; then
   export OCI_CLI_SUPPRESS_FILE_PERMISSIONS_WARNING=True
   export OCI_CLI_CONFIG_FILE=${HOME}/.config/cloud/oci/config
fi

main() {
    local _action=${1:-start} ; shift || true
    ${_action} $*    
}; declare -fx main


sa.add.user() {
  : 'add.user doomemacs 2000 "passwd"'
  sudo adduser -G wheel -m -u ${2:?'expecting a uid'} ${1:?'expecting a username'}
  [[ -n "${3:-}" ]] && sudo passwd --stdin ${1} <<< "${3}"
}
declare -fx sa.add.user

if u.have bcompare; then
   bcompare() { QT_GRAPHICSSYSTEM=native command bcompare "$@"; }
   declare -fx bcompare
fi


if u.have copyq; then
  copyq() {
     QT_QPA_PLATFORM=xcb command copyq $*
  }; declare -fx copyq
fi

if u.have alacritty; then
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
u.singleton() {
    local _cmd=${1:? 'expecting a command'}; shift
    is.running $(type -p ${_cmd}) && return 0
    ${_cmd} "$@"
    echo $!
}; declare -fx u.singleton


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






function u.f-defined? {
  : 'f.defined? ${function} ... # true if all functions are defined'
  type -t -- "$@" > /dev/null
}; declare -fx u.f-defined?

sa.shutdown() (
    for _h in "$@"; do
        ssh root@${_h} { dnf upgrade -y && shutdown -h now }
    done
    sudo dnf upgrade -y && sudo shutdown -h now
); declare -fx sa.shutdown

sa.shutdown.all() ( dnf.off milhouse clubber; ); declare -fx sa.shutdown.all

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




