#!/bin/bash

DISPLAY=$(xrandr -q | grep ' connected' | head -n 1 | cut -d ' ' -f1)

sqlite3 brite.db <<EOF
CREATE TABLE IF NOT EXISTS record  (
  id INTEGER PRIMARY KEY,
  display TEXT NOT NULL,
  brightness NUMERIC NOT NULL
);
EOF

RECORD_COUNT=$(
sqlite3 brite.db <<EOF 
  SELECT COUNT(*) FROM record; 
EOF
)

if [ $RECORD_COUNT -eq 0 ]
then
  sqlite3 brite.db <<EOF
    INSERT INTO record (display, brightness)
    VALUES ("$DISPLAY", 1);
EOF
fi

function DISPLAY_CURRENT_BRIGHTNESS() {
  CURRENT_BRIGHTNESS=$(
sqlite3 brite.db <<EOF 
  SELECT brightness FROM record;
EOF
)
  echo "$DISPLAY is set to brightness $CURRENT_BRIGHTNESS"
}

if [ $# -eq 0 ] 
then
  DISPLAY_CURRENT_BRIGHTNESS
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