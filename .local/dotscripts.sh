#!/usr/bin/env bash

if [ $EUID = 0 ]; then
  echo "====================================="
  echo "Please do not run this script as Sudo"
  echo "====================================="
  exit
fi

# Fonts
for directory in "$HOME/.local/share/fonts/" "$HOME/.fonts/"; do
  mkdir -p ${directory}
  pushd ${directory}

  for font in FiraCode FiraMono; do
    curl -LO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font}.zip
    sudo unzip -o ./${font}.zip
    sudo rm -r ./${font}.zip
  done

  popd
done

# Icons
for directory in "$HOME/.local/share/icons/" "$HOME/.icons/"; do
  mkdir -p ${directory}
  pushd ${directory}

  # Kora
  if [ -e ./kora/ ]; then
    sudo rm -r ./kora/
  fi
  git clone https://github.com/bikass/kora.git
  sudo mv ./kora/ ./koradl/
  sudo cp -r ./koradl/kora/ ./
  sudo rm -r ./koradl/

  popd
done

# Themes
for directory in "$HOME/.local/share/themes/" "$HOME/.themes/"; do
  mkdir -p ${directory}
  pushd ${directory}

  # Mono
  if [ -e ./MonoThemeDark/ ]; then
    sudo rm -r ./MonoThemeDark/
  fi
  curl -LO https://github.com/witalihirsch/Mono-gtk-theme/releases/latest/download/MonoThemeDark.zip
  unzip -o ./MonoThemeDark.zip
  sudo rm -r ./MonoThemeDark.zip

  popd
done

# Manual
for directory in "fonts/ icons/ themes/"; do
  sudo cp -r ./${directory} $HOME
done 