# dnf install -y gh
running.bash && u.have $(basename ${BASH_SOURCE} .sh) || return 0

# notes: gh config set git_protocol ssh
source <(gh completion --shell $(u.shell))

# TODO mike@carif.io: needs testing
gh.repo.create() (
    : 'gh.create-repo ${name} [--private] # creates github repo ${name} for default github user. --private overrides --public'
    set -Eeuo pipefail
    local _repo=${1:?'expecting a repo name'}; shift    
    gh repo create ${_repo} --add-readme --clone --description "tbs ${_repo}" --public "$@"
); declare -fx gh.repo.create
