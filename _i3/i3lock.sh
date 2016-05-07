#!/bin/bash

SCRIPTPATH=$(realpath "$0")
SCRIPTPATH=${SCRIPTPATH%/*}

scrot /tmp/screen_locked.png

convert /tmp/screen_locked.png \
    -blur 0x5 \
    -brightness-contrast \
    -25x-25 \
    /tmp/screen_locked_blur.png

convert /tmp/screen_locked_blur.png \
    -gravity center "${SCRIPTPATH}/lock.png" \
    -composite \
    /tmp/screen_locked_blur.png

i3lock -n -i /tmp/screen_locked_blur.png
