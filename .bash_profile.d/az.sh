# dnf install azure-cli
# configuration settings https://docs.microsoft.com/en-us/cli/azure/azure-cli-configuration
# generally https://docs.microsoft.com/en-us/cli/azure/use-cli-effectively

type az &> /dev/null || return 0 # az not installed
export AZURE_CONFIG_DIR=${HOME}/.config/azure # ${AZURE_CONFIG_DIR}/config
