function tsr --description "Refresh Neovim Tree-sitter parsers and queries"
  for directory in (find "$CHEZMOI/nvim/parsers" -type d -depth 1)
    set -l language (string split --max 1 --right - (basename $directory))[-1]
    tree-sitter build -o "$HOME/.config/nvim/parser/$language.so" $directory
  end

  for directory in (find "$CHEZMOI/nvim/queries" -type d -depth 1)
    set -l language (string split --max 1 --right - (basename $directory))[-1]
    if not test -e "$HOME/.config/nvim/queries/$language"
      ln -s $directory/queries "$HOME/.config/nvim/queries/$language"
    end
  end
end
