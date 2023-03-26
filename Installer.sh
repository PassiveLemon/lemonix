#!/usr/bin/env bash

# If the current directory isn't a clone, make a temporary directory, clone, and install. This will clean up later so you won't carry these files.
if [ ! -d "./.git" ]; then
  echo "|| No clone detected. Cloning...  ||"
  sudo mkdir -p ${HOME}/lemontemp/
  sudo chmod 777 ${HOME}/lemontemp/
  # Mark current directory to return later.
  pushdir=${PWD}
  cd ${HOME}/lemontemp/

  echo "|| Get dotfiles ||"
  sudo git clone --depth 1 https://github.com/PassiveLemon/lemonix/
  cd lemonix
  installpath=${PWD}
else
  installpath="."
fi

echo "|| Copying dots to home... ||"
if [ ! -d "${installpath}/.wallpapers/" ]; then
  sudo git clone --depth 1 https://github.com/PassiveLemon/lemonwalls/
fi
mkdir -p ${HOME}/.wallpapers/
sudo cp -r ${installpath}/lemonwalls/* ${HOME}/.wallpapers/
sudo rm -r ${installpath}/lemonwalls/
sudo cp ${HOME}/.wallpapers/AI/00005-1568076343.png ${HOME}/.background-image
sudo cp -r ${installpath}/.local/ ${HOME}/

# Backs up system config before running. Subsequential runs won't remove original backup.
if [ ! -f "/etc/nixos/configuration.nix.old" ]; then
  sudo mv /etc/nixos/configuration.nix /etc/nixos/configuration.nix.old
fi
sudo rm /etc/nixos/configuration.nix
sudo cp ${installpath}/configuration.nix /etc/nixos/configuration.nix

. ${installpath}/dotscripts.sh

echo "|| Awesome Modules ||"
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

echo "|| Changing permissions... ||"
sudo chmod -R 777 ${HOME}/.config
sudo chmod -R 777 ${HOME}/.local

echo "|| Dots installed. ||"

if [ -d ${HOME}/lemontemp ]; then
  cd ${pushdir}
  sudo rm -r ${HOME}/lemontemp/
fi
