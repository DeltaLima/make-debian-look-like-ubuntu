#!/bin/bash

declare -A packages

# the first three array entries are numbered because they have to be ordered

# install base desktop stuff
packages[0-base]="linux-headers-amd64 plymouth build-essential
p7zip-full unrar unzip  neofetch ecryptfs-utils curl wget python-is-python3" 

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

# install admin and dev tools
packages[admin]="htop iotop sysstat lm-sensors git mc vim btop btrfs-progs 
debootstrap geany geany-plugins lnav mtr-tiny ncdu nmap ppp borgbackup borgmatic
pandoc pwgen remmina rsync screen socat stress strace tcpdump ufw colordiff
ifstat"

# install nice programs
packages[nice]="wine:i386 winetricks chromium dosbox gimp vlc barrier audacity
keepassxc audacious clementine nextcloud-desktop qv4l2 guvcview
shutter solaar steam-installer"

# you can just add your own packages like shown above and below, just add
# a new array field :)

# install games 
#packages[game]="openarena"

# ham radio
#packages[ham]="direwolf gqrx-sdr ax25-tools ax25-apps js8call"

# lol stuff :)
#packages[lol]="lolcat"

# packages for xubuntuish XFCE
#packages[desktop-xfce]="gnome-keyring seahorse python3-keyring mugshot elementary-xfce-icon-theme 
#lightdm-settings lightdm-gtk-greeter-settings gvfs-backends"
