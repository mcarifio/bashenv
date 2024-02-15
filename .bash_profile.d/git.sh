running.bash && u.have $(basename ${BASH_SOURCE} .sh) || return 0

git.url.folder() (
    set -Eeuo pipefail
    : 'git.url.folder ${git-url} [${prefix:-~/src/} # return a local folder based on a git url, e.g. git.url.folder https://github.com/zotero/zotero |> ~/src/github.com/zotero/zotero/zotero'
    local -r _url=${1:?'expecting a git url'}
    local -r _suffix=${2:-${HOME}/src}
    [[ "${_url}" =~ ^https?://([^/]+)/([^/]+)/(.*)$ ]] && { echo ${_suffix}/${BASH_REMATCH[1]}/${BASH_REMATCH[2]}/${BASH_REMATCH[3]}/${BASH_REMATCH[3]}; return 0; }
    [[ "${_url}" =~ ^([^@]*@)?([^:]+):([^/]+)/(.*)\.git$ ]] && { echo ${_suffix}/${BASH_REMATCH[2]}/${BASH_REMATCH[3]}/${BASH_REMATCH[4]}/${BASH_REMATCH[4]}; return 0; }
    echo ${_suffix}/${_url}    
); declare -fx url.git.folder


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
); declare -fx git.pn2url



# TODO error unless theirs' only one
git.repopath() (
    dirname $(find ${_here} -name .git -type d -minpath 2 -maxpath 2);
); declare -fx git.repopath



