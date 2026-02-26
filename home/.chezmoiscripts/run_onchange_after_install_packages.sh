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
  brew "llvm"
  brew "lua-language-server"
  brew "neovim"
  brew "ripgrep"
  brew "starship"
  brew "tree-sitter"
  brew "tree-sitter-cli"
EOF

