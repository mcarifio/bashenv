# dnf install azure-cli
# configuration settings https://docs.microsoft.com/en-us/cli/azure/azure-cli-configuration
# generally https://docs.microsoft.com/en-us/cli/azure/use-cli-effectively
# usage: [guard | source] _template.guard.sh [--install] [--verbose] [--trace]
_guard=$(path.basename ${BASH_SOURCE})
export AZURE_CONFIG_DIR=${HOME}/.config/azure # ${AZURE_CONFIG_DIR}/config

az.session() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x az.session
az.session

loaded "${BASH_SOURCE}"
