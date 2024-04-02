# usage: [guard | source] gio.guard.sh [--install] [--verbose] [--trace]

_guard=$(path.basename ${BASH_SOURCE})
declare -A _option=([install]=0 [verbose]=0 [summarize]=0 [trace]=0)
_undo=''; trap -- 'eval ${_undo}; unset _option _undo; trap -- - RETURN' RETURN

# declare -a _rest=( $(u.parse _option "$@") )
&> /dev/null u.parse _option "$@"
# declare -p _option

if (( ${_option[trace]} )) && ! bashenv.is.tracing; then
    _undo+='set +x;'
    set -x
fi

# install by distro id by (runtime) dispatching to distro install function
eval "${_guard}.install() ( ${_guard}.install.\$(os-release.id); )"
f.x ${_guard}.install

eval "${_guard}.install.fedora() ( set -x; dnf install glib2; )" ## untested
f.x ${_guard}.install.fedora

eval "${_guard}.install.ubuntu() ( set -x; sudo apt upgrade -y; sudo apt install -y glib2; )" ## untested
f.x ${_guard}.install.ubuntu

# source ${_guard}.guard.sh --install
if (( ${_option[install]} )) && ! u.have ${_guard}; then
    ${_guard}.install ${_rest} || return $(u.error "${_guard}.install failed")
fi



# _gio itself

desktop.data_dirs() (
    : 'desktop.data_dirs # return all directories to look for .desktop files'
    echo ${XDG_DATA_DIRS//:/\/applications } /usr/share/xfce4/helpers ${HOME}/.local/share/applications /usr/share/applications;
)
f.complete desktop.data_dirs

# find the full pathname of an application's desktop file by searching for it in well known locations.
desktop.which() ( 
    : 'desktop.find ${name} # find the first .desktop file that matches ${name}'
    local -r _app=${1?'expecting an app'}
    for _d in $(desktop.data_dirs); do
	local _desktop=$(2>/dev/null find "${_d}" -maxdepth 1 -name \*"${_app}".desktop -print)
	[[ -r "${_desktop}" ]] && { echo "${_desktop}"; return 0; }
    done
    >&2 echo "${_app} not found"
    return 1

)
f.complete desktop.which

# launch a .desktop file at the command line
desktop.launch() (
    : 'desktop.launch [--sudo] ${pathname} ... # launch ${pathname}.desktop as root or ${USER}'
    local -i _sudo=0
    if (( ${#@} )) ; then
        for _a in "${@}"; do
            case "${_a}" in
		--sudo) _sudo=1;;
		
                --) shift; break;;
                *) break;;
            esac
            shift
        done
    fi
    local -r _desktop="${1?'expecting an app'}"
    [[ -z "${_desktop}" ]] && { >&2 echo "${_desktop} not found"; return 1; }
    shift
    (( _sudo )) && (set -x; sudo -E gio launch "${_desktop}" "$@") || (set -x; gio launch "${_desktop}" "$@")
)
f.complete desktop.launch


desktop.run() (
    : 'desktop.run ${pathname} [--sudo] ... # launch ${name}.desktop as root or ${USER}'
    local -r _app=${1?'expecting an app'}; shift
    desktop.launch $(desktop.which ${_app}) "$@"
)
f.complete desktop.run


desktop.grep.exec() (
    : 'desktop.grep.exec ${re} # find all .desktop files whose Exec= matches ${re}'
    local -r _re=${1:?'expecting a regular expression'}
    for _d in $(desktop.data_dirs); do
	# (set -x; grep "^Exec=[[:space:]]*${_re}" $(2>/dev/null find "${_d}" -maxdepth 1 -name \*.desktop -print) /dev/null) || true
	# TODO apply realpath to pathname
	grep "^Exec=[[:space:]]*${_re}" $(2>/dev/null find "${_d}" -maxdepth 1 -name \*.desktop -print) /dev/null || true
    done | sort | uniq
)
f.complete desktop.grep.exec

desktop.grep.basename() (
    : "desktop.grep.basename ${re} # find all .desktop files whose basename matches ${re}, e.g. desktop.grep.basename '/.*Edge'"
    local -r _re=${1:?'expecting a regular expression'}
    for _d in $(desktop.data_dirs); do
	# (set -x; 2>/dev/null find "${_d}" -maxdepth 1 -regex "${_re}"'\.desktop$' -print)
	2>/dev/null find "${_d}" -maxdepth 1 -regex "${_re}"'\.desktop$' -print
    done
)
f.complete desktop.grep.basename

loaded "${BASH_SOURCE}"
