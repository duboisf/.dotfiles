#!/bin/bash -x

# This script tests the bootstrap.sh script in a docker container.
# The docker container is booted up if it doesn't exist and persists
# between invocations.
# Use `docker stop test-dotfiles-bootstrap` to stop and remove the container.

BRANCH="${1:-main}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTAINER_NAME="test-dotfiles-bootstrap"

docker buildx build -t ubuntu:sudo -f "$SCRIPT_DIR/Dockerfile" --load "$SCRIPT_DIR"

docker rm -f $CONTAINER_NAME > /dev/null 2>&1 || true

docker run -d --rm \
    --name $CONTAINER_NAME \
    --mount type=bind,src="$SCRIPT_DIR",dst=/.dotfiles,ro \
    ubuntu:sudo \
    tail -f /dev/null

docker exec $CONTAINER_NAME \
    bash -c "curl -fsSL https://raw.githubusercontent.com/duboisf/.dotfiles/refs/heads/${BRANCH}/bootstrap.sh | bash -s -- ${BRANCH}"
