#!/bin/bash

declare -A packages

# the first three array entries are numbered because they have to be ordered

# install base desktop stuff
packages[0-base]="plymouth ecryptfs-utils curl wget python-is-python3" 

# install desktop base
packages[1-desktop-base]="ttf-mscorefonts-installer fonts-ubuntu fonts-ubuntu-console fonts-liberation2
fonts-noto-core fonts-dejavu fonts-hack
flatpak flatpak-xdg-utils gnome-software-plugin-flatpak network-manager-openvpn-gnome brasero
dconf-editor thunderbird"

# install gnome base
packages[2-desktop-gnome]="gnome-shell-extension-manager gnome-tweaks gnome-shell-extensions 
gnome-shell-extension-desktop-icons-ng gnome-shell-extension-dashtodock
gnome-shell-extension-appindicator gnome-shell-extension-system-monitor 
gnome-shell-extension-panel-osd 
yaru-theme-gnome-shell yaru-theme-gtk yaru-theme-icon yaru-theme-sound
yaru-theme-unity"