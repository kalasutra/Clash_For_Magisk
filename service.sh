sysctl -w net.ipv6.conf.all.accept_ra=0
sysctl -w net.ipv6.conf.default.accept_ra=0
sysctl -w net.ipv6.conf.wlan0.accept_ra=0
sysctl -w net.ipv6.conf.wlan1.accept_ra=0

sysctl -w net.ipv6.conf.wlan0.disable_ipv6=1
sysctl -w net.ipv6.conf.wlan1.disable_ipv6=1
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1

until [ $(getprop sys.boot_completed) -eq 1 ] ; do
    sleep 5
done

service_path=`realpath $0`
module_dir=`dirname ${service_path}`
scripts_dir="${module_dir}/scripts"

${scripts_dir}/clash.service -s && ${scripts_dir}/clash.tproxy -s
inotifyd ${scripts_dir}/clash.inotify ${module_dir} >> /dev/null &