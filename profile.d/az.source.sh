# dnf install azure-cli
# configuration settings https://docs.microsoft.com/en-us/cli/azure/azure-cli-configuration
# generally https://docs.microsoft.com/en-us/cli/azure/use-cli-effectively
${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0
export AZURE_CONFIG_DIR=${HOME}/.config/azure # ${AZURE_CONFIG_DIR}/config

az.session() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x az.session
az.session

sourced

