#!/bin/bash

MIN_BRIGHTNESS=0
MAX_BRIGHTNESS=100
SCREEN=($(xrandr -q | grep ' connected' | head -n 1 | cut -d ' ' -f1))

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
    VALUES ("$SCREEN", 1);
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

function SCREEN_CURRENT_BRIGHTNESS() {
  echo "$SCREEN is set to brightness $(GET_CURRENT_BRIGHTNESS)"
}

function UPDATE_BRIGHTNESS() {
    sqlite3 brite.db <<EOF
    UPDATE record
    SET brightness=$1
    WHERE display='$SCREEN';
EOF
}

function CHANGE_BRIGHTNESS() {
  xrandr --output $SCREEN --brightness $1
  UPDATE_BRIGHTNESS $1
}

function INCREMENT_BRIGHTNESS() {
  local CURRENT_BRIGHTNESS=$(GET_CURRENT_BRIGHTNESS)

  if [ $(echo "$CURRENT_BRIGHTNESS != $MAX_BRIGHTNESS" | bc) -eq 1 ]
  then
    local NEW_BRIGHTNESS=0

    if [ $(echo "$CURRENT_BRIGHTNESS >= 1" | bc) -eq 1 ]
    then
      NEW_BRIGHTNESS=$(($CURRENT_BRIGHTNESS+1))

      if [ $(echo "$NEW_BRIGHTNESS > $MAX_BRIGHTNESS" | bc) -eq 1 ]
      then
        NEW_BRIGHTNESS=$MAX_BRIGHTNESS
      fi
    else
      NEW_BRIGHTNESS="$(echo $CURRENT_BRIGHTNESS + '0.1' | bc)"
    fi

    CHANGE_BRIGHTNESS $NEW_BRIGHTNESS
  fi
}

function DECREMENT_BRIGHTNESS() {
  local CURRENT_BRIGHTNESS=$(GET_CURRENT_BRIGHTNESS)

  if [ $(echo "$CURRENT_BRIGHTNESS != $MIN_BRIGHTNESS" | bc) -eq 1 ]
  then
    local NEW_BRIGHTNESS=0

    if [ $(echo "$CURRENT_BRIGHTNESS > 1" | bc) -eq 1 ]
    then
      NEW_BRIGHTNESS=$(($CURRENT_BRIGHTNESS-1))
    else
      NEW_BRIGHTNESS="$(echo $CURRENT_BRIGHTNESS - '0.1' | bc)"
      
      if [ $(echo "$NEW_BRIGHTNESS < $MIN_BRIGHTNESS" | bc) -eq 1 ]
      then
        NEW_BRIGHTNESS=$MIN_BRIGHTNESS
      fi
    fi

    CHANGE_BRIGHTNESS $NEW_BRIGHTNESS
  fi
}

if [ $# -eq 0 ] 
then
  SCREEN_CURRENT_BRIGHTNESS
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
        (i)
          INCREMENT_BRIGHTNESS ;;
        (d)
          DECREMENT_BRIGHTNESS ;;
        (*)
          echo "Try 'brite --help' for more information."
          exit 1
      esac
    done
  fi
fi