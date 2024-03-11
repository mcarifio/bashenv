#!/usr/bin/env bash
if type -p dnf &> /dev/null; then
    sudo dnf upgrade -y
    sudo dnf install -y tree direnv just gmake
elif type -p apt &> /dev/null; then
    sudo apt upgrade -y
    sudo apt install tree direnv just gmake
elif type -p snap &> /dev/null; then
    :
elif type -p flatpak &> /dev/null; then
    :
fi

