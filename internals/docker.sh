#!/usr/bin/env bash
# Docker availability detection. Sets DOCKER=(docker) or DOCKER=(sudo docker).
# Source this in scripts that need docker.

if docker info >/dev/null 2>&1; then
  DOCKER=(docker)
elif command -v sudo >/dev/null 2>&1 && sudo -n docker info >/dev/null 2>&1; then
  DOCKER=(sudo docker)
else
  echo "docker is not available to this user" >&2
  exit 1
fi
