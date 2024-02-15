running.bash && u.have udevadm || return 0

config.memory() ( udevadm info -e | grep -e MEMORY_DEVICE ; ); declare -fx config.memory



