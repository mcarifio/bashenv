${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

shutdown.all() (
    set -Eeuo pipefail; shopt -s nullglob
    for m in {skipjack,charlie}.mg8702; do ssh ${m} sudo /usr/sbin/shutdown -h now; done
    [[ -d /run/media/mcarifio/home ]] && >&2 echo "pack the home nvme drive"
    sudo /usr/sbin/shutdown -h now
)
f.x shutdown.all

sourced || true




