sudo.alacritty() (
    local _title=${1:?'expecting a title'}; shift
    sudo -E alacritty --title "${_title}" --option window.dimensions.{lines=50,columns=300} --command "$@"
)
f.x sudo.alacritty

watch.input() (
    sudo.alacritty ${FUNCNAME} /mopt/showmethekey/current/bin/showmethekey-cli &
)
f.x watch.input

watch.dmesg() (
    sudo.alacritty ${FUNCNAME} dmesg -HT --color=always --follow &
)
f.x watch.dmesg

alacritty.loaded() ( return 0; )
f.x alacritty.loaded


