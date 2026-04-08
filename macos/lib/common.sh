#!/usr/bin/env bash

log() {
  printf "\n\033[1;34m==> %s\033[0m\n" "$1"
}

warn() {
  printf "\033[1;33m[warn]\033[0m %s\n" "$1"
}
