#!/bin/zsh

function brew_install() {
  if ! brew list $1 &>/dev/null
  then
    brew install $1
  fi
}

function defaults_write() {
  local read_command=(defaults read "$1" "$2")
  local write_command=(defaults write "$1" "$2" "-$3" "$4")
  local current=$($read_command)
  if [[ "$current" != "$4" ]]
  then
    $write_command
    printf "Set $1 $2 to $4\n"

    if [[ $1 == "com.apple.dock" ]]
    then
      restart_dock=true
    fi
  fi
}

# Install Homebrew.
# zsh has a built-in `which` where -s provides symlink information instead of silencing output, so instead we send its
# output to null.
if ! which brew >/dev/null
then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add brew to the path immediately, so it can be used to install other packages below.
  eval "$(/opt/homebrew/bin/brew shellenv)"

  # Homebrew will install the Xcode command line tools and switch to their developer folder, which is missing key tools
  # (like the Metal compilers). If the full Xcode app is installed, switch back to its developer folder.
  if [[ -a /Applications/Xcode.app ]]
  then
    xcode-select --switch /Applications/Xcode.app/Contents/Developer
  fi
fi

# Install packages.
brew_install cmake
brew_install fd
brew_install llvm
brew_install lua-language-server
brew_install markdown
brew_install nvim
brew_install ripgrep
brew_install tree-sitter

# Set up dotfiles.
# Create symlinks in ~ to all the files underneath the "dot" directory. Invisible files are excluded.
for file in $(find -s "dot" -type f -not -name ".*")
do
  local actual="${file:a}"
  local link="$HOME/.${file:4}"

  # Create any needed intermediate directories for the link file.
  local root="${link:h}"
  if [[ ! -d "$root" ]]
  then
    mkdir -p "$root"
  fi

  if [[ -f $link ]]
  then
    if [[ "$(readlink $link)" == "$actual" ]]
    then
      # No need to do anything since the link already points to the correct actual file.
      continue
    fi

    # Back up the existing file and remove it.
    mv "$link" "$link.dotbackup"
    rm -f "$link"
  fi

  ln -s "${actual}" "$link"
  printf "Linked $link to $actual\n"
done

# Set up macOS options. Some changes won't be visible until process restart or logging out.
# Dock and window management settings.
defaults_write "com.apple.dock" "orientation" "string" "left"
defaults_write "com.apple.dock" "mineffect" "string" "scale"
defaults_write "com.apple.dock" "minimize-to-application" "int" "1"

# Disable press-and-hold keys, which re-enables classic key-repeat functionality.
defaults_write "NSGlobalDomain" "ApplePressAndHoldEnabled" "int" "0"

# Set key repeat speed.
defaults_write "NSGlobalDomain" "KeyRepeat" "int" "2"
defaults_write "NSGlobalDomain" "InitialKeyRepeat" "int" "25"

# Various Finder options.
defaults_write "com.apple.finder" "ShowExternalHardDrivesOnDesktop" "int" "1"
defaults_write "com.apple.finder" "ShowHardDrivesOnDesktop" "int" "1"
defaults_write "com.apple.finder" "ShowMountedServersOnDesktop" "int" "1"
defaults_write "com.apple.finder" "ShowRemovableMediaOnDesktop" "int" "1"

# Set up iTerm2 integration.
local iterm2="$HOME/.iterm2_shell_integration.zsh"
if [[ ! -f "$iterm2" ]]
then
  curl -s -L https://iterm2.com/shell_integration/zsh -o "$iterm2"
  printf "Installed iTerm 2 shell integration\n"
fi

