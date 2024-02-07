#!/bin/sh

cd /home/docker/unstable-diffusion-webui-docker
echo "Killing webui-docker-comfy-1"
docker stop webui-docker-comfy-1
echo "Building webui-docker-comfy-1"
docker compose --profile comfy up --build
