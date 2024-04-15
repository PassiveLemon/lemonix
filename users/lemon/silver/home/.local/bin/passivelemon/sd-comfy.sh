#!/bin/sh

cd /home/docker/unstable-diffusion-webui-docker
echo "|| Killing webui-docker-comfy-1... ||"
docker stop webui-docker-comfy-1
echo "|| Webui-docker-comfy-1 stopped. Building Webui-docker-comfy-1... ||"
docker compose --profile comfy up --build
echo "|| Stopped Webui-docker-comfy-1. ||"
