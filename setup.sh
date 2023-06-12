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
      sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || error
      ;;
    gnome)
      sudo flatpak install firefox gradience || error
      ;;
  esac
  
done
