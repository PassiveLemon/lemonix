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

echo "|| Getting dotfiles ||"
sudo git clone https://github.com/PassiveLemon/lemondots/

cp -r $HOME/lemondots/.nix/ $HOME/
cp -r $HOME/lemondots/.config/ $HOME/
cp -r $HOME/lemondots/.local/ $HOME/
cp -r $HOME/lemondots/.wallpapers/ $HOME/
cp $HOME/lemondots/.gtkrc-2.0 $HOME/
#cp $HOME/lemondots/.xinitrc $HOME/
sudo mv /etc/nixos/configuration.nix /etc/nixos/configuration.nix.old
sudo cp $HOME/.nix/configuration.nix /etc/nixos/configuration.nix

sudo cp $HOME/.wallpapers/Reds/Wallpaper\ \(6).png $HOME/.background-image

echo "|| Running sub-scripts ||"

bash $HOME/.local/fontsscript.sh
bash $HOME/.local/iconsscript.sh
bash $HOME/.local/themesscript.sh

echo "|| Changing permissions ||"
sudo chmod u+x $HOME/.xinitrc
sudo chmod u+x $HOME/.config/bspwm/bspwmrc
sudo chmod u+x $HOME/.config/sxhkd/sxhkdrc

sudo rm -r $HOME/lemontemp/
popd
