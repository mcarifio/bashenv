# deno https://bitbucket.org/ciq-mcarifio/ehcm/ts/ehcm.ts # to be supplied

ehcm.template() (
    : 'ehcm.template [${name]] # generate a starting function definition for ${name}'
    local _prefix="${FUNCNAME%.*}"
    local _fname="${1:-fn}"
    # for syntax checking: source <(ehcm.template do1); ehcm.do1
    cat<<EOF
    ${_prefix}.${_fname}() (
        : '${_fname} # comment'
        set -Eeu -o pipefail
        >&2 echo "${_fname} not yet implemented"
        return 1
    ); declare -fx ${_fname}
EOF
); declare -fx ehcm.template


ehcm.err() (
    : 'ehch.err [${message}] # print message to /dev/stderr and return 1'
    local _message=${1:-"${FUNCNAME} ${FUNCNAME[-1]}"}
    local _from=${2:-"${BASH_SOURCE}:${BASH_LINENO[-1]}"}
    >&2 echo "${_from}: ${_message}"
    return 1
); declare -fx ehcm.err

ehcm.nyi() (
    : 'ehch.nyi # caller not yet implemented'
    ehcm.err "${FUNCNAME[-1]} not yet implemented" "${BASH_SOURCE}:${BASH_LINENO[-1]}"
); declare -fx ehcm.nyi

ehcm.gsheet.url() (
    : 'ehcm.url # return gsheel url for ehcm'
    set -Eeuo pipefail
    echo "https://docs.google.com/spreadsheets/d/1QnPP6toEMsLidhGXSrKMWuKPB19VpSYYZmAttM51fWQ"
); declare -fx ehcm.gsheet.url

ehcm.append() (
    : 'ehcm.append # add a row to gsheet, tbs'
    set -Eeuo pipefail
    ehch.nyi
    echo "do something"
); declare -fx ehcm.append

ehcm.distro() (
     : 'ehcm.distro # '
    set -Eeuo pipefail
    source /etc/os-release
    echo ${ID}-${ID_VERSION}-${arch}
); declare -fx ehcm.distro

ehcm.dumpmachine() (
    : 'ehcm.dumpmachine # '
    set -Eeuo pipefail
    gcc -dumpmachine 
); declare -fx ehcm.dumpmachine

