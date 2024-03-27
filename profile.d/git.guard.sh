# usage: [guard | source] git.guard.sh [--install] [--verbose] [--trace]
_guard=$(path.basename ${BASH_SOURCE})
declare -A _option=([install]=0 [verbose]=0 [trace]=0)
_undo=''; trap -- 'eval ${_undo}; unset _option _undo; trap -- - RETURN' RETURN
local -a _rest=( $(u.parse _option "$@") )
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

# TODO mike@carifio 02/20/24: probably obsolete
git.url.folder() (
    set -Eeuo pipefail
    : 'git.url.folder ${git-url} [${prefix:-~/src/} # return a local folder based on a git url, e.g. git.url.folder https://github.com/zotero/zotero |> ~/src/github.com/zotero/zotero/zotero'
    local -r _url=${1:?'expecting a git url'}
    local -r _suffix=${2:-${HOME}/src}
    [[ "${_url}" =~ ^https?://([^/]+)/([^/]+)/(.*)$ ]] && { echo ${_suffix}/${BASH_REMATCH[1]}/${BASH_REMATCH[2]}/${BASH_REMATCH[3]}/${BASH_REMATCH[3]}; return 0; }
    [[ "${_url}" =~ ^([^@]*@)?([^:]+):([^/]+)/(.*)\.git$ ]] && { echo ${_suffix}/${BASH_REMATCH[2]}/${BASH_REMATCH[3]}/${BASH_REMATCH[4]}/${BASH_REMATCH[4]}; return 0; }
    echo ${_suffix}/${_url}    
)
declare -fx url.git.folder


# TODO mike@carif.io 02/20/24: probably obsolete
git.pn2url() (
  : 'usage: git clone $(git.pn2url)'
  local _home=${2:-${HOME}/src}
  local _dir=${1:-${PWD}}
  local _pn=$(realpath --relative-to=${_home} --strip ${_dir})
  local _url=${_pn%%/*}:${_pn#*/}
  # local _work_dir=${_dir}/${_pn##*/}
  # echo ${_url} ${_work_dir}
  # git clone ${_url} ${_work_dir}
  echo ${_url}
)
declare -fx git.pn2url



# TODO mike@carif.io 02/20/24: probably obsolete
git.repopath() (
    dirname $(find ${_here} -name .git -type d -minpath 2 -maxpath 2);
)
declare -fx git.repopath

git.clcd() {
    : 'git.clcd ${url} [${folder}] # clone ${url} into ${folder} and cd to it'
    local _url=${1:?'expecting a url'}
    local _folder=${2:-${_url##*/}}
    _folder=${_folder//./\/}
    git clone --verbose ${_url} ${_folder}
    [[ -r ${_folder}/.envrc ]] && u.have dotenv && dotenv allow ${_folder}
    cd ${_folder}
}
declare -fx git.clcd


git.unzip() (
    : '${_url} [${_folder} [${_glob}]] # copy part the contents of a git repo at ${_url} into ${_folder} taking only the parts that match ${_glob}'
    set -Eeu -o pipefail
    local _url="${1:?'expecting a url to a zip file'}"
    local _here=${2:-${PWD}}
    local _tmpdir=$(mktemp -d --suffix=-${FUNCNAME})
    curl -sSL "${_url}" | bsdtar -C ${_tmpdir} -s '|[^/]*/||' -xf -
    mv ${_tmpdir}/* $(path.md ${_here})
    rm -rf ${_tmpdir}
)
declare -fx git.unzip

loaded "${BASH_SOURCE}"
