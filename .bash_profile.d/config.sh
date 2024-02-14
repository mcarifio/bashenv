running.bash
has.all udevadm

config.memory() ( udevadm info -e | grep -e MEMORY_DEVICE ; ); declare -fx config.memory



