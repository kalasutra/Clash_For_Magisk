#!/system/bin/sh

scripts=`realpath $0`
scripts_dir=`dirname ${scripts}`
. /data/clash/clash.config

monitor_local_ipv4() {
    local_ipv4=$(ip a | awk '$1~/inet$/{print $2}')
    local_ipv4_number=$(ip a | awk '$1~/inet$/{print $2}' | wc -l)
    rules_ipv4=$(${iptables_wait} -t mangle -nvL FILTER_LOCAL_IP | grep "ACCEPT" | awk '{print $9}')
    rules_number=$(${iptables_wait} -t mangle -L FILTER_LOCAL_IP | grep "ACCEPT" | wc -l)

    if [ ${local_ipv4_number} -ne ${rules_number} ] ; then
        for rules_subnet in ${rules_ipv4[*]} ; do
            wait_count=0
            a_subnet=$(ipcalc -n ${rules_subnet} | awk -F '=' '{print $2}')
            for local_subnet in ${local_ipv4[*]} ; do
                b_subnet=$(ipcalc -n ${local_subnet} | awk -F '=' '{print $2}')

                if [ "${a_subnet}" != "${b_subnet}" ] ; then
                    wait_count=$((${wait_count} + 1))
                    
                    if [ ${wait_count} -ge ${local_ipv4_number} ] ; then
                        ${iptables_wait} -t mangle -D FILTER_LOCAL_IP -d ${rules_subnet} -j ACCEPT
                    fi
                fi
            done
        done

        for subnet in ${local_ipv4[*]} ; do
            if ! (${iptables_wait} -t mangle -C FILTER_LOCAL_IP -d ${subnet} -j ACCEPT > /dev/null 2>&1) ; then
                ${iptables_wait} -t mangle -I FILTER_LOCAL_IP -d ${subnet} -j ACCEPT
            fi
        done

        unset a_subnet
        unset b_subnet
    else
        exit 0
    fi

    unset local_ipv4
    unset local_ipv4_number
    unset rules_ipv4
    unset rules_number
    unset wait_count
}

keep_dns() {
    local_dns=`getprop net.dns1`

    if [ "${local_dns}" != "${static_dns}" ] ; then
        sleep 5
        setprop net.dns1 ${static_dns}
    fi

    unset local_dns
}

subscription() {
    if [ "${auto_subscription}" = "true" ] ; then
        mv -f ${Clash_config_file} ${Clash_data_dir}/config.yaml.backup
        curl -L -A 'clash' ${subscription_url} -o ${Clash_config_file} >> /dev/null 2>&1

        sleep 20

        if [ -f "${Clash_config_file}" ]; then
            ${scripts_dir}/clash.service -k && ${scripts_dir}/clash.tproxy -k
            rm -rf ${Clash_data_dir}/config.yaml.backup
            sleep 1
            ${scripts_dir}/clash.service -s && ${scripts_dir}/clash.tproxy -s
        else
            mv ${Clash_data_dir}/config.yaml.backup ${Clash_config_file}
        fi
    else
        exit 0
    fi
}

find_packages_uid() {
    if [ "${mode}" = "blacklist" ] ; then
        echo "1000 1001 1010 1014 1016" > ${appuid_file}
    elif [ "${mode}" = "whitelist" ] ; then
        echo "" > ${appuid_file}
    fi
    for package in `cat ${filter_packages_file} | sort -u` ; do
        awk '$1~/'^"${package}"$'/{print $2}' ${system_packages_file} >> ${appuid_file}
    done
}

port_detection() {
    clash_pid=`cat ${Clash_pid_file}`
    clash_port=$(ss -antup | grep "clash" | awk '$7~/'pid="${clash_pid}"*'/{print $5}' | awk -F ':' '{print $2}' | sort -u)
    match_count=0
    for sub_port in ${clash_port[*]} ; do
        sleep 0.5
        if [ "${sub_port}" = ${Clash_tproxy_port} ] || [ "${sub_port}" = ${Clash_dns_port} ] ; then
            match_count=$((${match_count} + 1))
        fi
    done

    if [ ${match_count} -ge 2 ] ; then
        exit 0
    else
        exit 1
    fi
}

while getopts ":kfmps" signal ; do
    case ${signal} in
        s)
            subscription
            ;;
        k)
            if [ "${mode}" = "blacklist" ] || [ "${mode}" = "whitelist" ] ; then
                keep_dns
            else
                exit 0
            fi
            ;;
        f)
            find_packages_uid
            ;;
        m)
            if [ "${mode}" = "blacklist" ] && [ -f "${Clash_pid_file}" ] ; then
                monitor_local_ipv4
            else
                exit 0
            fi
            ;;
        p)
            sleep 5
            port_detection
            ;;
        ?)
            echo ""
            ;;
    esac
done