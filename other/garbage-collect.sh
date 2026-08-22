#!/usr/bin/env bash

nix store gc
nix store optimise

docker image prune -af
docker system prune -af
docker buildx prune -af
docker builder prune -af

