#!/usr/bin/env bash

echo "|| Setting up config... ||"
# Backs up system config before running. Subsequential runs won't remove original backup.
if [ ! -f "/etc/nixos-backup/" ]; then
  sudo mv /etc/nixos/ /etc/nixos-backup/
fi
sudo mkdir -p /etc/nixos/

# Link this Git to /etc/nixos
sudo ln -s ${PWD}/ /etc/nixos

#echo "|| Awesome modules ||"
#mkdir -p ${HOME}/.config/awesome/libraries/
#cd ${HOME}/.config/awesome/libraries/
#if [ ! -d "./awesome-wm-widgets/" ]; then
#  git clone --depth 1 https://github.com/streetturtle/awesome-wm-widgets.git
#fi

echo "|| Dots installed. Maybe. ||"

