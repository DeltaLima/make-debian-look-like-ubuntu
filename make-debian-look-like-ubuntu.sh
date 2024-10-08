#!/bin/bash

# Title: make-debian-look-like-ubuntu.sh
# Description: This script performs all necessary steps to make a Debian Gnome
# desktop look like an Ubuntu desktop. Also it installs flatpak with 
# flathub.org repository enabled and Firefox from there.
# Author: DeltaLima
# Date: 21.06.2023
# Version: 1.0
# Usage: bash make-debian-look-like-ubuntu.sh
# 
# Copyright 2023 DeltaLima (Marcus Hanisch)
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy 
# of this software and associated documentation files (the “Software”), to deal
# in the Software without restriction, including without limitation the rights 
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
# copies of the Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in 
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# 
#

arguments="$@"

# define the $packages[] array
declare -A packages

# the first three array entries are numbered because they have to be ordered

# install base desktop stuff
packages[0-base]="plymouth ecryptfs-utils curl wget python-is-python3 binutils" 

# install desktop base
packages[1-desktop-base]="ttf-mscorefonts-installer fonts-ubuntu fonts-ubuntu-console fonts-liberation2
fonts-noto-core fonts-noto-color-emoji fonts-dejavu fonts-hack
flatpak flatpak-xdg-utils gnome-software-plugin-flatpak network-manager-openvpn-gnome
dconf-editor thunderbird"

# install gnome base
packages[2-desktop-gnome]="gnome-shell-extension-manager gnome-tweaks gnome-shell-extensions 
gnome-shell-extension-desktop-icons-ng gnome-shell-extension-dashtodock
gnome-shell-extension-appindicator gnome-shell-extension-system-monitor 
gnome-shell-extension-panel-osd 
yaru-theme-gnome-shell yaru-theme-gtk yaru-theme-icon yaru-theme-sound
yaru-theme-unity
gnome-package-updater gnome-packagekit"

# if you want to add for automation purposes your own packages, just add another array field, like
#packages[4-my-packages]="shutter solaar steam-installer chromium dosbox gimp vlc audacity keepassxc audacious nextcloud-desktop"


# colors for colored output 8)
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
ENDCOLOR="\e[0m"

function message() {
     case $1 in
     warn)
       MESSAGE_TYPE="${YELLOW}WARN${ENDCOLOR}"
     ;;
     error)
       MESSAGE_TYPE="${RED}ERROR${ENDCOLOR}"
     ;;
     info|*)
       MESSAGE_TYPE="${GREEN}INFO${ENDCOLOR}"
     ;;
     esac

     if [ "$1" == "info" ] || [ "$1" == "warn" ] || [ "$1" == "error" ]
     then
       MESSAGE=$2
     else
       MESSAGE=$1
     fi

     echo -e "[${MESSAGE_TYPE}] $MESSAGE"
}

error () 
{
  message error "ERROR!!"
  exit 1
}

confirm_continue()
{
  message warn "Type '${GREEN}y${ENDCOLOR}' or '${GREEN}yes${ENDCOLOR}' and hit [ENTER] to continue"
  read -p "[y/N?] " continue
  if [ "${continue,,}" != "y" ] && [ "${continue,,}" != "yes" ]
  then
    message error "Installation aborted."
    exit 1
  fi
}

###

if [ "$(whoami)" == "root" ]
then message error "I cannot run as root"
error
fi

if [ -z "$arguments" ]
then
  package_categories="${!packages[@]}"
else
  package_categories="$@"
fi

# sort the category list, some of them have to be in order
package_categories="$(echo $package_categories | xargs -n1 | sort | xargs)"
message "Welcome to ${GREEN}make-debian-look-like-ubuntu${ENDCOLOR}!"
message ""
message "This script makes a fresh Debian-Gnome installation to look like"
message "an Ubuntu Gnome installation. Settings are applied for the user"
message "running this script (${YELLOW}${USER}${ENDCOLOR})".
message ""
message "Your user has to be in the 'sudo' group."
message "If not, the script will guide you."
message ""
message "The process is divided into following steps:"
message "${YELLOW}$package_categories${ENDCOLOR}"
message ""
message "If you want, you can run only a few of them, e.g. just '${YELLOW}2-desktop-gnome${ENDCOLOR}':"
message " ${YELLOW}bash $0 2-desktop-gnome${ENDCOLOR}"
message ""
message warn "Some files, like gtk settings, get overwritten without asking."
message warn "If this is not a fresh installation, make a backup first!"
message ""
confirm_continue

