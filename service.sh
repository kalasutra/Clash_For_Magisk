#!/system/bin/sh

until [ $(getprop sys.boot_completed) -eq 1 ]; do
  sleep 5
done
# default disable ipv6 accept_ra
echo 0 > /proc/sys/net/ipv6/conf/all/accept_ra
echo 0 > /proc/sys/net/ipv6/conf/wlan0/accept_ra
# echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
# echo 1 > /proc/sys/net/ipv6/conf/wlan0/disable_ipv6