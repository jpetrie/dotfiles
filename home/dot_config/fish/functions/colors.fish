function colors --description "Show the 16 ANSI terminal colors"

  printf "$(tput setab  0) $(tput sgr0) $(tput setaf 0)  black 00 $(tput setab 0)  $(tput sgr0) "
  printf "$(tput setab  8)  $(tput sgr0)$(tput setaf  8) 08 bright black$(tput sgr0)\n"

  printf "$(tput setab  0) $(tput sgr0) $(tput setaf 1)    red 01 $(tput setab 1)  $(tput sgr0) "
  printf "$(tput setab  9)  $(tput sgr0)$(tput setaf  9) 09 bright red$(tput sgr0)\n"

  printf "$(tput setab  8) $(tput sgr0) $(tput setaf 2)  green 02 $(tput setab 2)  $(tput sgr0) "
  printf "$(tput setab 10)  $(tput sgr0)$(tput setaf 10) 10 bright green$(tput sgr0)\n"

  printf "$(tput setab  8) $(tput sgr0) $(tput setaf 3) yellow 03 $(tput setab 3)  $(tput sgr0) "
  printf "$(tput setab 11)  $(tput sgr0)$(tput setaf 11) 11 bright yellow$(tput sgr0)\n"

  printf "$(tput setab  7) $(tput sgr0) $(tput setaf 4)   blue 04 $(tput setab 4)  $(tput sgr0) "
  printf "$(tput setab 12)  $(tput sgr0)$(tput setaf 12) 12 bright blue$(tput sgr0)\n"

  printf "$(tput setab  7) $(tput sgr0) $(tput setaf 5)magenta 05 $(tput setab 5)  $(tput sgr0) "
  printf "$(tput setab 13)  $(tput sgr0)$(tput setaf 13) 13 bright magenta$(tput sgr0)\n"

  printf "$(tput setab 15) $(tput sgr0) $(tput setaf 6)   cyan 06 $(tput setab 6)  $(tput sgr0) "
  printf "$(tput setab 14)  $(tput sgr0)$(tput setaf 14) 14 bright cyan$(tput sgr0)\n"

  printf "$(tput setab 15) $(tput sgr0) $(tput setaf 7)  white 07 $(tput setab 7)  $(tput sgr0) "
  printf "$(tput setab 15)  $(tput sgr0)$(tput setaf 15) 15 bright white$(tput sgr0)\n"
end
