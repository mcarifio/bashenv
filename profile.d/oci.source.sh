# oci config
export OCI_CLI_SUPPRESS_FILE_PERMISSIONS_WARNING=True
export OCI_CLI_CONFIG_FILE=${HOME}/.config/cloud/oci/config

oci.session() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x oci.session
oci.session

loaded "${BASH_SOURCE}"
