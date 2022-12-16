#!/usr/bin/env bash

if [ $EUID = 0 ]; then
    echo "====================================="
    echo "Please do not run this script as Sudo"
    echo "====================================="
    exit
fi

sudo mkdir -p /home/lemon/lemontemp/
sudo chmod 777 /home/lemon/lemontemp/
pushd /home/lemon/lemontemp/

echo "|| Get dotfiles ||"
sudo git clone https://github.com/PassiveLemon/lemondots/

cp -r /home/lemon/lemondots/.nix/ /home/lemon/
cp -r /home/lemon/lemondots/.config/ /home/lemon/
cp -r /home/lemon/lemondots/.local/ /home/lemon/
cp -r /home/lemon/lemondots/.wallpapers/ /home/lemon/
cp /home/lemon/lemondots/.gtkrc-2.0 /home/lemon/
#cp /home/lemon/lemondots/.xinitrc /home/lemon/
sudo mv /etc/nixos/configuration.nix /etc/nixos/configuration.nix.old
sudo cp /home/lemon/.nix/configuration.nix /etc/nixos/configuration.nix

sudo cp /home/lemon/.wallpapers/Reds/Wallpaper\ \(6\).png /home/lemon/.background-image

echo "|| Run sub-scripts ||"

bash /home/lemon/.local/fontsscript.sh
bash /home/lemon/.local/iconsscript.sh
bash /home/lemon/.local/themesscript.sh

echo "|| Change permissions ||"
sudo chmod 777 /home/lemon/.config
#sudo chmod u+x /home/lemon/.xinitrc
sudo chmod u+x /home/lemon/.config/bspwm/bspwmrc
sudo chmod u+x /home/lemon/.config/sxhkd/sxhkdrc

sudo rm -r /home/lemon/lemontemp/
popd
