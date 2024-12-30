#!/usr/bin/env bash

set -Eeuo pipefail

# This machine's timezone 
tz() ( timedatectl |grep 'Time zone'| awk '{print $3;}'; )

# Name of this script, e.g. homeassistant
name() (
    local _config="${BASH_SOURCE##*/}"
    echo "${_config%%.*}"
)

# Generate the config pathname for this script based on naming conventions
config() (
    echo "${XDG_CONFIG_HOME:-${HOME}/.config}/$(name).${FUNCNAME}"
)

# status 0 iff docker $(name) is running
docker.running() (
    docker inspect --format='{{.State.Running}}' ${1:-$(name)} 2>/dev/null | grep --silent true
)

main() (
    local _config="$(config)"
    [[ -r "${_config}" ]] || >&2 echo "$(realpath ${BASH_SOURCE}):${FUNCNAME} config ${_config} missing, continuing"        
    local _port=${1:-8129}
    local _url=${HOSTNAME:-localhost}:${_port}

    if docker.running $(name); then
        docker ps --filter "name=$(name)"
    else
        docker run -d --name $(name) \
               --privileged \
               --restart=unless-stopped \
               -e TZ=$(tz) \
               -v ${_config}:/config \
               -v /run/dbus:/run/dbus:ro \
               --network=host \
               --publish ${_port}:${_port} \
               ghcr.io/home-assistant/home-assistant:stable
    fi
    curl -I ${_url} || { >&2 echo "${_url} not listening?"; return 1; }
)

main "$@"

