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

if [ ! $(grep linked <<< "$session_name") ] ||
    [ $direction = "U" ] || [ $direction = "D" ] ||
    [ "$edge" = 0 ]; then
    tmux select-pane "-$direction"
elif [ "$edge" = 1 ]; then
    linked_index=${session_name:6:6}
    min_name=$(tmux list-sessions | grep linked | head -n 1 | cut -d : -f 1)
    max_name=$(tmux list-sessions | grep linked | tail -n 1 | cut -d : -f 1)
    min_index=${min_name:6:6}
    max_index=${max_name:6:6}

    case "$direction" in
        "L") op='-';;
        "R") op='+';;
    esac

    new_index=$(($linked_index $op 1))

    if [ "$new_index" -gt "$max_index" ]; then
        new_index=$min_index
    elif [ "$new_index" -lt "$min_index" ]; then
        new_index=$max_index
    fi

    new_name="linked$new_index"
    new_tty=$(tmux list-clients | grep $new_name | cut -d : -f 1)

    APPLESCRIPT="
    tell application \"iTerm\"
        activate
        repeat with aWindow in windows
            set aTTY to tty of current session of aWindow
            
            if aTTY is equal to \"$new_tty\" then
                select aWindow
                exit repeat
            end if
        end repeat
    end tell
    "

    echo "$APPLESCRIPT" | osascript
else
    tmux display wat
fi
