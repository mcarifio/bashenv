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
f.complete url.git.folder


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
f.complete git.pn2url



# TODO mike@carif.io 02/20/24: probably obsolete
git.repopath() (
    dirname $(find ${_here} -name .git -type d -minpath 2 -maxpath 2);
)
f.complete git.repopath

git.clcd() {
    : 'git.clcd ${url} [${folder}] # clone ${url} into ${folder} and cd to it'
    local _url=${1:?'expecting a url'}
    local _folder=${2:-${_url##*/}}
    _folder=${_folder//./\/}
    git clone --verbose ${_url} ${_folder}
    [[ -r ${_folder}/.envrc ]] && u.have dotenv && dotenv allow ${_folder}
    cd ${_folder}
}
f.complete git.clcd




