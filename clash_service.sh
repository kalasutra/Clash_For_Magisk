#!/system/bin/sh

mark_id="2020"
table_id="2020"
tun_device="utun"
tun_ip="198.18.0.0/16"
bin_name="clash"
bin_path="/system/bin/${bin_name}"
clash_data_dir="/sdcard/Documents/clash"
conf_file="${clash_data_dir}/config.yaml"
geoip_file="${clash_data_dir}/Country.mmdb"
pid_file="${clash_data_dir}/${bin_name}.pid"
selector_file="${clash_data_dir}/selector.txt"
selector_tmp="${clash_data_dir}/selector.tmp"


get_ec_parameter() {
     clash_ec_port=$(cat ${conf_file} | grep -E "^external-controller:" | head -n 1 | sed -E 's/external-controller: .*:([0-9]*).*/\1/')
     clash_secret=$(cat ${conf_file} | grep -E "^secret:" | head -n 1 | sed -E 's/secret: "?([^"]*)"?.*/\1/')
     if [ "${clash_ec_port}" = "" ] ; then
         clash_ec_port="9090"
     fi
}

selector_restore() {
    if test -s ${selector_file} ; then
        get_ec_parameter
        va="0"
        while read line ; do
            if [ "$va" = "0" ] ; then
                va="1"
                group=$(echo $line |tr -d '\n' |od -An -tx1|tr ' ' %|tr -d '\n')
            else
                va="0"
                selector=$line
                curl -v -H "Authorization: Bearer ${clash_secret}" -X PUT -d "{${selector}}" "127.0.0.1:${clash_ec_port}/proxies/${group}"
            fi
        done < ${selector_file}
    else
        echo -e "\033[7;32mselector.txt empty or not exist, selector restore abortion\033[0m"
    fi
}

selector_record() {
    get_ec_parameter
    curl -H "Authorization: Bearer ${clash_secret}" http://127.0.0.1:${clash_ec_port}/proxies | sed -E 's/Selector/Selector\n/g' | sed '$d' | sed -E 's/.*name":"(.*)","now":"(.*)","type.*/\1\n"name":"\2"/' > ${selector_tmp}
    if test -s ${selector_tmp} ; then
        cp -f ${selector_tmp} ${selector_file}
    else
        echo -e "\033[7;32mSelector empty, selector.txt not updated\033[0m"
    fi
    rm -f ${selector_tmp}
}

create_tun_link() {
    mkdir -p /dev/net
    if [ ! -L /dev/net/tun ] ; then
        ln -s /dev/tun /dev/net/tun
    fi
}

add_rule() {
    ip rule add fwmark ${mark_id} table ${table_id} pref 5000
    ip rule add from ${tun_ip} to ${tun_ip} table ${table_id} pref 14000
}

del_rule() {
    ip rule del fwmark ${mark_id} table ${table_id} pref 5000
    ip rule del from ${tun_ip} to ${tun_ip} table ${table_id} pref 14000
}

add_route() {
    ip route add default dev ${tun_device} table ${table_id}
    ip route add ${tun_ip} dev ${tun_device} table ${table_id}
}

flush_route() {
    ip route flush table ${table_id}
}

wait_clash_listen() {
    wait_count=0
    port_bind_program=$(netstat -antp | grep 7892 | awk '{print $7}' | awk -F '[/]' '{print $2}')
    while [ "${port_bind_program}" != "clash" ] && [ ${wait_count} -lt 30 ] ; do
        sleep 1
        port_bind_program=$(netstat -antp | grep 7892 | awk '{print $7}' | awk -F '[/]' '{print $2}')
        wait_count=$((${wait_count} + 1))
    done
    if [ "${port_bind_program}" = "clash" ] && probe_clash_alive ; then
        return 0
    else
        return 1
    fi
}

probe_clash_alive() {
    [ -f ${pid_file} ] && cmd_file="/proc/`cat ${pid_file}`/cmdline" || return 1
    [ -f ${cmd_file} ] && grep -q ${bin_name} ${cmd_file} && return 0 || return 1
}

start_service() {
    if probe_clash_alive ; then
        exit 0
    elif [ -f ${conf_file} ] && [ -f ${geoip_file} ] && ${bin_name} -d ${clash_data_dir} -t ; then
        chown root:sdcard_rw ${bin_path}
        chmod 6755 ${bin_path}
        create_tun_link
        nohup ${bin_name} -d ${clash_data_dir} &
        echo -n $! > ${pid_file}
        if wait_clash_listen ; then
            add_rule
            add_route
            selector_restore
            return 0
        else
            rm -f ${pid_file}
            return 1
        fi
    else
        return 2
    fi
}

stop_service() {
    selector_record
    kill -9 `cat ${pid_file}` || killall ${bin_name} || kill `cat ${pid_file}`
    sleep 1
    del_rule
    flush_route
    rm -f ${pid_file}
}

case "$1" in
    start)
        start_service
        ;;
    stop)
        stop_service
        ;;
    restart)
        stop_service
        sleep 1
        start_service
        ;;
    *)
        echo "$0: usage: $0 { start | stop | restart }"
        ;;
esac
