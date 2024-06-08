#### This is pretty much just a guide for myself. You can use it yourself if you want I guess.
# Root
```
sudo -i
```

# Wifi (If needed)
```
sudo systemctl start wpa_supplicant
wpa_cli
```

```
> add_network
0 </br>
> set_network 0 ssid "ssid"
OK </br>
> set_network 0 psk "password"
OK </br>
> set_network 0 key_mgmt WPA-PSK
OK </br>
> enable_network 0
OK -> Should see a connection success line
> quit
```

# Partitioning (Will eventually be replaced with Disko)
#### Replace `sda` with your drive name in lsblk. Ex: `nvme0n1`.
```
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart primary 1GiB 100%
parted /dev/sda -- mkpart ESP fat32 1MiB 1GiB
parted /dev/sda -- set 2 esp on
```
- What we do is create a 1 GiB FAT32 ESP partition at the front and the rest will be EXT4.

# Formatting
```
mkfs.ext4 -L lemonixos /dev/sda1
mkfs.fat -F 32 -n boot /dev/sda2
```

# Generating
```
mount /dev/disk/by-label/lemonixos /mnt

mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot

nixos-generate-config --root /mnt
```

## Setting up NixOS configuration
#### Replace `silver` with the appropriate host.
If WiFi is needed:
```
nano /mnt/etc/nixos/configuration.nix
```
> `networking.networkmanager.enable = true`

Find a temporary directory:
```
nix-shell -p git
git clone https://github.com/PassiveLemon/lemonix && cd lemonix

cp /etc/nixos/hardware-configuration.nix ./hosts/silver/
nixos-install --flake .#silver

reboot
```
-  May need to `git add` the hardware config if there wasn't one already there.

# Finishing touches
The home drive should now be mounted in place. Head to `~/Documents/GitHub/`

```
git clone --recurse-submodules https://github.com/PassiveLemon/lemonix && cd lemonix

bash ./other/installer.sh
```
- The `installer.sh` script must be run from the root of the repository.

Hardware config should be in `/etc/nixos-backup/` if needed.

Perform any manual tasks. Ex:
- Git clones to the appropriate locations like AWM libraries. (Until I can figure out a solution to this)
- Lanzaboote `sbctl create-keys` `sbctl enroll-keys`

```
nix run home-manager/release-24.05 -- init --switch
home-manager switch --flake .#lemon@silver
reboot
```
