#!/bin/sh

git config --global user.email "${GITHUB_EMAIL}"
git config --global user.name "${GITHUB_USER}"
git config --global --add safe.directory /npr-work

exec nixpkgs-review "${NPR_FLAGS}"

