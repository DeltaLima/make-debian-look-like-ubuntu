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
      message "add flathub.org flatpak repository"
      sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || error
      message "sed default grub option"
      sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*$/GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash mem_sleep_default=deep\"/g' /etc/default/grub || error
      sudo update-grub
      ;;
    gnome)
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
      echo "[Settings]
gtk-application-prefer-dark-theme=1" | tee ~/.config/gtk-3.0/settings.ini > ~/.config/gtk-4.0/settings.ini
      ;;
  esac
  
done
