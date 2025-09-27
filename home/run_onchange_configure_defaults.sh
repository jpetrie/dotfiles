#!/bin/bash
set -eufo pipefail

# Enable key repeat behavior (disables the accented character picker popup).
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

