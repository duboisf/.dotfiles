#!/bin/bash

# This script tests the bootstrap.sh script in a docker container.
# The docker container is booted up if it doesn't exist and persists
# between invocations.
# Use `docker stop test-dotfiles-bootstrap` to stop and remove the container.

if ! docker inspect test-dotfiles-bootstrap > /dev/null 2>&1; then
    # ubuntu:sudo is the image built from the Dockerfile
    docker run -d --rm \
        --name test-dotfiles-bootstrap \
        --mount type=bind,src=$HOME/.dotfiles,dst=/.dotfiles,ro \
        ubuntu:sudo \
        tail -f /dev/null
fi

docker exec test-dotfiles-bootstrap /.dotfiles/bootstrap.sh
