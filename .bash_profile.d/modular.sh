realpath /proc/$$/exe | grep -Eq 'bash$' || return 0
type -p modular &> /dev/null || return 0

export MODULAR_AUTH=mut_512623ed4a1c48dbbfc02915ec0bd168
modular.auth() ( modular auth ${1:-${MODULAR_AUTH:?'expecting an auth token'}}; ); declare -fx modular.auth
export PATH=~/.modular/pkg/packages.modular.com_mojo/bin:$PATH
