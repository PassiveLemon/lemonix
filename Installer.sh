#!/usr/bin/env bash

if [ ! -d ./LICENSE ] && [ ! -d ./.git ]; then
  echo "|| No clone detected. Cloning...  ||"
  sudo mkdir -p ${HOME}/lemontemp/
  sudo chmod 777 ${HOME}/lemontemp/
  pushd ${HOME}/lemontemp/

  echo "|| Get dotfiles ||"
  sudo git clone https://github.com/PassiveLemon/lemonix/
  cd lemonix
  installpath=${PWD}
else
  path="."
fi

echo "|| Copying dots to home... ||"
if [ ! -d ./.wallpapers/ ]; then
  sudo git clone https://github.com/PassiveLemon/lemonwalls/
fi
mv ${installpath}/lemonwalls/ ${installpath}/.wallpapers

cp -r ${installpath}/.config/ ${HOME}/
cp -r ${installpath}/.local/ ${HOME}/
cp -r ${installpath}/.wallpapers/ ${HOME}/
cp ${installpath}/xorg.conf ${HOME}/
sudo mv /etc/nixos/configuration.nix /etc/nixos/configuration.nix.old
sudo cp ${installpath}/configuration.nix /etc/nixos/configuration.nix

sudo cp ${HOME}/.wallpapers/Reds/Wallpaper\ \(6\).png ${HOME}/.background-image

bash ${installpath}/dotscripts.sh

echo "|| Changing permissions... ||"
sudo chmod -R 777 ${HOME}/.config
sudo chmod -R 777 ${HOME}/.local
sudo chmod -R 777 ${HOME}/.nix
sudo chmod u+x ${HOME}/.config/bspwm/bspwmrc
sudo chmod u+x ${HOME}/.config/sxhkd/sxhkdrc

echo "|| Dots installed. ||"

if [ -d ${HOME}/lemontemp ]; then
  sudo rm -r ${HOME}/lemontemp/
  popd
fi
