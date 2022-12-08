#!/usr/bin/env bash

if [ $EUID = 0 ]; then
  echo "====================================="
  echo "Please do not run this script as Sudo"
  echo "====================================="
  exit
fi

sudo mkdir $HOME/lemontemp/
pushd $HOME/lemontemp/

sudo apt install -y git make

mkdir -p $HOME/.local/share/icons/

sudo git clone https://github.com/varlesh/volantes-cursors.git
cd volantes-cursors
sudo make build
sudo make install
cd ..

sudo git clone https://github.com/bikass/kora.git
cd kora
cp -r $HOME/kora/ $HOME/.local/share/icons/
cd ..

cp -r $HOME/.local/default/ $HOME/.local/share/icons/

sudo rm -r $HOME/lemontemp/
popd
