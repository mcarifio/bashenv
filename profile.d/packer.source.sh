${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

packer.session() {
    complete -C packer packer
}
f.x packer.session
packer.session

sourced || true


