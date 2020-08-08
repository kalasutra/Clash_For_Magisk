# override the official Magisk module installer
SKIPUNZIP=1

wait_count=0
download_command=""
download_version=""
sdcard_rw_id="1015"
command_judgment="true"
clash_data_dir="/sdcard/Documents/clash"
download_location="${MODPATH}/system/bin/clash.gz"
appid_file="${clash_data_dir}/appid.list"
download_link="https://tmpclashpremiumbindary.cf"


if [ $BOOTMODE ! = true ] ; then
    abort "! Please install in Magisk Manager"
fi

if $(curl -V > /dev/null 2>&1) ; then
    download_command="curl -k -L -o ${download_location}"
elif $(wget --help > /dev/null 2>&1) ; then
    command_judgment="flase"
    download_command="wget --no-check-certificate -O ${download_location}"
else
    abort "! Please install the busybox module and try again."
fi

download_canary_version() {
    case "${ARCH}" in
        arm)
            if [ "${command_judgment}" == "true" ] ; then
                download_version=$(curl -k -s ${download_link} | grep -o clash-linux-armv7-*.*.*.*.gz | awk -F '>' '{print $2}')
                ${download_command} ${download_link}/${download_version}
            else
                touch ${TMPDIR}/version
                wget --no-check-certificate -O ${TMPDIR}/version ${download_link}
                download_version=$(cat ${TMPDIR}/version | grep -o clash-linux-armv7-*.*.*.*.gz | awk -F '>' '{print $2}')
                ${download_command} ${download_link}/${download_version}
            fi
            ;;
        arm64)
            if [ "${command_judgment}" == "true" ] ; then
                download_version=$(curl -k -s ${download_link} | grep -o clash-linux-armv8-*.*.*.*.gz | awk -F '>' '{print $2}')
                ${download_command} ${download_link}/${download_version}
            else
                touch ${TMPDIR}/version
                wget --no-check-certificate -O ${TMPDIR}/version ${download_link}
                download_version=$(cat ${TMPDIR}/version | grep -o clash-linux-armv8-*.*.*.*.gz | awk -F '>' '{print $2}')
                ${download_command} ${download_link}/${download_version}
            fi
            ;;
        x86)
            if [ "${command_judgment}" == "true" ] ; then
                download_version=$(curl -k -s ${download_link} | grep -o clash-linux-386-*.*.*.*.gz | awk -F '>' '{print $2}')
                ${download_command} ${download_link}/${download_version}
            else
                touch ${TMPDIR}/version
                wget --no-check-certificate -O ${TMPDIR}/version ${download_link}
                download_version=$(cat ${TMPDIR}/version | grep -o clash-linux-386-*.*.*.*.gz | awk -F '>' '{print $2}')
                ${download_command} ${download_link}/${download_version}
            fi
            ;;
        x64)
            if [ "${command_judgment}" == "true" ] ; then
                download_version=$(curl -k -s ${download_link} | grep -o clash-linux-amd64-*.*.*.*.gz | awk -F '>' '{print $2}')
                ${download_command} ${download_link}/${download_version}
            else
                touch ${TMPDIR}/version
                wget --no-check-certificate -O ${TMPDIR}/version ${download_link}
                download_version=$(cat ${TMPDIR}/version | grep -o clash-linux-amd64-*.*.*.*.gz | awk -F '>' '{print $2}')
                ${download_command} ${download_link}/${download_version}
            fi
            ;;
    esac
}

mkdir -p $MODPATH/system/bin
mkdir -p ${clash_data_dir}

if [ ! -f ${appid_file} ] ; then
    ui_print "- Set the default mode to global."
    echo "ALL" > ${appid_file}
fi

ui_print "- Start downloading the kernel file."
until [ -f ${download_location} ] && $(gzip -d ${download_location}) ; do
    download_canary_version
    wait_count=$((${wait_count} + 1))
    if [ ${wait_count} -ge 6 ] ; then
        abort "! I have tried to download 5 times but failed. Please save the log and hand it to the developer to solve it."
    fi
done

ui_print "- Start installing the necessary files."
unzip -j -o "${ZIPFILE}" 'clash_control.sh' -d $MODPATH/system/bin >&2
unzip -j -o "${ZIPFILE}" 'clash_service.sh' -d $MODPATH >&2
unzip -j -o "${ZIPFILE}" 'clash_tproxy.sh' -d $MODPATH >&2
unzip -j -o "${ZIPFILE}" 'service.sh' -d $MODPATH >&2
unzip -j -o "${ZIPFILE}" 'uninstall.sh' -d $MODPATH >&2
mv $MODPATH/system/bin/clash_control.sh $MODPATH/system/bin/clash_control

ui_print "- Start updating the module file"
rm -rf $MODPATH/module.prop
touch $MODPATH/module.prop
echo "id=clash_premium" > $MODPATH/module.prop
echo "name=Clash Premium For Magisk" >> $MODPATH/module.prop
echo "version=${download_version}" >> $MODPATH/module.prop
echo "versionCode=$(date +%Y%m%d)" >> $MODPATH/module.prop
echo "author=shell scripts by kalasutra. clash premium by Dreamacro" >> $MODPATH/module.prop
echo "description=clash premium with service scripts for Android.Only supports tun mode transparent proxy.Default disable ipv6." >> $MODPATH/module.prop

ui_print "- Start setting the necessary permissions."
set_perm_recursive $MODPATH 0 0 0755 0644
set_perm  $MODPATH/service.sh    0  0  0755
set_perm  $MODPATH/uninstall.sh    0  0  0755
set_perm  $MODPATH/system/bin/clash 0 ${sdcard_rw_id} 6755
set_perm  $MODPATH/system/bin/clash_control 0 0 0755
set_perm  $MODPATH/clash_service.sh 0 0 0755
set_perm  $MODPATH/clash_tproxy.sh 0 0 0755

if [ -f ${MODPATH}/system/bin/clash ] ; then
    ui_print "- The installation is normal, please enjoy."
else
    abort "- The installation seems abnormal, please test."
fi