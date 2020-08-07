#!/system/bin/sh

# override the official Magisk module installer
SKIPUNZIP=1

sdcard_rw_id="1015"
clash_data_dir="/sdcard/Documents/clash"
pid_file="${clash_data_dir}/clash.pid"
download_premium_link="https://github.com/Dreamacro/clash/releases/download/premium"
download_command="wget --no-check-certificate -O ${MODPATH}/system/bin/clash.gz"

mkdir -p $MODPATH/system/bin
mkdir -p ${clash_data_dir}

download_premium() {
    case "${ARCH}" in
        arm)
            $download_command ${download_premium_link}/clash-linux-armv7-2020.06.27.gz
            ;;
        arm64)
            $download_command ${download_premium_link}/clash-linux-armv8-2020.06.27.gz
            ;;
        x86)
            $download_command ${download_premium_link}/clash-linux-386-2020.06.27.gz
            ;;
        x64)
            $download_command ${download_premium_link}/clash-linux-amd64-2020.06.27.gz
            ;;
    esac
}

download_premium
gzip -d ${MODPATH}/system/bin/clash.gz
unzip -j -o "${ZIPFILE}" 'clash_control.sh' -d $MODPATH/system/bin >&2
unzip -j -o "${ZIPFILE}" 'clash_service.sh' -d $MODPATH >&2
unzip -j -o "${ZIPFILE}" 'clash_tproxy.sh' -d $MODPATH >&2
unzip -j -o "${ZIPFILE}" 'service.sh' -d $MODPATH >&2
unzip -j -o "${ZIPFILE}" 'uninstall.sh' -d $MODPATH >&2
unzip -j -o "${ZIPFILE}" 'module.prop' -d $MODPATH >&2
mv $MODPATH/system/bin/clash_control.sh $MODPATH/system/bin/clash_control

set_perm_recursive $MODPATH 0 0 0755 0644
set_perm  $MODPATH/service.sh    0  0  0755
set_perm  $MODPATH/uninstall.sh    0  0  0755
set_perm  $MODPATH/system/bin/clash 0 ${sdcard_rw_id} 6755
set_perm  $MODPATH/system/bin/clash_control 0 0 0755
set_perm  $MODPATH/clash_service.sh 0 0 0755
set_perm  $MODPATH/clash_tproxy.sh 0 0 0755