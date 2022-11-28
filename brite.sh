#!/bin/bash

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