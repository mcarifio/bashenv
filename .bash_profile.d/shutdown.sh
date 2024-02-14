# source for bash only
realpath /proc/$$/exe | grep -Eq 'bash$' || return 0
# source only if rsync is available
# type -p shutdown &> /dev/null || return 0

shutdown() (
    for m in clubber milhous; do ssh ${m} sudo /usr/sbin/shutdown -h now; done
    [[ -d /run/media/mcarifio/home ]] && >&2 echo "pack the home nvme drive"
    sudo /usr/sbin/shutdown -h now
); declare -fx shutdown




