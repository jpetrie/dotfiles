function gp -a project --description "Jump to project directory"
  set destination "$PROJECTS/$project"
  if test -d $destination
    cd $destination
  else
    echo "Not a project directory: $destination"
    return 1
  end
end

