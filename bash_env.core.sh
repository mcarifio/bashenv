pid.parents() (
    local -i _pid=${1:-$$}
    local -i _stop=${2:-1}
    while (( _pid != _stop )); do
        local _pid=$(ps -o ppid= -p ${_pid})
        ps -o pid= -o ppid= -o comm= -p ${_pid}
    done    
)
f.x pid.parents
