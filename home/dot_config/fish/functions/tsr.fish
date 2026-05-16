function tsr --description "Refresh Neovim Tree-sitter parsers and queries"
  for directory in (find "$CHEZMOI/nvim/parsers" -type d -depth 1)
    set -l language (string split --max 1 --right - (basename $directory))[-1]
    set -l parser_output "$HOME/.config/nvim/parser/$language.so"
    echo "Building $language parser to $parser_output"
    tree-sitter build -o "$parser_output" $directory
  end

  for directory in (find "$CHEZMOI/nvim/queries" -type d -depth 1)
    set -l language (string split --max 1 --right - (basename $directory))[-1]
    set -l query_output "$HOME/.config/nvim/queries/$language"
    if not test -e "$query_output"
      echo "Linking $language queries to $query_output"
      ln -s $directory/queries "$query_output"
    else
      echo "Skipping $language queries (already linked)"
    end
  end
end
