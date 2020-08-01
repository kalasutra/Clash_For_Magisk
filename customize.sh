#!/system/bin/sh

# override the official Magisk module installer
SKIPUNZIP=1

if [ $BOOTMODE = true ] ; then
    if [ "${ARCH}" = "arm64" ] ; then
        ui_print "The module supports ${ARCH} architecture, continue to install."
    else
        abort "The module does not support ${ARCH} architecture, stop install."
    fi
else
    abort "! Please install in Magisk Manager"
fi

sdcard_rw_id="1015"
clash_data_dir="/sdcard/Documents/clash"
clash_link="https://tmpclashpremiumbindary.cf"
latest_version=`curl -k -s https://tmpclashpremiumbindary.cf | grep -o clash-linux-armv8-*.*.*.*.gz | awk -F '>' '{print $2}'`

mkdir -p $MODPATH/system/bin
mkdir -p ${clash_data_dir}

unzip -j -o "${ZIPFILE}" 'clash' -d $MODPATH/system/bin >&2
unzip -j -o "${ZIPFILE}" 'clash_control' -d $MODPATH/system/bin >&2
unzip -j -o "${ZIPFILE}" 'clash_service.sh' -d $MODPATH >&2
unzip -j -o "${ZIPFILE}" 'clash_tproxy.sh' -d $MODPATH >&2
unzip -j -o "${ZIPFILE}" 'service.sh' -d $MODPATH >&2
unzip -j -o "${ZIPFILE}" 'uninstall.sh' -d $MODPATH >&2
unzip -j -o "${ZIPFILE}" 'module.prop' -d $MODPATH >&2

curl "${clash_link}/${latest_version}" -k -L -o "$MODPATH/clash.gz" >&2
if [ "$?" != "0" ] ; then
    abort "Error: Download Clash core failed."
fi
ui_print "Extracting Clash core file"
gzip -d $MODPATH/clash.gz
mv $MODPATH/clash $MODPATH/system/bin

set_perm_recursive $MODPATH 0 0 0755 0644
set_perm  $MODPATH/service.sh    0  0  0755
set_perm  $MODPATH/uninstall.sh    0  0  0755
set_perm  $MODPATH/system/bin/clash 0 ${sdcard_rw_id} 6755
set_perm  $MODPATH/system/bin/clash_control 0 0 0755
set_perm  $MODPATH/clash_service.sh 0 0 0755
set_perm  $MODPATH/clash_tproxy.sh 0 0 0755
