#!/bin/sh

compton &
#picom -CGb &
#sudo apt-get install compton feh sysstat xsetroot alsa-utils dmenu
# 
feh --bg-scale ~/ico/15.jpg
#~/feh.sh &
dwm_cpu()
{
    #CPU=$(sar -u 1 1 | grep Average | awk '{printf $3+$5}')
    #printf ":%.2f%%" "$CPU"
    sar -u 1 1 | sed  -n '4{p;q}' | awk '{printf (":%d", $3+$5)}' 
}


dwm_net()
{
    sar -n DEV 1 1 | sed  -n '4{p;q}' | awk '{printf ("%3.1fk %3.1fk\n", $3,$4)}'    
}

dwm_date () {
    #date "+%H:%M:%S"
    date | awk '{printf ("%s%s %s %s",$2,$3,$4,$5)}'
}

dwm_alsa () {
    VOL=$(amixer get Master | tail -n1 | sed -r "s/.*\[(.*)%\].*/\1/")
    printf "%s" "$SEP1"
    if [ "$IDENTIFIER" = "unicode" ]; then
        if [ "$VOL" -eq 0 ]; then
            printf ""
        elif [ "$VOL" -gt 0 ] && [ "$VOL" -le 33 ]; then
            printf "%s%%" "$VOL"
        elif [ "$VOL" -gt 33 ] && [ "$VOL" -le 66 ]; then
            printf " %s%%" "$VOL"
        else
            printf " %s%%" "$VOL"
        fi
    else
        if [ "$VOL" -eq 0 ]; then
            printf "MUTE"
        elif [ "$VOL" -gt 0 ] && [ "$VOL" -le 33 ]; then
            printf "%s%%" "$VOL"
        elif [ "$VOL" -gt 33 ] && [ "$VOL" -le 66 ]; then
            printf "%s%%" "$VOL"
        else
            printf "%s%%" "$VOL"
        fi
    fi
    printf "%s\n" "$SEP2"
}

dwm_df()
{
      printf "%s%s%s\n" "$(df -h / | awk ' /[0-9]/ {print $4"<"$2}')"
}
dwm_weather()
{
      curl -sf 'wttr.in/GuangZhou?format=1'
}
dwm_free()
{
    free --mebi | sed  -n '2{p;q}' | awk '{printf ("%2.2fG<%2.2fG\n", ( $4 / 1024),($2/1024) )}'
}
dwm_xxx()
{
    sarr
}
while xsetroot -name " ":"$(dwm_net)  $(dwm_cpu)"%"  ":"$(dwm_free)  ":"$(dwm_df)  "墳:"$(dwm_alsa)  "ﮮ:"$(dwm_date)" 
do
    sleep 1 # refresh per 1s
done &
exec dwm
