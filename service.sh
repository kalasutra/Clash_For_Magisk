until [ $(getprop sys.boot_completed) -eq 1 ] ; do
    sleep 5
done

service_path=`realpath $0`
module_dir=`dirname ${service_path}`
scripts_dir="${module_dir}/scripts"
Clash_pid_file="${Clash_run_path}/clash.pid"

until [ -d "/data/clash" ] ; do
    sleep 1
done

if [ -f ${Clash_pid_file} ] ; then
    rm -rf ${Clash_pid_file}
fi

${scripts_dir}/clash.service -s && ${scripts_dir}/clash.tproxy -s
inotifyd ${scripts_dir}/clash.inotify ${module_dir} >> /dev/null &
${scripts_dir}/clash.tool -s &
${scripts_dir}/clash.tool -k &
${scripts_dir}/clash.tool -m &