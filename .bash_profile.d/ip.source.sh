running.bash && u.have $(basename ${BASH_SOURCE} .sh) || return 0

ip4.addr.show() ( ip -4 addr show ${1:?'expecting a device name like eth0'} | grep -oP '(?<=inet\s)\d+(\.\d+){3}'; ); declare -fx ip4.addr.show