#!/usr/bin/env bash
# invoked by ~/.config/autostart.desktop

set -Eeuo pipefail

# Does gnome autostart login first?
_bashenv=$(bashenv.root 2>/dev/null || echo ${HOME}/bashenv/.bash_profile.d)
if u.have alacritty; then
    source ${_bashenv}/alacrity.source.sh
    watch.input
    watch.dmesg
    watch.nvtop
fi

d.run() (
    for _host in "$@"; do
	ping -c 1 ${_host} &> /dev/null && desktop.run terminator-${_host} || >&2 echo "${_host} doesn't answer a ping."
    done    
)


# thunderbird email client
# thunderbird &

# gnome-terminal
desktop.run Terminal Terminator Tabby

# slack
# slack &


# local terminator
# desktop.run terminator-spider
# remote terminators
# d.run ${HOSTNAME} milhous clubber
# d.run ${HOSTNAME} slipjack algernon

# can't have too many browsers
# chrome browser
desktop.run google-chrome chromium-browser microsoft-edge vivaldi brave opera
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
