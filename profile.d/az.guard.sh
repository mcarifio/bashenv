# dnf install azure-cli
# configuration settings https://docs.microsoft.com/en-us/cli/azure/azure-cli-configuration
# generally https://docs.microsoft.com/en-us/cli/azure/use-cli-effectively

export AZURE_CONFIG_DIR=${HOME}/.config/azure # ${AZURE_CONFIG_DIR}/config

az.session() {
    true || u.error
}
declare -fx az.session
az.session
