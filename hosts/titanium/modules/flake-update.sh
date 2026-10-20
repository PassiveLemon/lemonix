#!/usr/bin/env bash

NIXOS="$1"
HM="$2"

cp flake.lock flake-temp.lock

nix flake update

for HOST in $NIXOS; do
  echo "Building $HOST"
  nixos-rebuild build --flake ".#$HOST"
done

for HOST in $HM; do
echo "Building $HOST"
  home-manager build --flake ".#$HOST"
done

mv -f flake-temp.lock flake.lock

