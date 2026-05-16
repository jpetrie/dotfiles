function gr --description "Jump to repository root directory"
  cd (git rev-parse --show-toplevel)
end

