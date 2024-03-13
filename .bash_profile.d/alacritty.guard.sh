sudo.alacritty() (
    local _title=${1:?'expecting a title'}; shift
    sudo -E alacritty --title "${_title}" --option window.dimensions.{lines=50,columns=300} --command "$@"
)
f.complete sudo.alacritty

watch.input() (
    sudo.alacritty ${FUNCNAME} /mopt/showmethekey/current/bin/showmethekey-cli &
)
f.complete watch.input

watch.dmesg() (
    sudo.alacritty ${FUNCNAME} dmesg -HT --color=always --follow &
)
f.complete watch.dmesg

