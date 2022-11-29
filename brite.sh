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

function GET_CURRENT_BRIGHTNESS() {
  local CURRENT_BRIGHTNESS=$(
sqlite3 brite.db <<EOF 
  SELECT brightness FROM record;
EOF
)
  echo $CURRENT_BRIGHTNESS
}

function DISPLAY_CURRENT_BRIGHTNESS() {
  echo "$DISPLAY is set to brightness $(GET_CURRENT_BRIGHTNESS)"
}

function CHANGE_BRIGHTNESS() {
  echo "Value : $1"
}

if [ $# -eq 0 ] 
then
  DISPLAY_CURRENT_BRIGHTNESS
else
  ARG=$1
  HYPHEN_INDEX=`expr "$ARG" : '-'`

  if [ $HYPHEN_INDEX -eq 0 ]
  then
    CHANGE_BRIGHTNESS $ARG
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