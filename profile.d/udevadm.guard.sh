config.memory() (
    udevadm info -e | grep -e MEMORY_DEVICE
)
f.complete config.memory

loaded "${BASH_SOURCE}"



