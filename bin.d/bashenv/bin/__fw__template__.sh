#!/usr/bin/env bash
# -*- mode: shell-script; -*- # eval: (setq-local indent-tabs-mode nil tab-width 4 indent-line-function 'insert-tab) -*-
#!/usr/bin/env -S sudo -i /usr/bin/env bash # run as root under sudo

# Simulate installation. Gross.
shopt -s extglob
[[ -z "${BASHENV}" && -f ~/.bash_login ]] && source ~/.bash_login || true
if [[ -z "${BASHENV}" ]] ; then
    local _xdg_data_home=${XDG_DATA_HOME:-~/.local/share}
    [[ -d ${_xdg_data_home} ]] || { >&2 echo "${xdg_data_home} not found."; return 1; }
    export BASHENV=${_xdg_data_home}
    source ${BASHENV}/load.mod.sh
    path.add $(path.bins)
fi


# __fw__ framework
source __fw__.sh || { >&2 echo "$0 cannot find __fw__.sh"; exit 1; }
trap '_catch --lineno default-catcher $?' ERR

# Specific option parsing
function _fw_start {
    local _self=${FUNCNAME[0]}

    declare -Ag _flags+=([--template-flag]=default)
    local -a _rest=()
    
    while (( $# )); do
        local _it=${1}
        case "${_it}" in
            # --template-flag=*) _flags[--template-flag]=${_it#--template-flag=};;
            --template-flag=*) _flags[--template-flag]=${_it#--template-flag=};;
            --) shift; _rest+=($*); break;;
            -*|--*) _catch --exit=1 --print --lineno "${_it} unknown flag" ;;
            *) _rest+=(${_it});;
        esac
        shift
    done

    # echo the command line with default flags added.
    if (( ${_flags[--verbose]} )) ; then
        printf "${_self} "
        local _k; for _k in ${!_flags[*]}; do printf '%s=%s ' ${_k} ${_flags[${_k}]}; done;
        printf '%s ' ${_rest[*]}
        echo
    fi

    # All options parsed (or defaulted). Do the work.
    ${_flags[--forward]} ${_rest[*]}
}


# Specific work.
function _start-echo {
    declare -Ag _flags
    local _k; for _k in  ${!_flags[*]}; do printf '%s:%s ' ${_k} ${_flags[${_k}]}; done
    echo $*
}

function _start-rename.me.sh {
    local _self=${FUNCNAME[0]}
    declare -Ag _flags
    local _k; for _k in  ${!_flags[*]}; do printf '%s:%s ' ${_k} ${_flags[${_k}]}; done; echo $*
    >&2 echo -e "\n\n\n\tRENAME and REWRITE ${_self}\n\n\n"
}

# skip specific option parsing
# _start_at --start=_start $@

# add specific option parsing
# _start_at --start=_fw_start --forward=_start-${_basename}
_start_at --start=_fw_start --forward=_start-rename.me.sh

