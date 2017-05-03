#!/bin/bash

# Define the clock
Clock() {
  DATETIME=$(date "+%b. %d %H:%M")
  echo -n "$DATETIME"
}
Battery() {
  BATPERC=$(acpi --battery | cut -d, -f2 | xargs | cut -d "%" -f1 -)
  RESULT=""
  if [ "$BATPERC" -le "100" ] 
  then
    RESULT="\uf240 $BATPERC%"
  fi
  if [ "$BATPERC" -lt "75" ] 
  then
    RESULT="\uf241 $BATPERC%"
  fi
  if [ "$BATPERC" -lt "50" ] 
  then
    RESULT="\uf242 $BATPERC%"
  fi
  if [ "$BATPERC" -lt "25" ] 
  then
    RESULT="\uf243 $BATPERC%"
  fi
  if [ "$BATPERC" -lt "10" ] 
  then
    RESULT="\uf244 $BATPERC%"
  fi
  

  echo -en "$RESULT"
}
WindowTitle() {
	TITLE=$(xdotool getwindowfocus getwindowname)
	echo -n "$TITLE"
}
Volume() {
  VOL=$(pulseaudio-ctl full-status | cut -d" " -f1)
  echo -en "\uf028 $VOL"
}
Wifi() {
  WIFI=$(cat /home/anton/.files/scripts/.dbmon_nm_var_active_connection)
#  WIFI=$(nmcli connection show --active | grep wlp7s0 | awk '{print $1 "\t"}')
  echo -en "\uf1eb $WIFI"
}
SpotifySong() {
  SONG=$(/home/anton/.files/scripts/spotifyCurrSong);
  ARTIST=$(/home/anton/.files/scripts/spotifyCurrArtist);
  if [ -n "$SONG" ]
  then
    echo -en "\uf001 $SONG %{F#70838c}- $ARTIST%{F-}"
  else
    echo ""
  fi
}

while true; do
  barout=""
  Monitors=$(xrandr | grep -o "^.* connected" | sed "s/ connected//")
  tmp=0
  for m in $(echo "$Monitors"); do
    barout+="%{S${tmp}}%{l} $(WindowTitle) %{c} $(SpotifySong) %{r} $(Wifi) | $(Volume) | $(Battery) | $(Clock)        "
    let tmp=$tmp+1
  done
  echo $barout
  sleep 0.5
done
