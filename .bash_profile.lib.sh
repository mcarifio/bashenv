## f

# https://www.gnu.org/software/bash/manual/html_node/Programmable-Completion.html

# bashenv traffics (mostly) in bash functions that follow these conventions:
#   - they're named ${something}.{something} e.g f.complete. bash completes on .
#   - they are exported global for subshells
#   - they optionally have a completion function named __${fn}.complete which will help the user complete
#       fn's arguments
#   - the first line of the function definition is : 'text' which acts as a docstring



declare -Ax __bashenv_loaded=()

# f.exists
__f.exists.complete() {
    local _command=$1 _word=$2 _previous_word=$3
    COMPREPLY=( $(f.match $2) )
}
f.exists() {
    : '${f} # return 0 iff bash function ${f} exists (is defined)'a
    [[ function = $(type -t "${1}") ]]
}


# This is a pattern. It will make sense after you've seen it a few times.
# f.complete
__f.complete.complete() {
    local _command=$1 _word=$2 _previous_word=$3
    COMPREPLY=( $(f.loaded.match "$2") )
}
f.complete() {
    : '${fn} # export ${fn} for subshells and connect to a completion fn __${fn}.complete iff it exists'
    local _f=${1:?'expecting a function'}
    local _fc=__${_f}.complete
    f.exists ${_f} || return 1
    declare -gfx ${_f}
    __bashenv_loaded[${_f}]=$(date)
    f.exists ${_fc} || return 0
    declare -gfx ${_fc}
    complete -F ${_fc} ${_f}
}
f.complete f.complete
# Unwound the circularity, you can now bash complete f.exists.
f.complete f.exists

# plus1, useful to test u.map next
__example.plus1.complete() {
    local _command=$1 _word=$2 _prev=$3
    >&2 printf "(int...) "
}
example.plus1() (
    : '${number} #> 1 + ${number} # a useful example for u.map'
    echo $(( $1 + 1 ))
)
f.complete example.plus1


# u.map
__u.map.complete() {
    local _command=$1 _word=$2 _previous_word=$3
    COMPREPLY=( $(f.loaded.match "$2") )
}
u.map() {
    : '${f} ... # apply $f to each item in the list ... and return the result'
    local _f=${1:?'expecting a function'}; shift
    for _a in "$@"; do ${_f} ${_a} || return $?; done 
}
f.complete u.map

# u.map.mkall
__u.map.mkall.complete() {
    local _command=$1 _word=$2 _previous_word=$3
    COMPREPLY=( $(f.loaded.match "$2") )
}
u.map.mkall() {
    : '${f} # defines a global function ${f}.all that applies $f} to each argument and returns the result'
    local _f=${1:?'expecting a function'}; shift
    local _all=${_f}.all
    eval $(printf '%s() { u.map %s "$@"; }; declare -fx %s' ${_all} ${_f} ${_all})
}
f.complete u.map.mkall



# f.loaded
f.loaded() {
    : '#> return all functions loaded (so far)'
    printf '%s\n' ${!__bashenv_loaded[@]}
}
f.complete f.loaded


# f.loaded.match
__f.loaded.match.complete() {
    local _command=$1 _word=$2 _previous_word=$3
    COMPREPLY=( $(f.loaded.match "$2") )
}
f.loaded.match() {
    : '${prefix:-""} #> echo all bashenv functions matching ${prefix} '
    f.loaded | \grep "^$1"
}
f.complete f.loaded.match

# f.match, circular
__f.match.complete() {
    local _command=$1 _word=$2 _previous_word=$3
    COMPREPLY=( $(f.match "$2") )
}
f.match() {
    : '${prefix} #> echo all bash functions matching ${prefix}'
    declare -F | cut -d' ' -f3 | \grep -E "^$1"
}
f.complete f.match


# f.doc
__f.doc.complete() {
    local _command=$1 _word=$2 _previous_word=$3
    COMPREPLY=( $(f.loaded.match "$2") )    
}
f.doc() {
    : '${function} # echos the docstring of a function to stdout'		    
    local _f=${1:?'expecting a function'}
    if [[ $(type -t ${_f}) = "function" ]] ; then
	echo -n "${_f} "
	type ${_f} | awk "match(\$0,/\s+:\s+'(.*)'/,m) { print m[1]; }"
    else
	>&2 echo "'function ${_f}' not found"
	return 1
    fi
}
f.complete f.doc


running.bash() {
    : '# return 0 iff you are in bash (your parent process is the bash shell)'
    realpath /proc/$$/exe | grep -Eq 'bash$' || return 1
}
f.complete running.bash

home() (
    : '[${user}:-${USER}] #> the login directory of the${user}.'
    getent passwd ${1:-${SUDO_USER:-${USER}}} | cut -d: -f6
)
f.complete home


# Return the full pathname of the bashenv root directory, usually something like ${HOME}/bashenv.
# Depends on where you placed it however.
eval "bashenv.root() ( echo $(dirname $(realpath ${BASH_SOURCE})); )"; declare -fx bashenv.root

