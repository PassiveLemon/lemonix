#!/usr/bin/env bash

if [ $EUID = 0 ]; then
  echo "====================================="
  echo "Please do not run this script as Sudo"
  echo "====================================="
  exit
fi

sudo mkdir $HOME/lemontemp/
sudo chmod 777 $HOME/lemontemp/
pushd $HOME/lemontemp/

mkdir -p $HOME/.local/share/fonts/

for font in {Iosevka FiraCode FiraMono} do
  curl -LO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font}.zip
  sudo mkdir -p $HOME/.local/share/fonts/${font}/
  sudo unzip ${font}.zip -d $HOME/.local/share/fonts/${font}/
done

popd
sudo rm -r $HOME/lemontemp/
