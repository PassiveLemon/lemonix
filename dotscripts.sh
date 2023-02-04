#!/usr/bin/env bash

if [ $EUID = 0 ]; then
  echo "====================================="
  echo "Please do not run this script as Sudo"
  echo "====================================="
  exit
fi

# Fonts
homelocalfonts="$HOME/.local/share/fonts"
homedotfonts="$HOME/.fonts"
mkdir -p ${homelocalfonts}
mkdir -p ${homedotfonts}
pushd ${homelocalfonts}
# Nerd Fonts
  for font in FiraCode FiraMono; do
    curl -LO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font}.zip
    sudo unzip -o ./${font}.zip
    sudo rm -r ./${font}.zip
  done
sudo cp -r ${homelocalfonts}/* ${homedotfonts}/
popd

# Icons
homelocalicons="$HOME/.local/share/icons"
homedoticons="$HOME/.icons"
mkdir -p ${homelocalicons}
mkdir -p ${homedoticons}
pushd ${homelocalicons}
# Kora
  if [ -e ./kora/ ]; then
    sudo rm -r ./kora/
  fi
  git clone https://github.com/bikass/kora.git
  sudo mv ./kora/ ./koradl/
  sudo cp -r ./koradl/kora/ ./
  sudo rm -r ./koradl/
sudo cp -r ${homelocalicons}/* ${homedoticons}/
popd

# Themes
homelocalthemes="$HOME/.local/share/themes"
homedotthemes="$HOME/.themes"
mkdir -p ${homelocalthemes}
mkdir -p ${homedotthemes}
pushd ${homelocalthemes}

sudo cp -r ${homelocalthemes}/* ${homedotthemes}/
popd

# Manual
sudo cp -rf ./.local/ $HOME/