path.login() (
    : '#> echos interesting directories under $(home)'
    printf '%s:' $(home)/opt/*/current/bin $(home)/.config/*/bin
)
f.complete path.login


# path.add
path.add() {
    : '${folder}... ## adds ${folder} to PATH iff not already there'
    for _a in "$@"; do
	local _p=$(realpath -L ${_a})
	case ":${PATH}:" in
            *:"${_p}":*) ;;
            *) PATH="${_p}:$PATH"
	esac
    done
}
__path.add.complete() {
    local _command=$1 _word=$2 _previous_word=$3
    # return list of possible directories https://stackoverflow.com/questions/12933362/getting-compgen-to-include-slashes-on-directories-when-looking-for-files/40227233#40227233a
    COMPREPLY=( $(compgen -d -- $2) )    
}
f.complete path.add



# path.walk
path.walk() (
    : '${folder} [${min} [${max}]] #> all directories under ${folder}'
    local -r _root=${1:-${PWD}}
    local -ri _maxdepth=${2:-1}
    local -ri _mindepth=${3:-1}
    find "${_root}" -mindepth ${_mindepth} -maxdepth ${_maxdepth} -type d -regex '.*/[^\.]+$'
)
__path.walk.complete() {
    local _command=$1 _word=$2 _previous_word=$3
    # return list of possible directories https://stackoverflow.com/questions/12933362/getting-compgen-to-include-slashes-on-directories-when-looking-for-files/40227233#40227233a
    COMPREPLY=( $(compgen -d -- $2) )    
}
f.complete path.walk

path.pn() ( realpath -Lms ${1:-${PWD}}; ); declare -fx path.pn
u.map.mkall path.pn

# full pathname 1
path.fpn() ( echo -n ${HOSTNAME}:; realpath -Lms ${1:-${PWD}}; ); declare -fx path.fpn
u.map.mkall path.fpn


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

u.have() ( &> /dev/null type ${1?:'expecting a command'} || return 1; ); declare -fx u.have
u.map.mkall u.have # u.have.all

u.call() {
    local _f=${1:?'expecting a command'}; shift
    u.have ${_f} || return 0
    ${_f} "$@"
}; declare -fx u.call


u.error() {
    : 'u.error [--return] this is a message' 
    local -i _status=${1:-1} ; shift || true
    local _finally=exit
    if [[ "$1" = --return ]]; then
	_finally=return
	shift
    fi    
    >&2 printf "{\"exec\": $0, \"status\": ${_status}, \"message\": \"$*\"}"
    ${_finally} ${_status}
}; declare -fx u.error


## guard


guard.for() {
    : 'guard.for ${command}... # '
    running.bash || return 1
    u.have.all "$@" || return 1
}; declare -fx guard.for

guard() {
    : 'guard ${pathname} [${command}] # source ${pathname} iff ${command} resolves'
    local _pathname=${1:-'expecting a pathname'}; shift
    local _for=${2:-$(path.basename ${_pathname})}; shift
    guard.for ${_for} || return 0
    if ! source ${_pathname} "$@"; then
	>&2 echo "${_pathname} => $?, continuing..."
	return 0
    fi
    u.call ${_for}.env "$@" || >&2 echo "${_for}.env => $?, continuing..."
    return 0
}; declare -fx guard

_template() ( echo ${FUNCNAME}; ); declare -fx _template
 
u.map.tree() {
    local _action=${1:?'expecting an action, e.g. source or guard'}
    local _folder=${2:?'expecting a folder'}
    [[ -d "${_folder}" ]] || { >&2 echo "${_folder} is not a folder"; return 1; }
    u.map ${_action} $(find "${_folder}" -type f -regex "[^#]+\.${_action}\.sh\$")        
}; declare -fx u.map.tree

u.or() ( echo "$@" | cut -d' ' -f1; ); declare -fx u.or

u.shell() {
  : 'u.shell # this shell, always bash. But the SHELL env variable can be unreliable'
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


u.where() { realpath -Lms ${1:-${BASH_SOURCE}}/..; }; declare -fx u.where
u.map.mkall u.where # u.where.all



u.xwalk() {
    local _top=${1:?'expecting a root directory'} ; shift || true
    local _ext=${1:-sh} ; shift || true
    find -L ${_top} -path \*/enabled.d/\*.${_ext} -type f -executable -exec '{}' $* \;
}; declare -fx u.xwalk

u.mkurl() {
    local _self=${FUNCNAME[0]}
    local _url=${1:?'expecting a url'}
    local _pn=${2:?'expecting a pathname'}
    printf "#!/usr/bin/env xdg-open\n%s" ${_url} | install -m 0755 /dev/stdin ${_pn}
}; declare -fx u.mkurl


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
   sos.r() { sudo sos report --batch --case-id="${SUDO_USER}-$(uuidgen)" --description "${FUNCNAME}" $*; }; declare -fx sos.r
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

dispatch() {
    local _action=${1:-start} ; shift || true
    ${_action} $*    
}; declare -fx dispatch


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





