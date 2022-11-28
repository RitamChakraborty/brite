#!/bin/bash

if [ $# -eq 0 ] 
then
  echo "Display current display and brightness"
else
  while getopts "gi" opt
  do
      case $opt in
        (i) # Increase brightness
          echo "Increase brightness" ;;
        (d) # Decrease brightness
          echo "Decrease brightness" ;;
        (*) # Unknown option
          printf "Illegal option '-%s'\n" "$opt" && exit 1 ;;
      esac
  done
fi