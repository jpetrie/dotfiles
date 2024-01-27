# Dotfiles
This repository contains my dotfiles, along with the script to install them and setup a machine.

## Usage
`install.sh` handles the entire setup process. When run, this script will:

 - Install [Homebrew](https://brew.sh), if neccessary.
 - Use Homebrew to install various tools and utilities.
 - Create symlinks for the dotfile hierarchy defined in the repository's `dot` subdirectory.
 - Set a variety of options via `defaults`.
 - Install [iTerm2's ZSH shell integration](https://iterm2.com/documentation-shell-integration.html) to
`~/.term2_shell_integration.zsh` if it is missing (using `curl`).

`install.sh` reports on the changes it makes (which files it links, which options it sets, and so on), and tries to
avoid doing redundant work. If it produces no output when run, that means it didn't need to do anything.

When creating symlinks, the `install.sh` transforms each file's path by replacing everything up to the `dot` directory
with an actual dot, and creating the resulting file as a symlink under `~`. For example, `dot/ssh/config` becomes
`~/.ssh/config` while `dot/zshrc` becomes simply `~/.zshrc`. 

Any intermediate directories are actually created (rather than linked) in order to solve for the cases where a file in
one of those directories might contain sensitive information or otherwise shouldn't be in version control _without_ 
having to bother maintaining a `.gitignore` for the repository that names all such cases.

