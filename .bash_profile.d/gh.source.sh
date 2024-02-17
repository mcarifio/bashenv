# dnf install -y gh
running.bash && u.have $(basename ${BASH_SOURCE} .sh) || return 0

# notes: gh config set git_protocol ssh
source <(gh completion --shell $(u.shell))

# TODO mike@carif.io: needs testing
gh.repo.create() {
    : 'gh.create.repo ${name} [${folder}] [--private] # creates github repo ${name} for default github user. --private overrides --public'
    local _repo=${1:?'expecting a repo name'}; shift
    local _folder=${1:-${_repo}}; shift
    (
	set -Eeuo pipefail
	gh repo create ${_repo} --add-readme --clone --description "tbs ${_repo}" --public "$@"
	mv -v ${_repo} ${_folder}
    ) && cd ${_folder}
}; declare -fx gh.repo.create

gh.repo.delete() (
    : 'gh.repo.delete ${name} # deletes the github repo named ${name} e.g. mcarifio/try1'
    set -Eeuo pipefail
    local _repo=${1:?'expecting a repo name'}; shift
    gh repo delete --yes ${_repo}
); declare -fx gh.repo.delete
