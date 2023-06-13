#!/bin/bash

declare -A packages

# install base desktop stuff
packages[base]="linux-headers-amd64 plymouth build-essential
p7zip-full unrar unzip  neofetch ecryptfs-utils" 

# install desktop base
packages[desktop-base]="ttf-mscorefonts-installer fonts-ubuntu fonts-ubuntu-console fonts-liberation2
fonts-noto-core fonts-noto-extra fonts-noto-ui-core fonts-noto-ui-extra fonts-dejavu fonts-hack
flatpak flatpak-xdg-utils shotwell network-manager-openvpn-gnome gnome-software-plugin-flatpak brasero
dconf-editor thunderbird thunderbird-l10n-de"

# install gnome base
packages[desktop-gnome]="task-gnome-desktop task-german-desktop 
gnome-shell-extension-manager gnome-tweaks gnome-shell-extensions 
gnome-shell-extension-desktop-icons-ng gnome-shell-extension-dashtodock
gnome-shell-extension-appindicator gnome-shell-extension-system-monitor 
gnome-shell-extension-panel-osd 
yaru-theme-gnome-shell yaru-theme-gtk yaru-theme-icon yaru-theme-sound
yaru-theme-unity"

packages[desktop-xfce]="gnome-keyring seahorse python3-keyring mugshot elementary-xfce-icon-theme 
lightdm-settings lightdm-gtk-greeter-settings"

# install admin and dev tools
packages[admin]="htop iotop sysstat lm-sensors git mc vim btop btrfs-progs 
curl wget debootstrap geany geany-plugins lnav mtr-tiny ncdu nmap ppp 
pandoc pwgen remmina rsync screen socat stress strace tcpdump ufw borgbackup borgmatic colordiff
ansible"

# install nice programs
packages[nice]="wine:i386 winetricks chromium dosbox gimp vlc barrier audacity
keepassxc audacious clementine nextcloud-desktop arduino qv4l2 guvcview
solaar steam-installer"

# install games 
#packages[game]="openarena"

# ham radio
#packages[ham]="direwolf  gqrx-sdr ax25-tools ax25-apps js8call"

# lol stuff :)
#packages[lol]="lolcat"
