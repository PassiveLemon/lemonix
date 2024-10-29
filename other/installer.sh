#!/usr/bin/env bash
# Todo: Instead of confirming, change to the root and then continue.
read -rp "Confirm that this script is being run from the root of the repository (y/n)?" CHOICE
case "$CHOICE" in
  Y|y) ;;
  N|n)
    echo "Canceled"
    return
  ;;
  *)
    echo "Invalid choice"
    return
  ;;
esac

echo "|| Setting up config... ||"
# Backs up system config before running. Subsequential runs won't remove original backup.
if [ ! -f "/etc/nixos-backup/" ]; then
  sudo mv /etc/nixos/ /etc/nixos-backup/
fi

# Link this Git to /etc/nixos
sudo ln -s "$PWD" /etc/nixos

echo "|| Dots installed. Maybe. ||"

