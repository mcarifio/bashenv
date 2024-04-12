#!/usr/bin/env bash

# https://andrewmccarthy.ie/setting-a-blank-desktop-background-in-gnome.html
# gsettings list-keys org.gnome.desktop.background
# gsettings describe org.gnome.desktop.background primary-color

gnome.background() {
    : 'gnome.background [${primary-color:-web-gray} [${secondary-color:-gray}]]'
    local _primary=${1:-snow4}
    local _secondary=${2:-blue}
    gsettings set org.gnome.desktop.background picture-uri none
    # gsettings set org.gnome.desktop.background color-shading-type 'solid'
    gsettings set org.gnome.desktop.background color-shading-type vertical

    # https://en.wikipedia.org/wiki/X11_color_names
    # https://www.w3schools.com/colors/colors_x11.asp
    gsettings set org.gnome.desktop.background primary-color "${_primary}"
    gsettings set org.gnome.desktop.background secondary-color "${_secondary}"
}

gnome.background ${2:-snow4} ${1:-black} 
