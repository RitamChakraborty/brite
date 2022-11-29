#!/bin/bash

DISPLAY=$(xrandr -q | grep ' connected' | head -n 1 | cut -d ' ' -f1)

sqlite3 brite.db <<EOF
CREATE TABLE IF NOT EXISTS record  (
  id INTEGER PRIMARY KEY,
  display TEXT NOT NULL,
  brightness NUMERIC NOT NULL
);
EOF

if [ $# -eq 0 ] 
then
  echo "Display current display and brightness"
else
  ARG=$1
  HYPHEN_INDEX=`expr "$ARG" : '-'`

  if [ $HYPHEN_INDEX -eq 0 ]
  then
    echo "Change brightness to $ARG"
  else
    while getopts "id" opt
    do
      case $opt in
        (i) # Increase brightness
          echo "Increase brightness" ;;
        (d) # Decrease brightness
          echo "Decrease brightness" ;;
        (/?) # Unknown option
          printf "Illegal option '-%s'\n" "$opt" && exit 1 ;;
      esac
    done
  fi
fi

# randr -q | grep ' connected' | head -n 1 | cut -d ' ' -f1
# xrandr --output eDP-1 --brightness 1