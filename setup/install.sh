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

BASEDIR="$(pwd)"
SYSTEMPKGS="$(cat setup/apt-packages.txt)"
LAPTOPPKGS="$(cat setup/apt-packages-laptop.txt)"
DEBPKGS="setup/deb-packages.txt"

if compgen -G "/sys/class/power_supply/BAT*" > /dev/null; then
  SYSTEMPKGS="$SYSTEMPKGS $LAPTOPPKGS"
fi

for package in $SYSTEMPKGS; do
  printlog "Installing $package"
  if ! which "$package" > /dev/null; then
    if [[ $package = "spotify-client" ]]; then
      # Do not install spotify from the Software manager
      # The public key changes in time, consider checking the website
      # source: https://www.spotify.com/download/linux/
      curl -sS https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
      echo "deb https://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
      sudo apt update
    elif [[  $package = "eduvpn-client" ]]; then
      wget -O- https://app.eduvpn.org/linux/v4/deb/app+linux@eduvpn.org.asc | gpg --dearmor | sudo tee /usr/share/keyrings/eduvpn-v4.gpg >/dev/null
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/eduvpn-v4.gpg] https://app.eduvpn.org/linux/v4/deb/ noble main" | sudo tee /etc/apt/sources.list.d/eduvpn-v4.list
      sudo apt update
    elif [[  $package = "signal-desktop" ]]; then
      wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg;
      cat signal-desktop-keyring.gpg | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
      echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' |\
        sudo tee /etc/apt/sources.list.d/signal-xenial.list
      sudo apt update
    fi
    sudo apt install -y "$package" || printerror "Unable to install $package"
  else
    echo "Already installed"
  fi
done

if [ -f "$DEBPKGS" ]; then
  DEBPATHS=$HOME/Downloads/deb_packages
  if [ ! -d "$DEBPATHS" ]; then
    mkdir "$DEBPATHS"
  fi
  printlog "Downloading .deb packages into $DEBPATHS/"
  while IFS=' ' read -r url name
  do
      wget "$url" -O "$DEBPATHS"/"$name" || printerror "Unable to download $name"
  done < "$DEBPKGS"
  printlog "Installing downloaded .deb packages under $DEBPATHS/"
  sudo dpkg -i "$DEBPATHS"/*.deb || printerror "Unable to install dowloaded .deb packages"
  printlog "Installing the missing dependencies (if there is any)"
  sudo apt install -f
  echo
  while true; do
    read -r -p "Do you want to remove the downloaded .deb packages? [Y/n]: " yn
    case $yn in
      [Nn]* ) break;;
      * ) rm -rf "$DEBPATHS"; break;;
    esac
  done
fi

printlog "Updating & Upgrading & Autoremoving"
sudo apt update
sudo apt upgrade
sudo apt autoremove
sudo apt clean

printlog "Bootstrapping"
bash setup/bootstrap.sh

printlog "Creating Python virtual environment '.env' into $HOME"
PYTHON=$(which python3)
echo "Using version $($PYTHON --version 2>&1)"
PKGS_PATH=$BASEDIR/setup/python-packages.txt
echo "Installing Python packages given in $PKGS_PATH"
$PYTHON -m venv "$HOME"/.env || printerror "Failed to create venv"
if [ -f "$HOME/.env/bin/activate" ]; then
  source "$HOME"/.env/bin/activate
  pip install --upgrade pip
  pip install -r "$PKGS_PATH"
  deactivate
else
  printerror "Venv does not exist"
fi

printlog "Installing PyCharm: After installation, the program will launch automatically. Select 'Create a Desktop Entry'."
PYCHARM_URL=$(curl -s 'https://data.services.jetbrains.com/products/releases?code=PCP&latest=true&type=release' | grep -oP '"linux":\s*{\s*"link":\s*"\K[^"]+')
PYCHARM_FOLDER=$(basename "$PYCHARM_URL" .tar.gz)
wget -c -O /tmp/pycharm.tar.gz "$PYCHARM_URL"
sudo tar -xvzf /tmp/pycharm.tar.gz -C /opt
/opt/"$PYCHARM_FOLDER"/bin/pycharm
