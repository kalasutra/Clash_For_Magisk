#!/system/bin/sh

scripts=`realpath $0`
scripts_dir=`dirname ${scripts}`
old_local_ipv4=(127.0.0.1)
. /data/clash/clash.config

monitor_local_ipv4() {
    new_local_ipv4=$(ip a |awk '$1~/inet$/{print $2}')

    for new_subnet in ${new_local_ipv4[*]} ; do
        wait_count=0
        for old_subnet in ${old_local_ipv4[*]} ; do
            if [ "${new_subnet}" != "${old_subnet}" ] ; then
                wait_count=$((${wait_count} + 1))
                if [ wait_count -eq ${#old_local_ipv4[*]} ] ; then
                    echo ${new_subnet}
                fi
            fi
        done

    done

    old_local_ipv4=${new_local_ipv4}
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

while getopts ":kf" signal ; do
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
        ?)
            echo ""
            ;;
    esac
done