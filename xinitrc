#!/bin/sh

compton &
feh --bg-scale ~/.bin.jpg

dwm_net()
{
      case $BLOCK_BUTTON in
	3) notify-send "🌐 网络流量模块" "\- 查看实时网络流量
- ⏬: 下行流量
- ⏫: 上行流量" ;;
	6) "$TERMINAL" -e "$EDITOR" "$0" ;;
esac

update() {
    sum=0
    for arg; do
        read -r i < "$arg"
        sum=$(( sum + i ))
    done
    cache=${XDG_CACHE_HOME:-$HOME/.cache}/${1##*/}
    [ -f "$cache" ] && read -r old < "$cache" || old=0
    printf %d\\n "$sum" > "$cache"
    printf %d\\n $(( sum - old ))
}

RX=$(update /sys/class/net/[ew]*/statistics/rx_bytes)
TX=$(update /sys/class/net/[ew]*/statistics/tx_bytes)

# 换算单位
if [[ $RX -lt 1024 ]];then
    # 如果接收速率小于1024,则单位为B/s
    RX="${RX}B/s"
elif [[ $RX -gt 1048576 ]];then
    # 否则如果接收速率大于 1048576,则改变单位为MB/s
    RX=$(echo $RX | awk '{print $1/1048576 "MB/s"}')
else
    # 否则如果接收速率大于1024但小于1048576,则单位为KB/s
    RX=$(echo $RX | awk '{print $1/1024 "KB/s"}')
fi

# 换算单位
if [[ $TX -lt 1024 ]];then
    # 如果发送速率小于1024,则单位为B/s
    TX="${TX}B/s"
elif [[ $TX -gt 1048576 ]];then
    # 否则如果发送速率大于 1048576,则改变单位为MB/s
    TX=$(echo $TX | awk '{print $1/1048576 "MB/s"}')
else
    # 否则如果发送速率大于1024但小于1048576,则单位为KB/s
    TX=$(echo $TX | awk '{print $1/1024 "KB/s"}')
fi

printf "↑$TX ↓$RX"
}


dwm_date() 
{
    date '+%Y/%m/%d date:%H:%M:%S'
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
      printf "%s%s\n" "$(df -h / | awk ' /[0-9]/ {print $3 "/" $2}')"
}
dwm_free()
{
      free --mebi | sed -n '2{p;q}' | awk '{printf ("%2.2fGiB/%2.2fGiB\n", ( $3 / 1024), ($2 / 1024))}'
}
while xsetroot -name ""net:"$(dwm_net) "free:"$(dwm_free) "hd:"$(dwm_df) "vol:"$(dwm_alsa) $(dwm_date)" 
do
    sleep 1 # refresh per 60s
done &
exec dwm
