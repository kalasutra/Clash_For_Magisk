#!/system/bin/sh

scripts=`realpath $0`
scripts_dir=`dirname ${scripts}`
. /data/clash/clash.config

monitor_local_ipv4() {
    local_ipv4=$(ip a | awk '$1~/inet$/{print $2}')
    local_ipv4_number=$(ip a | awk '$1~/inet$/{print $2}' | wc -l)
    rules_ipv4=$(${iptables_wait} -t mangle -nvL FILTER_LOCAL_IPV4 | grep "RETURN" | awk '{print $9}')
    rules_number=$(${iptables_wait} -t mangle -L FILTER_LOCAL_IPV4 | grep "RETURN" | wc -l)

    for rules_subnet in ${rules_ipv4[*]} ; do
        wait_count=0
        a_subnet=$(ipcalc -n ${rules_subnet} | awk -F '=' '{print $2}')

        for local_subnet in ${local_ipv4[*]} ; do
            b_subnet=$(ipcalc -n ${local_subnet} | awk -F '=' '{print $2}')

            if [ "${a_subnet}" != "${b_subnet}" ] ; then
                wait_count=$((${wait_count} + 1))
                
                if [ ${wait_count} -ge ${local_ipv4_number} ] ; then
                    ${iptables_wait} -t mangle -D FILTER_LOCAL_IPV4 -d ${rules_subnet} -j RETURN
                fi
            fi
        done
    done

    for subnet in ${local_ipv4[*]} ; do
        if ! (${iptables_wait} -t mangle -C FILTER_LOCAL_IPV4 -d ${subnet} -j RETURN > /dev/null 2>&1) ; then
            ${iptables_wait} -t mangle -A FILTER_LOCAL_IPV4 -d ${subnet} -j RETURN
        fi
    done
}

keep_dns() {
    local_dns=`getprop net.dns1`

    if [ "${local_dns}" != "${static_dns}" ] ; then
        setprop net.dns1 ${static_dns}
    fi
}

find_packages_uid() {
    echo "" > ${appuid_file}
    for package in `cat ${filter_packages_file} | sort -u` ; do
        awk '$1~/'^"${package}"$'/{print $2}' ${system_packages_file} >> ${appuid_file}
    done
}

while getopts ":kfm" signal ; do
    case ${signal} in
        k)
            while true ; do
                keep_dns
                sleep 2
            done
            ;;
        f)
            find_packages_uid
            ;;
        m)
            while true ; do
                until [ -f ${Clash_pid_file} ] ; do
                    sleep 1
                done
                monitor_local_ipv4
                sleep 2
            done
            ;;
        ?)
            echo ""
            ;;
    esac
done