message "Continue with installation..."

if ! groups | grep sudo > /dev/null
then
  message error "Your user $USER is not in group 'sudo'."
  message error "Add your user to the group with:"
  message error " ${YELLOW}su -c \"/usr/sbin/usermod -aG sudo ${USER}\"${ENDCOLOR}"
  message error "after that, you need to reboot."
  error
fi
message "check sources.list"
if ! ( ( grep "contrib" /etc/apt/sources.list > /dev/null ) && ( grep -E " non-free( |$)" /etc/apt/sources.list > /dev/null ) )
then
  message warn "I need 'contrib' and 'non-free' in sources.ist, I will deploy my own"
  confirm_continue
  message "backup old sources.list to /etc/apt/sources.list.bak"
  sudo cp /etc/apt/sources.list /etc/apt/sources.list.$(date "+%s")bak
  cat << EOF | sudo tee /etc/apt/sources.list
deb http://deb.debian.org/debian/ bookworm main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian/ bookworm main contrib non-free non-free-firmware

deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
deb-src http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware

# bookworm-updates, to get updates before a point release is made;
# see https://www.debian.org/doc/manuals/debian-reference/ch02.en.html#_updates_and_backports
deb http://deb.debian.org/debian/ bookworm-updates main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian/ bookworm-updates main contrib non-free non-free-firmware
EOF

  message "apt update"
  sudo apt update
fi


# iterate through $packages
for category in $package_categories
do
  message "Packages category: ${YELLOW}${category}${ENDCOLOR}"
  message "Packages contained: "
  message "${GREEN}${packages[$category]}${ENDCOLOR}"
  
  message "running pre-tasks"
  # pre installation steps for categories
  case $category in
    nice)
      sudo dpkg --add-architecture i386 || error
      sudo apt update || error
      ;;
  esac
  
  # package installation #
  message "installing packages"
  sudo apt install -y ${packages[$category]} || error
  
  message "running post-tasks"
  # post installation steps for categories
  case $category in
    0-base)
      message "sed default grub option"
      sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*$/GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash\"/g' /etc/default/grub || error
      sudo update-grub
      ;;

    1-desktop-base)
      message "add flathub.org flatpak repository"
      sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || error
      
      # here was also com.github.GradienceTeam.Gradience included installed, but not needed
      # anymore - i found the relevant ~/.config/gtk-{3,4}.0/gtk.css file ;) 
      message "install firefox flatpak"
      sudo flatpak install org.mozilla.firefox || error
      message "set firefox flatpak to default"
      xdg-settings set default-web-browser org.mozilla.firefox.desktop 
      
      message "apply font fix for firefox flatpak"
      mkdir -p $HOME/.var/app/org.mozilla.firefox/config/fontconfig/
      cat << EOF > $HOME/.var/app/org.mozilla.firefox/config/fontconfig/fonts.conf
<?xml version='1.0'?>
<!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
<fontconfig>
    <!-- Disable bitmap fonts. -->
    <selectfont><rejectfont><pattern>
        <patelt name="scalable"><bool>false</bool></patelt>
    </pattern></rejectfont></selectfont>
