#!/system/bin/sh

appid_list=()
proxy_mode="none"
appid_file="/sdcard/Documents/clash/appid.list"
sdcard_rw_uid="1015"
mark_id="2020"
clash_redir_port="7892"
clash_dns_port="1053"
tun_ip="198.18.0.0/16"
intranet=(0.0.0.0/8 10.0.0.0/8 127.0.0.0/8 169.254.0.0/16 172.16.0.0/12 192.168.0.0/16 224.0.0.0/4 240.0.0.0/4)

create_mangle_iptables() {
    iptables -t mangle -N CLASH

    for subnet in ${intranet[@]} ; do
        iptables -t mangle -A CLASH -d ${subnet} -j RETURN
    done

    iptables -t mangle -A CLASH -p tcp ! --dport 53 -j MARK --set-xmark ${mark_id}
    iptables -t mangle -A CLASH -p udp ! --dport 53 -j MARK --set-xmark ${mark_id}

    create_dns_iptables
    create_proxy_iptables
    create_ap_iptables
}

create_ap_iptables() {
    iptables -t nat -N AP_PROXY
    for subnet in ${intranet[@]} ; do
        iptables -t nat -A AP_PROXY -d ${subnet} -j RETURN
    done
    iptables -t nat -A AP_PROXY -i wlan0 -p tcp -j REDIRECT --to-port ${clash_redir_port}
    iptables -t nat -I PREROUTING -j AP_PROXY
    iptables -t nat -I PREROUTING -j DNS
}

create_proxy_iptables() {
    iptables -t mangle -N PROXY
    iptables -t nat -N FILTER_DNS

    iptables -t mangle -A PROXY -m owner --gid-owner ${sdcard_rw_uid} -j RETURN
    iptables -t nat -A FILTER_DNS -m owner --gid-owner ${sdcard_rw_uid} -j RETURN

    probe_proxy_mode

    if [ "${proxy_mode}" = "ALL" ] ; then
        iptables -t mangle -A PROXY -j CLASH
        iptables -t nat -A FILTER_DNS -j DNS
    elif [ "${proxy_mode}" = "skip" ] ; then
        for appid in ${appid_list[@]} ; do
            iptables -t mangle -I PROXY -m owner --uid-owner ${appid} ! -d ${tun_ip} -j RETURN
            iptables -t nat -A FILTER_DNS -m owner --uid-owner ${appid} -j RETURN
        done
        iptables -t mangle -A PROXY -j CLASH
        iptables -t nat -A FILTER_DNS -j DNS
    elif [ "${proxy_mode}" = "pick" ] ; then
        for appid in ${appid_list[@]} ; do
            iptables -t mangle -A PROXY -m owner --uid-owner ${appid} -j CLASH
            iptables -t nat -A FILTER_DNS -m owner --uid-owner ${appid} -j DNS
        done
    fi

    iptables -t mangle -A OUTPUT -j PROXY
    iptables -t nat -A OUTPUT -j FILTER_DNS
}

probe_proxy_mode() {
    echo "" >> ${appid_file}
    sed -i '/^$/d' "${appid_file}"
    if [ -f "${appid_file}" ] ; then
        first_line=$(head -1 ${appid_file})
        if [ "${first_line}" = "ALL" ] ; then
            proxy_mode=ALL
        elif [ "${first_line}" = "bypass" ] ; then
            proxy_mode=skip
        else
            proxy_mode=pick
        fi
    fi

    while read appid_line ; do
        appid_text=(`echo ${appid_line}`)
        for appid_word in ${appid_text[*]} ; do
            if [ "${appid_word}" = "bypass" ] ; then
                break
            else
                appid_list=(${appid_list[*]} ${appid_word})
            fi
        done
    done < ${appid_file}
    # echo ${appid_list[*]}
}

create_dns_iptables() {
    iptables -t nat -N DNS
    iptables -t nat -A DNS -p tcp --dport 53 -j REDIRECT --to-port ${clash_dns_port}
    iptables -t nat -A DNS -p udp --dport 53 -j REDIRECT --to-port ${clash_dns_port}
}

flush_iptables() {
    # Delete iptables rules
    iptables -t nat -D PREROUTING -j AP_PROXY
    iptables -t nat -D PREROUTING -j DNS
    # Clear iptables chain
    iptables -t mangle -F OUTPUT
    iptables -t nat -F OUTPUT
    iptables -t mangle -F CLASH
    iptables -t mangle -F PROXY
    iptables -t nat -F FILTER_DNS
    iptables -t nat -F DNS
    iptables -t nat -F AP_PROXY
    # Delete iptables chain
    iptables -t mangle -X CLASH
    iptables -t mangle -X PROXY
    iptables -t nat -X FILTER_DNS
    iptables -t nat -X DNS
    iptables -t nat -X AP_PROXY
}

disable_proxy() {
    flush_iptables 2> /dev/null
}

enable_proxy() {
    create_mangle_iptables
}

case "$1" in
  enable)
    disable_proxy
    enable_proxy
    ;;
  disable)
    disable_proxy
    ;;
  restart)
    disable_proxy
    sleep 1
    enable_proxy
    ;;
  *)
    echo "$0:  usage:  $0 { enable | disable | restart }"
    ;;
esac