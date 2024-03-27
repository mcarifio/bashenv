ip4.addr.show() ( ip -4 addr show ${1:?'expecting a device name like eth0'} | grep -oP '(?<=inet\s)\d+(\.\d+){3}'; )
f.x ip4.addr.show

loaded "${BASH_SOURCE}"
