# dnf install -y gh

# TODO mike@carif.io: needs testing

gh.repo.clone() {
    : '${name} [${folder}] [--private] # creates github repo ${name} for default github user. --private overrides --public'
    local _repo=${1:?'expecting a repo name'}; shift
    local _folder=$1; shift    
    local _git_dir=$(2>&1 > /dev/null gh repo clone ${_repo} ${_folder} -- "$@"| awk $'match($0, /^Cloning into \'([^\']+)\'\.\.\./, m) { print m[1]; }')
    cd ${_git_dir}
}
f.complete gh.repo.clone


gh.repo.create() {
    : '${name} [${folder}] [--private] # creates github repo ${name} for default github user. --private overrides --public'
    local _repo=${1:?'expecting a repo name'}; shift
    local _folder="$2"
    gh repo create ${_repo} --add-readme --description "tbs ${_repo}" --public "$@"
    local _git_dir=$(2>&1 >/dev/null git clone gh:${USER}/${_repo} ${_folder} | awk $'match($0, /^Cloning into \'([^\']+)\'\.\.\./, m) { print m[1]; }' )
    cd ${_git_dir}
}
f.complete gh.repo.create

gh.repo.delete() (
    : 'gh.repo.delete ${name} # deletes the github repo named ${name} e.g. mcarifio/try1'
    set -Eeuo pipefail
    local _repo=${1:?'expecting a repo name'}; shift
    gh repo delete --yes ${_repo}
)
f.complete gh.repo.delete

# gh.env() {
#     return 0 
# }
# f.complete gh.env

