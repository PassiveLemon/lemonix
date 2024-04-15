#!/bin/sh

cd /home/docker/unstable-diffusion-webui-docker
echo "|| Killing webui-docker-auto-1... ||"
docker stop webui-docker-auto-1
echo "|| Webui-docker-auto-1 stopped. Building Webui-docker-auto-1... ||"
docker compose --profile auto up --build
echo "|| Stopped Webui-docker-auto-1. ||"
