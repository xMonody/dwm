#!/bin/sh

compton &
feh --bg-scale ~/.go/ico/xiao.jpg
dwm_cpu()
{
    CPU=$(sar -u 1 1 | grep Average | awk '{printf $3+$5}')
    printf ":%.2f%%" "$CPU"
}

dwm_network () {
    CONNAME=$(nmcli -a | grep 'Wired connection' | awk 'NR==1{print $1}')
    if [ "$CONNAME" = "" ]; then
        CONNAME=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -c 5-)
    fi

    PRIVATE=$(nmcli -a | grep 'inet4 192' | awk '{print $2}')
    PUBLIC=$(curl -s https://ipinfo.io/ip)

    printf "%s" "$SEP1"
    if [ "$IDENTIFIER" = "unicode" ]; then
        printf "🌐 %s %s | %s" "$CONNAME" "$PRIVATE" "$PUBLIC"
    else
        printf "NET %s %s | %s" "$CONNAME" "$PRIVATE" "$PUBLIC"
    fi
    printf "%s\n" "$SEP2"
}

dwm_net()
{
      case $BLOCK_BUTTON in
	3) notify-send "🌐 网络流量模块" "\- 查看实时网络流量
: 下行流量
: 上行流量" ;;
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
    RX=$(echo $RX | awk '{print $1/102 4 "KB/s"}')
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

printf "$TX $RX"
}

dwm_net1()
{
    mynet
}
#--------------------------------------------------------------------------------------------------------------->
# #!/bin/bash                                                                                                                        
  #检测网络链接畅通
#function network()
#{
     #超时时间
 #    local timeout=1
     #目标网站
  #   local target=www.baidu.com
     #获取响应状态码
   #  local ret_code=`curl -I -s --connect-timeout ${timeout} ${target} -w %{http_code} | tail -n1`
     #if [ "x$ret_code" = "x200" ]; then
     ┆   #网络畅通
    # ┆   return 1
     #else
     ┆   #网络不畅通
     #┆   return 0
     #fi
    # return 0
 #} 
#network
 #if [ $? -eq 0 ];then
  #   echo "no"
   #  exit -1
 #fi
# echo "ok"
# exit 0
#----------------------------------------------------------------------------------------------------------


dwm_date () {
    date "+%H:%M:%S"
}
dwm_date0(){
    date "+%D"
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
      printf "%s%s%s\n" "$(df -h / | awk ' /[0-9]/ {print $4""$2}')"
}
dwm_weather()
{
      curl -sf 'wttr.in/FoShan?format=1'
}
dwm_free()
{
    #free --mebi | sed -n '2{p;q}' | awk '{printf ("%2.2fG%2.2fG%2.2fG\n", ( $4 / 1024),($3 / 1024)+($6 / 1024),($2/1024) )}'
    free --mebi | sed -n '2{p;q}' | awk '{printf ("%2.2fG%2.2fG\n", ( $4 / 1024),($2/1024) )}'
}
while xsetroot -name "$(dwm_cpu) ":"$(dwm_net1) ":"$(dwm_free) ":"$(dwm_df) "墳:"$(dwm_alsa) ":"$(dwm_date0) "ﮮ:"$(dwm_date)" 
do
    sleep 1 # refresh per 60s
done &
exec dwm
