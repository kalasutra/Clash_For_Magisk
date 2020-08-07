#!/system/bin/sh

pid_file="/sdcard/Documents/clash/clash.pid"
wait_count=0
until [ $(getprop sys.boot_completed) -eq 1 ] && [ -d "/sdcard/Documents" ]; do
  sleep 2
  wait_count=$((${wait_count} + 1))
  if [ ${wait_count} -ge 100 ] ; then
    exit 0
  fi
done

if [ -f ${pid_file} ] ; then
    rm -rf ${pid_file}
fi

clash_control enable
# default disable ipv6 accept_ra
echo 0 > /proc/sys/net/ipv6/conf/all/accept_ra
echo 0 > /proc/sys/net/ipv6/conf/wlan0/accept_ra
# echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
# echo 1 > /proc/sys/net/ipv6/conf/wlan0/disable_ipv6
