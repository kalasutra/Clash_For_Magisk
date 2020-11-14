# override the official Magisk module installer
SKIPUNZIP=1
ASH_STANDALONE=1

wait_count=0
download_link=""
version_status=""
download_command=""
download_version=""
sdcard_rw_id="1015"
command_judgment="true"
clash_data_dir="/sdcard/Documents/clash"
download_location="${MODPATH}/system/bin/clash.gz"
appid_file="${clash_data_dir}/appid.list"

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

ui_print "- Select installation mode -"
ui_print "- Vol Up = Local mod"
ui_print "- Vol Down = Online mod"
while true ; do
    getevent -lc 1 2>&1 | grep KEY_VOLUME > $TMPDIR/events
    if $(cat $TMPDIR/events | grep -q KEY_VOLUMEUP) ; then
        mod="local"
        break
    elif $(cat $TMPDIR/events | grep -q KEY_VOLUMEDOWN) ; then
        mod="online"
        ui_print "- Please select a version."
        ui_print "- Vol + = stable"
        ui_print "- Vol - = canary"
        while true ; do
           getevent -lc 1 2>&1 | grep KEY_VOLUME > $TMPDIR/events
           if $(cat $TMPDIR/events | grep -q KEY_VOLUMEUP) ; then
               version_status="stable"
               download_link="https://github.com/Dreamacro/clash/releases"
               break
           elif $(cat $TMPDIR/events | grep -q KEY_VOLUMEDOWN) ; then
               version_status="canary"
               download_link="https://tmpclashpremiumbindary.cf"
               break
           fi
        done
        break
    fi
done

download_stable_archive() {
    if [ "${command_judgment}" == "true" ] ; then
        download_version=$(curl -k -s ${download_link}/tag/premium | grep -o "clash-linux-"$1"-*.*.*.*.gz"| head -n1)
        ${download_command} ${download_link}/download/premium/${download_version}
    else
        touch ${TMPDIR}/version
        wget --no-check-certificate -O ${TMPDIR}/version ${download_link}/tag/premium
        download_version=$(cat ${TMPDIR}/version | grep -o "clash-linux-"$1"-*.*.*.*.gz"| head -n1)
        ${download_command} ${download_link}/download/premium/${download_version}
    fi
}

download_stable_version() {
    case "${ARCH}" in
        arm)
            download_stable_archive armv7
            ;;
        arm64)
            download_stable_archive armv8
            ;;
        x86)
            download_stable_archive 386
            ;;
        x64)
            download_stable_archive amd64
            ;;
    esac
}

download_canary_archive() {
    if [ "${command_judgment}" == "true" ] ; then
        download_version=$(curl -k -s ${download_link} | grep -o clash-linux-"$1"-*.*.*.*.gz | awk -F '>' '{print $2}')
        ${download_command} ${download_link}/${download_version}
    else
        touch ${TMPDIR}/version
        wget --no-check-certificate -O ${TMPDIR}/version ${download_link}
        download_version=$(cat ${TMPDIR}/version | grep -o clash-linux-"$1"-*.*.*.*.gz | awk -F '>' '{print $2}')
        ${download_command} ${download_link}/${download_version}
    fi
}

download_canary_version() {
    case "${ARCH}" in
        arm)
            download_canary_archive armv7
            ;;
        arm64)
            download_canary_archive armv8
            ;;
        x86)
            download_canary_archive 386
            ;;
        x64)
            download_canary_archive amd64
            ;;
    esac
}

local_mod() {
    case "${ARCH}" in
      arm)
          mv -f $MODPATH/clash/clash-linux-armv7 $MODPATH/system/bin/clash
          ;;
      arm64)
          mv -f $MODPATH/clash/clash-linux-armv8 $MODPATH/system/bin/clash
          ;;
      x86)
          mv -f $MODPATH/clash/clash-linux-386 $MODPATH/system/bin/clash
          ;;
      x64)
          mv -f $MODPATH/clash/clash-linux-amd64 $MODPATH/system/bin/clash
          ;;
          esac
}

mkdir -p $MODPATH/system/bin
mkdir -p ${clash_data_dir}

if [ ! -f ${appid_file} ] ; then
    ui_print "- Set the default mode to global."
    echo "ALL" > ${appid_file}
fi

ui_print "- Start installing the necessary files."
unzip -j -o "${ZIPFILE}" -x 'META-INF/*' -d $MODPATH >&2
tar -xf $MODPATH/clash.tar.xz -C $MODPATH >&2
mv $MODPATH/clash_control.sh $MODPATH/system/bin/clash_control

if [ "${mod}" == "local" ] ; then
    local_mod
elif [ "${mod}" == "online" ] ; then
    ui_print "- Start downloading the kernel file."
    until [ -f ${download_location} ] && $(gzip -d ${download_location}) ; do
        if [ "${version_status}" == "stable" ] ; then
            download_stable_version
        elif [ "${version_status}" == "canary" ] ; then
            download_canary_version
        fi
        wait_count=$((${wait_count} + 1))
        if [ ${wait_count} -ge 6 ] ; then
            abort "! Download failed. Please keep the log and hand it to the developer to solve it."
        fi
    done
else
    abort "- Selection error."
fi

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

rm -rf $MODPATH/clash.tar.xz
rm -rf $MODPATH/clash
