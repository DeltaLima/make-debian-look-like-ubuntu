#!/bin/bash

arguments="$@"

# get the $packages Array
. include/packages.inc.sh

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

###

if [ -z "$arguments" ]
then
  package_categories="${!packages[@]}"
else
  package_categories="$@"
fi

message warn "Do you want to install these categories?"
message warn "${YELLOW}$package_categories${ENDCOLOR}"
message warn "Type '${GREEN}yes${ENDCOLOR}' and hit [ENTER] to continue"
read -p "=> " continue
if [ "$continue" != "yes" ] 
then
  message error "Installation aborted."
  exit 1
fi

message "Continue with installation..."
message "check sources.list"
if ! grep "contrib" /etc/apt/sources.list > /dev/null && grep "non-free" /etc/apt/sources.list > /dev/null
then
  message error "please activate 'contrib' and 'non-free' in your sources.ist"
  exit 1
fi
# iterate through $packages
for categorie in $package_categories
do
  message "Packages category: ${YELLOW}${categorie}${ENDCOLOR}"
  message "Packages contained: "
  message "${GREEN}${packages[$categorie]}${ENDCOLOR}"
  
  message "running pre-tasks"
  # pre installation steps for categories
  case $categorie in
    nice)
      sudo dpkg --add-architecture i386 || error
      sudo apt update || error
      ;;
  esac
  
  message "installing packages"
  sudo apt install -y ${packages[$categorie]} || error
  
  message "running post-tasks"
  # post installation steps for categories
  case $categorie in
    base)
      message "sed default grub option"
      sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*$/GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash mem_sleep_default=deep\"/g' /etc/default/grub || error
      sudo update-grub
      ;;
    gnome)
      message "add flathub.org flatpak repository"
      sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || error
      sudo flatpak install org.mozilla.firefox com.github.GradienceTeam.Gradience || error
      
      message "linking ~/.mozilla to flatpak env"
      mkdir -p $HOME/.mozilla
      mkdir -p $HOME/.var/app/org.mozilla.firefox/
      ln -s $HOME/.mozilla HOME/.var/app/org.mozilla.firefox/.mozilla
      
      message "placing font fix for firefox flatpak"
      mkdir -p $HOME/.var/app/org.mozilla.firefox/config/fontconfig/
      echo "<?xml version='1.0'?>
<!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
<fontconfig>
    <!-- Disable bitmap fonts. -->
    <selectfont><rejectfont><pattern>
        <patelt name="scalable"><bool>false</bool></patelt>
    </pattern></rejectfont></selectfont>
</fontconfig>" > $HOME/.var/app/org.mozilla.firefox/config/fontconfig/fonts.conf
      
      message "setting gtk legacy default to dark"
      mkdir -p $HOME/.config/gtk-{3,4}.0
      echo "[Settings]
gtk-application-prefer-dark-theme=1" | tee $HOME/.config/gtk-3.0/settings.ini > $HOME/.config/gtk-4.0/settings.ini

      message "enable gnome shell extensions"
      gnome-extensions enable ubuntu-appindicators@ubuntu.com
      gnome-extensions enable panel-osd@berend.de.schouwer.gmail.com
      gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
      gnome-extensions enable dash-to-dock@micxgx.gmail.com
      gnome-extensions enable system-monitor@paradoxxx.zero.gmail.com 
      
      message "set gsettings"
      # dash-to-dock
      gsettings set org.gnome.shell.extensions.dash-to-dock autohide-in-fullscreen false
      gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 0.64000000000000001
      gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'focus-or-previews'
      gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 36
      gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed true
      gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'LEFT'
      gsettings set org.gnome.shell.extensions.dash-to-dock extend-height true
      gsettings set org.gnome.shell.extensions.dash-to-dock show-apps-at-top true
      gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode 'FIXED'
      
      # panel-osd
      gsettings set org.gnome.shell.extensions.panel-osd x-pos 100.0
      
      # desktop
      gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/backgrounds/gnome/dune-l.svg'
      gsettings set org.gnome.desktop.background picture-uri-dark 'file:///usr/share/backgrounds/gnome/dune-d.svg'
      gsettings set org.gnome.desktop.background show-desktop-icons true
      gsettings set org.gnome.desktop.background primary-color '#E66100'
      gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
      gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:appmenu'
      gsettings set org.gnome.desktop.interface cursor-theme 'Yaru'
      gsettings set org.gnome.desktop.interface enable-hot-corners true
      gsettings set org.gnome.desktop.interface font-antialiasing 'grayscale'
      gsettings set org.gnome.desktop.interface font-hinting 'slight'
      gsettings set org.gnome.desktop.interface font-name 'Ubuntu 11'
      gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-dark'
      gsettings set org.gnome.desktop.interface icon-theme 'Yaru-dark'
      
      # fix big cursor issue in qt apps
      grep "XCURSOR_SIZE" /etc/environment || echo "XCURSOR_SIZE=24" | sudo tee -a /etc/environment
      ;;
  esac
  
done
