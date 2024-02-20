sa.shutdown.others() (
    for m in clubber milhous; do ssh ${m} sudo /usr/sbin/shutdown -h now; done
    [[ -d /run/media/mcarifio/home ]] && >&2 echo "pack the home nvme drive"
    sudo /usr/sbin/shutdown -h now
); declare -fx sa.shutdown.others




