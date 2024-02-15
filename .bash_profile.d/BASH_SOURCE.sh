running.bash || return 0
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
