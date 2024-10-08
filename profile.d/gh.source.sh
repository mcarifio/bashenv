${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

gh.repo.clone() {
    : '${name} [${folder}] [--private] # creates github repo ${name} for default github user. --private overrides --public'
    local _repo=${1:?'expecting a repo name'}; shift
    local _folder=$1; shift    
    local _git_dir=$(2>&1 > /dev/null gh repo clone ${_repo} ${_folder} -- "$@"| awk $'match($0, /^Cloning into \'([^\']+)\'\.\.\./, m) { print m[1]; }')
    cd ${_git_dir}
}
f.x gh.repo.clone


gh.repo.create() {
    : '${name} [${folder}] [--private] # creates github repo ${name} for default github user. --private overrides --public'
    local _repo=${1:?'expecting a repo name'}; shift
    local _folder="$2"
    gh repo create ${_repo} --add-readme --description "tbs ${_repo}" --public
    # local _git_dir=$(2>&1 >/dev/null git clone gh:${USER}/${_repo} ${_folder} | awk $'match($0, /^Cloning into \'([^\']+)\'\.\.\./, m) { print m[1]; }' )
    git clone gh:${USER}/${_repo} ${_folder}
    cd ${_git_dir}
}
f.x gh.repo.create

gh.repo.delete() (
    : 'gh.repo.delete ${name} # deletes the github repo named ${name} e.g. mcarifio/try1'
    set -Eeuo pipefail
    local _repo=${1:?'expecting a repo name'}; shift
    gh repo delete --yes ${_repo}
)
f.x gh.repo.delete

# gh.env() {
#     return 0 
# }
# f.x gh.env

gh.session() {
    source <(gh completion -s $(u.shell 2>/dev/null || echo bash)) || u.error
}
f.x gh.session

sourced || true

