#!/usr/bin/env bash

if [ $EUID = 0 ]; then
  echo "====================================="
  echo "Please do not run this script as Sudo"
  echo "====================================="
  exit
fi

sudo mkdir $HOME/lemontemp/
pushd $HOME/lemontemp/

sudo apt install curl

mkdir -p $HOME/.local/share/themes/

curl -LO https://github.com/EliverLara/Nordic/releases/latest/download/Nordic-Polar-standard-buttons.tar.xz
sudo tar -xf Nordic-Polar-standard-buttons.tar.xz
cp -r ./Nordic-Polar-standard-buttons/ $HOME/.local/share/themes/

sudo rm -r $HOME/lemontemp/
popd
