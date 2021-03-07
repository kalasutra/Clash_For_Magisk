until [ $(getprop sys.boot_completed) -eq 1 ] ; do
    sleep 5
done

service_path=`realpath $0`
module_dir=`dirname ${service_path}`
scripts_dir="${module_dir}/scripts"
Clash_data_dir="/data/clash"
Clash_run_path="${Clash_data_dir}/run"
Clash_pid_file="${Clash_run_path}/clash.pid"
busybox_path="/data/adb/magisk/busybox"

until [ -d "/data/clash" ] ; do
    sleep 1
done

if [ -f ${Clash_pid_file} ] ; then
    rm -rf ${Clash_pid_file}
fi

nohup ${busybox_path} crond -c ${Clash_run_path} > /dev/null 2>&1 &

${scripts_dir}/clash.service -s && ${scripts_dir}/clash.tproxy -s
inotifyd ${scripts_dir}/clash.inotify ${module_dir} >> /dev/null &