#!/usr/bin/env bash

if [ ! -d ./LICENSE ] && [ ! -d ./.git ]; then
  echo "|| No clone detected. Cloning...  ||"
  sudo mkdir -p ${HOME}/lemontemp/
  sudo chmod 777 ${HOME}/lemontemp/
  pushd ${HOME}/lemontemp/

  echo "|| Get dotfiles ||"
  sudo git clone https://github.com/PassiveLemon/lemonix/
  cd lemonix
  path=$(echo ${PWD})
else
  path="."
fi

echo "|| Copying dots to home... ||"
sudo git clone https://github.com/PassiveLemon/lemonwalls/
mv ${path}/lemonwalls/ ${path}/.wallpapers

cp -r ${path}/.config/ ${HOME}/
cp -r ${path}/.local/ ${HOME}/
cp -r ${path}/.wallpapers/ ${HOME}/
cp ${path}/xorg.conf ${HOME}/
sudo mv /etc/nixos/configuration.nix /etc/nixos/configuration.nix.old
sudo cp ${path}/configuration.nix /etc/nixos/configuration.nix

sudo cp ${HOME}/.wallpapers/Reds/Wallpaper\ \(6\).png ${HOME}/.background-image

bash ${path}/dotscripts.sh

echo "|| Changing permissions... ||"
sudo chmod -R 777 ${HOME}/.config
sudo chmod -R 777 ${HOME}/.local
sudo chmod -R 777 ${HOME}/.nix
sudo chmod u+x ${HOME}/.config/bspwm/bspwmrc
sudo chmod u+x ${HOME}/.config/sxhkd/sxhkdrc

echo "|| Other ||"
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "|| Dots installed. ||"

if [ -d ${HOME}/lemontemp ]; then
  sudo rm -r ${HOME}/lemontemp/
  popd
fi
