#!/bin/bash
# scrot /tmp/screen.png
# convert /tmp/screen.png -scale 10% -scale 1000% /tmp/screen.png # Pixelate
# convert /tmp/screen.png -scale 2.5% -scale 4000% /tmp/screen.png # Pixelate
# convert /tmp/screen.png -blur 0x10 /tmp/screen.png # blur
# [[ -f $1 ]] && convert /tmp/screen.png $1 -gravity center -composite -matte /tmp/screen.png
# dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Stop
i3lock