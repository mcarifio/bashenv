sudo.alacritty() (
    local _title=${1:?'expecting a title'}; shift
    sudo -E alacritty --title "${_title}" --option window.dimensions.{lines=50,columns=300} --command "$@"
)
f.x sudo.alacritty

# https://showmethekey.alynx.one/
# https://copr.fedorainfracloud.org/coprs/pesader/showmethekey/

# to install on bluefin (silverblue):
# RELEASE=$(os-release.major) curl -o /etc/yum.repos.d/showmethekey.repo https://copr.fedorainfracloud.org/coprs/pesader/showmethekey/repo/fedora-$RELEASE/pesader-showmethekey-fedora-$RELEASE.repo
# rpm-ostree install showmethekey
# rpm-ostree live-update

# note that showmethekey-gtk works, but I find the user interface
# distracting. I prefer to stream input events in a dedicated terminal
# "off to the side". In a multiheaded configuration that's in a different
# display.

watch.input() (
    sudo.alacritty ${FUNCNAME} showmethekey-cli &
)
f.x watch.input

watch.dmesg() (
    sudo.alacritty ${FUNCNAME} dmesg -HT --color=always --follow &
)
f.x watch.dmesg

alacritty.loaded() ( return 0; )
f.x alacritty.loaded


