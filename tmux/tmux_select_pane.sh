#!/bin/bash

pane_at_edge() {
  direction=$1

  case "$direction" in
     "U") 
       coord='top'
       op='<='
     ;;
     "D")
       coord='bottom'
       op='>='
     ;;
     "L")
       coord='left'
       op='<='
     ;;
     "R")
       coord='right'
       op='>='
     ;;
  esac

  cmd="#{pane_id}:#{pane_$coord}:#{?pane_active,_active_,_no_}"
  panes=$(tmux list-panes -F "$cmd")
  active_pane=$(echo "$panes" | grep _active_)
  active_pane_id=$(echo "$active_pane" | cut -d: -f1)
  active_coord=$(echo "$active_pane" | cut -d: -f2)
  coords=$(echo "$panes" | cut -d: -f2)

  if [[ "$op" == ">=" ]]; then
    test_coord=$(echo "$coords" | sort -nr | head -n1)
    at_edge=$(( active_coord >= test_coord ? 1 : 0 ))
  else
    test_coord=$(echo "$coords" | sort -n | head -n1)
    at_edge=$(( active_coord <= test_coord ? 1 : 0 ))
  fi;

  echo $at_edge
}

direction=$1
session_name=$(tmux display-message -p "#{session_name}")
session_group=$(tmux display-message -p "#{session_group}")
edge=$(pane_at_edge $direction)

if [ $direction = "U" ] || [ $direction = "D" ] || [ "$edge" = 0 ]; then
    tmux select-pane "-$direction"
elif [ "$edge" = 1 ]; then
    case "$direction" in
        "L") echo "TMUX L" | nc localhost 3128 ;;
        "R") echo "TMUX R" | nc localhost 3128 ;;
    esac
else
    tmux display wat
fi

exit 0
