#!/usr/bin/env bash

if [ ! -d ../LICENSE ] && [ ! -d ../.git ]; then
  echo "|| No clone detected. Cloning...  ||"
  sudo mkdir -p /home/lemon/lemontemp/
  sudo chmod 777 /home/lemon/lemontemp/
  pushd /home/lemon/lemontemp/

  echo "|| Get dotfiles ||"
  sudo git clone --recurse-submodules https://github.com/PassiveLemon/lemondots/
  cd lemondots
  path=${pwd}
else
  path=".."
fi

cp -r ${path}/.nix/ /home/lemon/
cp -r ${path}/.config/ /home/lemon/
cp -r ${path}/.local/ /home/lemon/
cp -r ${path}/.wallpapers/ /home/lemon/
# cp ${path}/.gtkrc-2.0 /home/lemon/
# cp ${path}/.xinitrc /home/lemon/
sudo mv /etc/nixos/configuration.nix /etc/nixos/configuration.nix.old
sudo cp /home/lemon/.nix/configuration.nix /etc/nixos/configuration.nix

sudo cp /home/lemon/.wallpapers/Reds/Wallpaper\ \(6\).png /home/lemon/.background-image

bash /home/lemon/.local/iconsscript.sh

echo "|| Change permissions ||"
sudo chmod -R 777 /home/lemon/.config
sudo chmod -R 777 /home/lemon/.local
sudo chmod -R 777 /home/lemon/.nix
# sudo chmod u+x /home/lemon/.xinitrc
sudo chmod u+x /home/lemon/.config/bspwm/bspwmrc
sudo chmod u+x /home/lemon/.config/sxhkd/sxhkdrc

if [ -d /home/lemon/lemontemp ]; then
  popd
  sudo rm -r /home/lemon/lemontemp/
fi