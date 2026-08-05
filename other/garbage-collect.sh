#!/usr/bin/env bash

nix store gc
nix store optimise

docker image prune --all -y
docker system prune --all -y
docker buildx prune --all -y
docker builder prune --all -y

