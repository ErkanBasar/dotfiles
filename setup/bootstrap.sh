#!/bin/bash

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

