#!/usr/bin/env bash
set -euo pipefail

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd -P)"

source "$SCRIPT_DIR/docker.sh"
VERSIONS_FILE="${VERSIONS_FILE:-$SCRIPT_DIR/../docker/versions.env}"

# shellcheck source=../docker/versions.env
source "$VERSIONS_FILE"

LLAMA_IMAGE="$HVA_V_LLAMA_CPP_IMAGE"
LLAMA_IMAGE_TAG="${LLAMA_IMAGE%@*}"
LATEST_DIGEST="$(
  "${DOCKER[@]}" buildx imagetools inspect "$LLAMA_IMAGE_TAG" 2>/dev/null \
    | awk '/^Digest:/ { print $2; exit }'
)"

if [[ -z "$LATEST_DIGEST" ]]; then
  echo "could not resolve latest digest for: $LLAMA_IMAGE_TAG" >&2
  exit 1
fi

LATEST_IMAGE="${LLAMA_IMAGE_TAG}@${LATEST_DIGEST}"

if [[ "$LATEST_IMAGE" != "$HVA_V_LLAMA_CPP_IMAGE" ]]; then
  sed -i "s|^HVA_V_LLAMA_CPP_IMAGE=.*$|HVA_V_LLAMA_CPP_IMAGE=$LATEST_IMAGE|" "$VERSIONS_FILE"
  echo "updated docker/versions.env:"
  echo "  HVA_V_LLAMA_CPP_IMAGE=$LATEST_IMAGE"
else
  echo "llama.cpp image pin already up to date:"
  echo "  HVA_V_LLAMA_CPP_IMAGE=$LATEST_IMAGE"
fi

echo "pulling llama server image: $LATEST_IMAGE"
"${DOCKER[@]}" pull "$LATEST_IMAGE"

echo
echo "updated image:"
"${DOCKER[@]}" image inspect "$LATEST_IMAGE" --format '{{.RepoTags}} {{.Id}} {{.Created}}'
echo
echo "restart llama to use new image:"
echo "  HVA_RESTART_LLAMA=1 hva"
