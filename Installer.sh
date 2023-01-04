#!/usr/bin/env bash

main="
cp -r /home/lemon/lemondots/.nix/ /home/lemon/
cp -r /home/lemon/lemondots/.config/ /home/lemon/
cp -r /home/lemon/lemondots/.local/ /home/lemon/
cp -r /home/lemon/lemondots/.wallpapers/ /home/lemon/
#cp /home/lemon/lemondots/.gtkrc-2.0 /home/lemon/
#cp /home/lemon/lemondots/.xinitrc /home/lemon/
sudo mv /etc/nixos/configuration.nix /etc/nixos/configuration.nix.old
sudo cp /home/lemon/.nix/configuration.nix /etc/nixos/configuration.nix

sudo cp /home/lemon/.wallpapers/Reds/Wallpaper\ \(6\).png /home/lemon/.background-image

bash /home/lemon/.local/iconsscript.sh

echo "|| Change permissions ||"
sudo chmod 777 /home/lemon/.config
#sudo chmod u+x /home/lemon/.xinitrc
sudo chmod u+x /home/lemon/.config/bspwm/bspwmrc
sudo chmod u+x /home/lemon/.config/sxhkd/sxhkdrc
"

if [ $EUID = 0 ]; then
    echo "====================================="
    echo "Please do not run this script as Sudo"
    echo "====================================="
    exit
fi

PS3="|| If this is being run inside the cloned repo, choose "Preinstalled". Otherwise, choose "Install" to clone and install. ||"
select opt in "Preinstalled" "Install" "Quit"; do
  case $opt in
    "Preinstalled")
      echo ""Preinstalled" selected"
      $main
      ;;
    "Install")
      echo ""Install" selected"
      sudo mkdir -p /home/lemon/lemontemp/
      sudo chmod 777 /home/lemon/lemontemp/
      pushd /home/lemon/lemontemp/

      echo "|| Get dotfiles ||"
      sudo git clone --recurse-submodules https://github.com/PassiveLemon/lemondots/

      $main

      sudo rm -r /home/lemon/lemontemp/
      popd
      ;;
    "Quit")
      break
      ;;
    *)
      echo "Invalid option"
      ;;
  esac
  break
done