#!/bin/sh

cd /home/docker/unstable-diffusion-webui-docker
echo "Killing webui-docker-auto-1"
docker stop webui-docker-auto-1
echo "Building webui-docker-auto-1"
docker compose --profile auto up --build
