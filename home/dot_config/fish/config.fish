set -gx CMAKE_EXPORT_COMPILE_COMMANDS 1
set -gx EDITOR nvim
set -gx HOMEBREW_NO_ANALYTICS 1
set -gx HOMEBREW_NO_AUTO_UPDATE 1
set -gx PROJECTS "$HOME/Developer"
set -gx VISUAL $EDITOR

# gp: Quickly jump to project directories.
function gp -a project;
  set destination "$PROJECTS/$project"
  if test -d $destination
    cd $destination
  else
    echo "Not a project directory: $destination"
    return 1
  end
end

if status is-interactive
  # Turn off the welcome message.
  set fish_greeting

  set -g fish_autosuggestion_enabled 0
  set -g fish_key_bindings fish_vi_key_bindings

  abbr --add cm chezmoi
  abbr --add e $EDITOR
  abbr --add g git
  abbr --add ls eza
  abbr --add ll eza -1la
  abbr --add tl eza -lT

  starship init fish | source
end

# Ensure brew is loaded into the environment.
eval (/opt/homebrew/bin/brew shellenv)

