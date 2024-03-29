#### This is pretty much just a guide for myself. You can use it yourself if you want I guess. </br>
# Root </br>
`sudo -i` </br>

# Wifi (if needed) </br>
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

# Partitioning </br>
#### Replace sda with your drive name in lsblk. Ex: nvme0n1. </br>

`parted /dev/sda -- mklabel gpt` </br>
`parted /dev/sda -- mkpart primary 1GB -8GB` </br>
`parted /dev/sda -- mkpart ESP fat32 1MB 512MB` </br>
`parted /dev/sda -- set 3 esp on` </br>

# Formatting
`mkfs.ext4 -L lemonnixos /dev/sda1` </br>
`mkfs.fat -F 32 -n boot /dev/sda3` </br>

# Installing </br>
`mount /dev/disk/by-label/lemonnixos /mnt` </br>

`mkdir -p /mnt/boot` </br>
`mount /dev/disk/by-label/boot /mnt/boot` </br>

`nixos-generate-config --root /mnt` </br>

## Settings </br>
`nano /mnt/etc/nixos/configuration.nix` </br>
`networking.networkmanager.enable = true` (If WiF is needed) </br>
`nix-shell -p git` </br>

Find a temporary directory. </br>
`git clone https://github.com/PassiveLemon/lemonix && cd lemonix` </br>

`sudo cp /etc/nixos/hardware-configuration.nix ./hosts/silver/` </br>
`sudo nixos-install --flake .#silver` </br>

User passwords should automatically be set. </br>
`reboot` </br>

# Cloning </br>
The home drive should now be mounted in place. Cd to `~/Documents/GitHub/lemonix/`. </br>
Otherwise, head to `~/Documents/GitHub/` and `git clone --recurse-submodules https://github.com/PassiveLemon/lemonix && cd lemonix`
`bash ./other/Installer.sh`. It must be run from the root of the repository. </br>

Hardware config should be in `/etc/nixos-backup/` if needed. </br>

`nix run home-manager/release-23.05 -- init --switch` </br>
`home-manager switch --flake .#lemon@silver` </br>
