#### This is pretty much just a guide for myself. You can use it yourself if you want I guess.
#### Replace `silver` or `lemon` with the appropriate host and/or user.
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

# Partitioning
In this example, we create a 1 GiB FAT32 ESP partition at the front (With space to align to blocks), a 24 GiB swap partition at the end, and the rest will be EXT4. This way if we install more RAM and need to increase our swap, we can just shrink the end of the EXT4 partition. For Swap, I like to do the amount of system memory * 1.5, so 16 GiB of memory gives us 24 GiB of swap.

In the case of a laptop that uses hibernate, set the swap partition to be at least the size of installed RAM. Otherwise, systems that do not need hibernation can simply use a swap file from `modules/nixos/swap.nix`.
```
parted /dev/nvme0n1 -- mklabel gpt
parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 1GiB
parted /dev/nvme0n1 -- mkpart primary 1GiB -24GiB
parted /dev/nvme0n1 -- mkpart primary linux-swap -24GiB 100%
parted /dev/nvme0n1 -- set 1 esp on
```
- Replace `nvme0n1` with your drive name if needed. Ex: sda, mmcblk, etc.

# Formatting
```
mkfs.fat -F 32 -n boot /dev/nvme0n1p1
mkfs.ext4 -L nixos /dev/nvme0n1p2
mkswap -L swap /dev/nvme0n1p3
```

# Generating
```
mkdir -p /mnt/boot

# Mount the root BEFORE mounting boot!!!!
mount /dev/disk/by-label/nixos /mnt
mount /dev/disk/by-label/boot /mnt/boot

swapon /dev/disk/by-label/swap

nixos-generate-config --root /mnt
```

## Setting up NixOS configuration
If WiFi is needed:
```
nano /mnt/etc/nixos/configuration.nix
```
> add: `networking.networkmanager.enable = true`

Find a temporary directory:
```
nix-shell -p git
git clone https://github.com/PassiveLemon/lemonix
cd lemonix
```
Disable any modules that use agenix or lanzaboote.
```
cp /mnt/etc/nixos/hardware-configuration.nix ./hosts/silver/
nixos-install --flake .#silver

reboot
```
-  May need to `git add` the hardware config if there wasn't one already there.

Enter the root password.

# Finishing touches
You should be able to log in now. Head to `~/Documents/GitHub/` or wherever you want to store your GitHub repos/projects.
```
git clone https://github.com/PassiveLemon/lemonix
cd lemonix

bash ./other/installer.sh
sbctl create-keys # For lanzaboote
```
This script mounts the current dotfile repository into `/etc/nixos/` and moves the previous configuration to `/etc/nixos-backup/`.
You should also keep agenix modules disabled unless you re-set your SSH keys now.
```
sudo nixos-rebuild switch
```
- The `installer.sh` script must be run from the root of the repository.

Hardware config should be in `/etc/nixos-backup/` if needed. You may want to copy this back into the cloned repo so it can be pushed later.
```
nix run home-manager/release-25.05 -- init --switch
home-manager switch --flake .#lemon@silver
```
The system is now ready to be rebooted. Before we do that, do any tasks that may require the BIOS. Ex:
- [Enable secure-boot setup](https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md#part-2-enabling-secure-boot)

```
reboot
```
Perform any manual tasks. Ex:
- Setting any files like git repositories or config files
- `sbctl enroll-keys --microsoft` (If you followed the pre-reboot tasks)
- Bat theme cache build

The system should be set up and ready for use. The only thing left after this is stuff that isn't managed by Nix. Ex:
- Wallpaper
- Application settings
- Web logins