</fontconfig>
EOF
      
      # fix big cursor issue in qt apps
      message "Set XCURSOR_SIZE=24 in /etc/environment to fix Big cursor bug in QT"
      grep "XCURSOR_SIZE" /etc/environment || echo "XCURSOR_SIZE=24" | sudo tee -a /etc/environment > /dev/null
      ;;

    2-desktop-gnome)
    
      message "allow user-extensions"
      gsettings set org.gnome.shell disable-user-extensions false
      
      message "enable gnome shell extensions"
      gnome-extensions enable ubuntu-appindicators@ubuntu.com
      gnome-extensions enable panel-osd@berend.de.schouwer.gmail.com
      gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
      gnome-extensions enable dash-to-dock@micxgx.gmail.com
      gnome-extensions enable ding@rastersoft.com
      
      message "apply settings for dash-to-dock"
      # dash-to-dock
      gsettings set org.gnome.shell.extensions.dash-to-dock autohide-in-fullscreen false
      gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 0.64000000000000001
      gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'focus-or-previews'
      gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-shrink true
      gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 42
      gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed true
      gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'LEFT'
      gsettings set org.gnome.shell.extensions.dash-to-dock extend-height true
      gsettings set org.gnome.shell.extensions.dash-to-dock show-apps-at-top true
      gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode 'FIXED'
      gsettings set org.gnome.shell.extensions.dash-to-dock running-indicator-style 'DOTS'
      gsettings set org.gnome.shell.extensions.dash-to-dock icon-size-fixed true
      
      
      message "apply settings for gnome desktop"
      # desktop
      gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/backgrounds/gnome/dune-l.svg'
      gsettings set org.gnome.desktop.background picture-uri-dark 'file:///usr/share/backgrounds/gnome/dune-d.svg'
      gsettings set org.gnome.desktop.background show-desktop-icons true
      gsettings set org.gnome.desktop.background primary-color '#E66100'
      gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
      gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:appmenu'
      gsettings set org.gnome.desktop.interface enable-hot-corners true
      gsettings set org.gnome.desktop.interface font-antialiasing 'grayscale'
      gsettings set org.gnome.desktop.interface font-hinting 'slight'
      gsettings set org.gnome.desktop.interface font-name 'Ubuntu 11'
      gsettings set org.gnome.desktop.interface monospace-font-name 'Ubuntu Mono 13'
      gsettings set org.gnome.desktop.interface document-font-name 'Sans 11'
      gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Ubuntu Bold 11'
      gsettings set org.gnome.desktop.interface cursor-theme 'Yaru'
      gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-dark'
      gsettings set org.gnome.desktop.interface icon-theme 'Yaru-dark'
      gsettings set org.gnome.shell.extensions.user-theme name 'Yaru-dark'

      # gtk-3.0 and gtk-4.0 settings
      message "setting gtk-3.0 and gtk-4.0 default to dark"
      mkdir -p $HOME/.config/gtk-{3,4}.0
      cat << EOF | tee $HOME/.config/gtk-3.0/settings.ini > $HOME/.config/gtk-4.0/settings.ini
[Settings]
gtk-application-prefer-dark-theme=1
EOF

      # apply adwaita gtk-3.0 and gtk-4.0 orange accent color
      message "setting gtk-3.0 and gtk-4.0 accent color to orange"
      cat << EOF | tee $HOME/.config/gtk-3.0/gtk.css > $HOME/.config/gtk-4.0/gtk.css
@define-color accent_color #ffbe6f;
@define-color accent_bg_color #e66100;
@define-color accent_fg_color #ffffff;
EOF

      # replace firefox-esr with flatpak in dock
      message "replace firefox-esr with flatpak in dock"
      gsettings get org.gnome.shell favorite-apps | grep "org.mozilla.firefox.desktop" > /dev/null ||
      gsettings set org.gnome.shell favorite-apps "$(gsettings get  org.gnome.shell favorite-apps  | sed 's/firefox-esr\.desktop/org\.mozilla\.firefox\.desktop/')"

      # replace evolution with thunderbird in dock
      message "replace evolution with thunderbird in dock"
      gsettings get org.gnome.shell favorite-apps | grep "thunderbird.desktop" > /dev/null ||
      gsettings set org.gnome.shell favorite-apps "$(gsettings get  org.gnome.shell favorite-apps  | sed 's/org\.gnome\.Evolution\.desktop/thunderbird\.desktop/')"

      # replace yelp with settings in dock
      message "replace yelp with settings in dock"
      gsettings get org.gnome.shell favorite-apps | grep "org.gnome.Settings.desktop" > /dev/null ||
      gsettings set org.gnome.shell favorite-apps "$(gsettings get  org.gnome.shell favorite-apps  | sed 's/yelp\.desktop/org\.gnome\.Settings\.desktop/')"
      ;;
  esac
  
done

message "${GREEN}DONE!!${ENDCOLOR}"
message warn "${RED}IMPORTANT!! ${YELLOW}Rerun this script again after a reboot, if this is the first run of it!${ENDCOLOR}"
