bash.ec() (
    : 'bash.ec ${function-name} => ec +${lineno} ${pathname} # suitable for emacs'
    shopt -s extdebug
    #                ${name} ${lineno} ${pathname}
    local _where=( $(declare -F ${1:?'expecting a function'}) )
    ec +${_where[1]} ${_where[2]} ## emacs format
); declare -fx bash.ec

bash.source() (
    : 'bash.ec ${function-name} => ec +${lineno} ${pathname} # suitable for emacs'
    shopt -s extdebug
    #                ${name} ${lineno} ${pathname}
    local _where=( $(declare -F ${1:?'expecting a function'}) )
    echo ${_where[2]}
); declare -fx bash.source


bash.reload() {
    : 'bash.reload ${function} ## reload the source file that defined ${function}'
    source $(bash.source ${1:?'expecting a function'})
}; declare -fx bash.reload

bash.shopt() {
    shopt -s cdable_vars autocd
}; declare -fx bash.shopt

export _bash_shopt=${BASHOPTS}
bash.shopt

# needs work

BASH_SOURCE.dirname() (
  : 'BASH_SOURCE.dirname [${stack}] # return the dirname of the script at call stack, default -1'  
  set -Eeu -o pipefail
  local -i _top=$(( ${#FUNCNAME[@]} ))
  local -i i=${1:-$(( _top - 1 ))}
  # echo $i ${_top} ${BASH_SOURCE[@]}
  (( i < 1 )) && echo ${PWD} || echo $(dirname $(realpath ${BASH_SOURCE[$i]}))
)

BASH_SOURCE.basename() (
  : 'BASH_SOURCE.basename [${stack}] # return the basename of the script at call stack, default -1'  
  set -Eeu -o pipefail
  local -i _top=$(( ${#FUNCNAME[@]} ))
  local -i i=${1:-$(( _top - 1 ))}
  (( i < 1 )) && echo $(basename ${PWD}) || echo $(basename $(realpath ${BASH_SOURCE[$i]}))
)

BASH_SOURCE.lib() (
  set -Eeu -o pipefail
  local -i _top=$(( ${#FUNCNAME[@]} ))
  local -i i=${1:-$(( _top - 1 ))}
  local _folder="$(BASH_SOURCE.dirname)"
  echo "${_folder}"/$(basename "${_folder}").lib
)
