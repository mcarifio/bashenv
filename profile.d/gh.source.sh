# dnf install -y gh
# TODO mike@carif.io: needs testing

# usage: [guard | source] gh.guard.sh [--install] [--verbose] [--trace]
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
    gh repo create ${_repo} --add-readme --description "tbs ${_repo}" --public
    # local _git_dir=$(2>&1 >/dev/null git clone gh:${USER}/${_repo} ${_folder} | awk $'match($0, /^Cloning into \'([^\']+)\'\.\.\./, m) { print m[1]; }' )
    git clone gh:${USER}/${_repo} ${_folder}
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

gh.session() {
    source <(gh completion -s $(u.shell 2>/dev/null || echo bash)) || u.error
}
f.complete gh.session
gh.session

loaded "${BASH_SOURCE}"
