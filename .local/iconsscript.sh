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

mkdir -p $HOME/.local/share/icons/

sudo git clone https://github.com/varlesh/volantes-cursors.git
cd volantes-cursors
sudo make build
sudo make install
cd ..