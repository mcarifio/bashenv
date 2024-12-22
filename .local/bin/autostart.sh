#!/usr/bin/env bash
# invoked by ~/.config/autostart.desktop

set -uo pipefail

# Does gnome autostart login first?
_bashenv=$(bashenv.root 2>/dev/null || echo ${HOME}/bashenv/.bash_profile.d)

sudo.alacritty() (
    set -Eeuo pipefail; shopt -s nullglob
    local _title=${FUNCNAME}
    local -i _lines=40 _columns=200

    for _a in "${@}"; do
        case "${_a}" in
            --title=*) _title="${_a##*=}";;
            --lines=*) _title="${_a##*=}";;
            --columns=*) _title="${_a##*=}";;
            --) shift; break;;
            --*) break;; ## break on unknown switch, pass it along
            *) break;;
        esac
        shift
    done
    # sudo -E alacritty --title "${_title}" --option window.dimensions.{lines=50,columns=400} --command "$@" &
    sudo $(type -P alacritty) --title "${_title}" --option window.dimensions.{lines=${_lines},columns=${_columns}} --command "$@" &
)

# bashenv/profile.d/binstall.d/showmethekey.dnf.binstall.sh
watch.input() (
    sudo.alacritty --title=${FUNCNAME} showmethekey-cli &
)


watch.dmesg() (
    sudo.alacritty --title=${FUNCNAME} dmesg -HT --color=always --follow &
)

watch.nvtop() (
    alacritty --title "${FUNCNAME}" --command nvtop &
)

watch.input
watch.dmesg
watch.nvtop

d.run() (
    for _host in "$@"; do
	ping -c 1 ${_host} &> /dev/null && desktop.run terminator-${_host} || >&2 echo "${_host} doesn't answer a ping."
    done    
)


# thunderbird email client
# thunderbird &

# gnome-terminal
desktop.run Terminal

# slack
# slack &


# local terminator
# desktop.run terminator-spider
# remote terminators
# d.run ${HOSTNAME} milhous clubber
# d.run ${HOSTNAME} slipjack algernon

# can't have too many browsers
# chrome browser
desktop.run google-chrome
# edge browser, flatpak
desktop.run microsoft-edge
# chromium
desktop.run chromium-browser
# vivaldi
desktop.run vivaldi
# opera
# opera &

# desktop client for protonmail
# electron-mail &

# desktop facebook messenger
# desktop.run caprine

# dropbox
# desktop.run dropbox

# morgan
# desktop.run morgen --hidden

# rdp client
# desktop.run Remmina

# xournalpp /home/mcarifio/work/mcarifio/notes/journal/think.xopp &
