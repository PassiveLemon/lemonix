#!/usr/bin/env bash

if [ ! -d ./LICENSE ] && [ ! -d ./.git ]; then
  echo "|| No clone detected. Cloning...  ||"
  sudo mkdir -p ${HOME}/lemontemp/
  sudo chmod 777 ${HOME}/lemontemp/
  pushdir=${PWD}
  cd ${HOME}/lemontemp/

  echo "|| Get dotfiles ||"
  sudo git clone https://github.com/PassiveLemon/lemonix/
  cd lemonix
  installpath=${PWD}
else
  installpath="."
fi

echo "|| Copying dots to home... ||"
if [ ! -d "${installpath}/.wallpapers/" ]; then
  sudo git clone https://github.com/PassiveLemon/lemonwalls/
fi
mv ${installpath}/lemonwalls/ ${installpath}/.wallpapers

cp -r ${installpath}/.config/ ${HOME}/
cp -r ${installpath}/.local/ ${HOME}/
cp -r ${installpath}/.wallpapers/ ${HOME}/
if [ ! -f "/etc/nixos/configuration.nix.old" ]; then
  sudo mv /etc/nixos/configuration.nix /etc/nixos/configuration.nix.old
fi
sudo rm /etc/nixos/configuration.nix
sudo cp ${installpath}/configuration.nix /etc/nixos/configuration.nix

sudo cp ${HOME}/.wallpapers/AI/00005-1568076343.png ${HOME}/.background-image

bash ${installpath}/dotscripts.sh

echo "|| Changing permissions... ||"
sudo chmod -R 777 ${HOME}/.config
sudo chmod -R 777 ${HOME}/.local
sudo chmod -R 777 ${HOME}/.nix

echo "|| Dots installed. ||"

if [ -d ${HOME}/lemontemp ]; then
  sudo rm -r ${HOME}/lemontemp/
  cd ${pushdir}
fi
