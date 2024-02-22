#!/usr/bin/env bash

echo "|| Setting up config... ||"
# Backs up system config before running. Subsequential runs won't remove original backup.
if [ ! -f "/etc/nixos-backup/" ]; then
  sudo mv /etc/nixos/ /etc/nixos-backup/
fi
sudo mkdir -p /etc/nixos/

# Link this Git to /etc/nixos
sudo ln -s ${PWD}/ /etc/nixos

echo "|| Dots installed. Maybe. ||"

