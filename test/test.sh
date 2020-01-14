#!/bin/bash

# this script will run docker container with an empty system as a test playground for scripts

if [ "$1" = "--osx" ] || [ "$1" = "--macos" ]; then
  : # https://github.com/Cleafy/sxkdvm
else
  docker build -f ~/dotfiles/test/Dockerfile -t dottest ~/dotfiles
  docker run -it dottest
fi
