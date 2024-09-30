#!/bin/zsh

# Create symlinks in ~ to all (visible) files underneath the "dot" directory.
for file in $(find -s "dot" -type f -not -name ".*")
do
  local actual="${file:a}"
  local link="${HOME}/${file:s/dot\//.}"
  local root="${link:h}"

  if [[ -L "${link}" ]] then
    if [[ "$(readlink ${link})" != "${actual}" ]] then
      # For existing links, only report if the target is different than expected.
      print -P "%F{red}skip%f ${link} %F{red}(a link to a different file exists)%f"
    fi
    continue
  fi

  if [[ -f "${link}" ]] then
    print -P "%F{red}skip%f ${link} %F{red}(a file with the same name exists)%f"
    continue
  fi

  if [[ -d "${link}" ]] then
    print -P "%F{red}skip%f ${link} %F{red}(a directory with the same name exists)%f"
    continue
  fi

  # Create the link (and any neccessary intermediate directories).
  mkdir -p "${root}"
  ln -s "${actual}" "${link}"
  print -P "%F{green}link%f ${link} %F{green}to%f ${actual}"
done

