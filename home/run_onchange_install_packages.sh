#!/bin/bash
set -eufo pipefail

brew bundle --file=/dev/stdin <<EOF
  brew "chezmoi"
  brew "cmake"
  brew "cmake-language-server"
  brew "doxygen"
  brew "eza"
  brew "fd"
  brew "fish"
  brew "fzy"
  brew "git"
  brew "lua-language-server"
  brew "neovim"
  brew "ripgrep"
  brew "starship"
  brew "tree-sitter"
  brew "tree-sitter-cli"
  cask "1password"
  cask "1password-cli"
  cask "alfred"
  cask "bettermouse"
  cask "carbon-copy-cloner"
  cask "discord"
  cask "ghostty"
  cask "obsidian"
  cask "rectangle-pro"
EOF

