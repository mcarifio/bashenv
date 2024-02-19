# dnf install -y gh
source.guard $(basename ${BASH_SOURCE%%.*}) || return 0

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

gh.env() {
    return 0 
}; declare -fx gh.env

eval "declare -ix _load_count_${_for}"
eval "${_for}.load_count() ( echo \$_load_count_${_for}; ); declare -fx ${_for}.load_count"
u.have ${_for}.env && (( _load_count_${_for} == 0 )) && ${_for}.env "$@"
(( ++_load_count_${_for} ))
