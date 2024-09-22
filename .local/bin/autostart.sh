#!/usr/bin/env bash
# invoked by ~/.config/autostart.desktop

set -Eeuo pipefail
shopt -s nullglob
[[ "$0" = */bashdb ]] && shift

# Does gnome autostart login first?
bashenv=$(bashenv.root 2>/dev/null || echo ${HOME}/bashenv/.bash_profile.d)
# source ${bashenv}/desktop.sh
# source ${bashenv}/ssh.sh

sudo.alacritty() (
    local _title=$1; shift || true
    sudo -E alacritty --title "${_title}" --option window.dimensions.{lines=50,columns=300} --command "$@" &
)

watch.input() (
    sudo.alacritty ${FUNCNAME} ${HOME}/opt/showmethekey/current/bin/showmethekey-cli &
)


watch.dmesg() (
    sudo.alacritty ${FUNCNAME} dmesg -HT --color=always --follow &
)

watch.input
watch.dmesg


d.run() (
    for _host in "$@"; do
	ping -c 1 ${_host} &> /dev/null && desktop.run terminator-${_host} || >&2 echo "${_host} doesn't answer a ping."
    done    
)




# start apps

# emacs client
# ec

# wayland clipboard
# desktop.run copyq.desktop
# https://copyq.readthedocs.io/en/latest/known-issues.html
# QT_QPA_PLATFORM=xcb /usr/bin/copyq --start-server hide


# thunderbird email client
desktop.run mozilla-thunderbird

# gnome-terminal
desktop.run Terminal

# slack
# desktop.run Slack

# desktop.run Tabby

# zoom video conf
# desktop.run Zoom


# local terminator
# desktop.run terminator-spider
# remote terminators
d.run ${HOSTNAME} milhous clubber

# can't have too many browsers
# chrome browser
desktop.run google-chrome
# edge browser, flatpak
desktop.run Edge
# opera
# opera &
# chromium
# desktop.run chromium-browser
# vivaldi
# desktop.run vivaldi

# @install/bash: { sudo flatpak install https://github.com/atlas-engineer/nyxt/releases/download/3.3.0/nyxt-3.3.0.flatpak; }
# @doc: { https://nyxt.atlas.engineer/documentation }
# flatpak run engineer.atlas.Nyxt &

# viber desktop client for rak
# desktop.run viber


# desktop client for protonmail
# electron-mail &

# desktop facebook messenger
# desktop.run caprine

# dropbox
desktop.run dropbox

# morgan
desktop.run morgen --hidden

# rdp client
# desktop.run Remmina

xournalpp /home/mcarifio/work/mcarifio/notes/journal/think.xopp &

