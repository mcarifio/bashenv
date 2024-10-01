path.add ${HOME}/.modular/pkg/packages.modular.com_mojo/bin
${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

export MODULAR_AUTH=mut_512623ed4a1c48dbbfc02915ec0bd168

modular.auth() (
    modular auth ${1:-${MODULAR_AUTH:?'expecting an auth token'}}
)
f.x modular.auth

sourced || true

