function vp -a plugin --description "Jump to a Neovim plugin"
  set destination "$HOME/.local/share/chezmoi/nvim/pack/plugins/start/$plugin"
  if test -d $destination
    cd $destination
  else
    echo "Not a plugin directory: $destination"
    return 1
  end
end

