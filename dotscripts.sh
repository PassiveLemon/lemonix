#!/bin/sh

if [ "$(id -u)" = 0 ]; then
  echo "====================================="
  echo "Please do not run this script as root"
  echo "====================================="
  exit
fi

pushdir=${PWD}

# Fonts
homelocalfonts="${HOME}/.local/share/fonts"
homedotfonts="${HOME}/.fonts"
mkdir -p ${homelocalfonts}
mkdir -p ${homedotfonts}
cd ${homelocalfonts}
# Nerd Fonts
  for font in FiraCode FiraMono; do
    curl -LO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font}.zip
    sudo unzip -o ./${font}.zip
    sudo rm -r ./${font}.zip
  done
sudo cp -r ${homelocalfonts}/* ${homedotfonts}/
cd ${pushdir}

# Icons
homelocalicons="${HOME}/.local/share/icons"
homedoticons="${HOME}/.icons"
mkdir -p ${homelocalicons}
mkdir -p ${homedoticons}
cd ${homelocalfonts}
# Kora
  if [ -e ./kora/ ]; then
    sudo rm -r ./kora/
  fi
  git clone --depth 1 https://github.com/bikass/kora.git
  sudo mv ./kora/ ./koradl/
  sudo cp -r ./koradl/kora/ ./
  sudo rm -r ./koradl/
sudo cp -r ${homelocalicons}/* ${homedoticons}/
cd ${pushdir}

# Themes
homelocalthemes="${HOME}/.local/share/themes"
homedotthemes="${HOME}/.themes"
mkdir -p ${homelocalthemes}
mkdir -p ${homedotthemes}
cd ${homelocalfonts}
#sudo cp -r ${homelocalthemes}/* ${homedotthemes}/
cd ${pushdir}

# Manual
sudo cp -rf ./.local/ $HOME/