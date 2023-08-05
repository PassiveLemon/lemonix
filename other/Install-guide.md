#### This is pretty much just a guide for myself. You can use it yourself if you want I guess. </br>
## Root </br>
`sudo -i` </br>

## Wifi (if needed) </br>
`sudo systemctl start wpa_supplicant` </br>

`wpa_cli` </br>

> `add_network` </br>
0 </br>
> `set_network 0 ssid "ssid"` </br>
OK </br>
> `set_network 0 psk "password"` </br>
OK </br>
> `set_network 0 key_mgmt WPA-PSK` </br>
OK </br>
> `enable_network 0` </br>
OK -> Should see a connection success line </br>
> `quit` </br>

## Partitioning </br>
#### Replace /sda with your drive name in lsblk. Ex: Laptop drive's name is mmcblk0 </br>

`parted /dev/sda -- mklabel gpt` </br>
`parted /dev/sda -- mkpart primary 1GB -4GB` </br>
`parted /dev/sda -- mkpart primary linux-swap -4GB 100%` (If you want swap) </br>
`parted /dev/sda -- mkpart ESP fat32 1MB 512MB` </br>
`parted /dev/sda -- set 3 esp on` </br>

## Formatting
`mkfs.ext4 -L lemonnixos /dev/sda1` </br>
`mkswap -L swap /dev/sda2` (If you want swap) </br>
`mkfs.fat -F 32 -n boot /dev/sda3` </br>

## Installing </br>
`mount /dev/disk/by-label/lemonnixos /mnt` </br>

`mkdir -p /mnt/boot` </br>
`mount /dev/disk/by-label/boot /mnt/boot` </br>

`swapon /dev/sda2` (If you want swap) </br>
`nixos-generate-config --root /mnt` </br>
`nano /mnt/etc/nixos/configuration.nix` </br>

## Settings </br>
`boot.loader.systemd-boot.enable = true` </br>
`networking.networkmanager.enable = true` (if wifi is needed) </br>

## Install </br>
`nixos-install` </br>

## Set root </br>
> password </br>

`reboot` </br>

login: root </br>
> password </br>

## Cloning </br>
`git clone https://github.com/PassiveLemon/lemonix` </br>
`bash ./lemonix/Installer.sh` </br>

Make sure to set user password: </br>
`sudo passwd lemon` </br>
> password </br>
