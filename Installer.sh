#!/usr/bin/env bash

echo "|| Setting up config ||"
# Backs up system config before running. Subsequential runs won't remove original backup.
if [ ! -f "/etc/nixos-backup/" ]; then
  sudo mv /etc/nixos/ /etc/nixos-backup/
fi
sudo mkdir -p /etc/nixos/

# Link this Git to /etc/nixos
sudo ln -s ${PWD}/ /etc/nixos

# Dumb workaround
sudo cp -r ${PWD}/modules/config/*/ ${HOME}/.config/

. ./dotscripts.sh

echo "|| Awesome modules ||"
mkdir -p ${HOME}/.config/awesome/
cd ${HOME}/.config/awesome/
if [ ! -d "./lain/" ]; then
  git clone --depth 1 https://github.com/lcpz/lain.git
fi
if [ ! -d "./awesome-wm-widgets/" ]; then
  git clone --depth 1 https://github.com/streetturtle/awesome-wm-widgets.git
fi
for module in lain awesome-wm-widgets; do
  cd ${module}/
  git pull
  cd ..
done

echo "|| Dots installed. ||"
