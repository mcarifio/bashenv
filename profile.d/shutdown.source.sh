# shutdown in a machine specific way
shutdown() (
    for d in ~/.config/keepassxc ~/Documents/e; do
	rsync.local $d
    done
    dnf upgrade -y
    sudo shutdown -h now    
)
f.complete shutdown

loaded "${BASH_SOURCE}"
