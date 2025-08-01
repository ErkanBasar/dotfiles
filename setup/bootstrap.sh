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

BASEDIR="$(pwd)"

printlog "Setting up symlinks"

# Git
sudo ln -sfn $BASEDIR/git/gitconfig $HOME/.gitconfig

# Shell
sudo ln -sfn $BASEDIR/shell/bashrc $HOME/.bashrc
sudo ln -sfn $BASEDIR/shell/bash_profile $HOME/.bash_profile
sudo ln -sfn $BASEDIR/shell/bash_aliases $HOME/.bash_aliases
sudo ln -sfn $BASEDIR/shell/bash_logout $HOME/.bash_logout

# Custom Scripts
sudo ln -sfn $BASEDIR/scripts/tunnel.sh /usr/bin/tunnel
sudo ln -sfn $BASEDIR/scripts/srunl.sh /usr/bin/srunl
sudo ln -sfn $BASEDIR/scripts/gu.sh /usr/bin/gu

# Icons
sudo rm -r $HOME/.icons
sudo ln -sfn $BASEDIR/icons/ $HOME/.icons

# Redshift
sudo ln -sfn $BASEDIR/redshift/redshift.conf $HOME/.config/redshift.conf

# Autostart
sudo rm -rf $HOME/.config/autostart/
sudo ln -sfn $BASEDIR/autostart/ $HOME/.config/autostart

# TLP: power management tool
if command -v tlp >/dev/null 2>&1; then
  sudo tlp start || printerror "Unable to start TLP"
fi
