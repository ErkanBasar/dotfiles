#!/bin/bash

printerror () {
    echo "======================== ERROR ========================" >&2
    echo "$1" >&2
    echo "=======================================================" >&2
}

printlog () {
    echo
    echo "---------------------------------------------------------------------------" >&2
    echo "$1"
    echo "---------------------------------------------------------------------------" >&2
}

printlog "Updating Aptitude package manager..."
sudo apt update
printlog "Running the full-upgrade"
sudo apt full-upgrade || printerror "Unable to do the full-upgrade"

BASEDIR="$(pwd)"
SYSTEMPKGS="$(cat setup/apt-packages.txt)"
DEBPKGS="setup/deb-packages.txt"

for package in $SYSTEMPKGS; do

  printlog "Installing $package"

  if ! which $package > /dev/null; then

    sudo apt install -y $package || printerror "Unable to install $package"

  else
    echo "Already installed"

  fi

done

if [ -f "$DEBPKGS" ]; then

  DEBPATHS=$HOME/Downloads/deb_packages
  if [ ! -d $DEBPATHS ]; then
    mkdir $DEBPATHS
  fi

  printlog "Downloading .deb packages into $DEBPATHS/"
  while IFS=' ' read -r url name
  do
      wget $url -O $DEBPATHS/$name || printerror "Unable to download $name"
  done < "$DEBPKGS"

  printlog "Installing downloaded .deb packages under $DEBPATHS/"
  sudo dpkg -i $DEBPATHS/*.deb || printerror "Unable to install dowloaded .deb packages"

  printlog "Installing the missing dependencies (if there is any)"
  sudo apt install -f

  printlog "Removing the downloaded .deb packages"
  sudo rm -rf $DEBPATHS

fi

printlog "Updating & Upgrading & Autoremoving"
sudo apt update
sudo apt upgrade
sudo apt autoremove
sudo apt clean

printlog "Bootstrapping"
bash setup/bootstrap.sh

