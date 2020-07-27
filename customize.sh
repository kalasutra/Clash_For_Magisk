#!/system/bin/sh

# override the official Magisk module installer
SKIPUNZIP=1

if [ "${ARCH}" = "arm64" ] ; then
    ui_print "The module supports ${ARCH} architecture, continue to install."
else
    abort "The module does not support ${ARCH} architecture, stop install."
fi

sdcard_rw_id="1015"
clash_data_dir="/sdcard/Documents/clash"

mkdir -p $MODPATH/system/bin
mkdir -p ${clash_data_dir}

unzip -j -o "${ZIPFILE}" 'clash' -d $MODPATH/system/bin >&2
unzip -j -o "${ZIPFILE}" 'clash_control' -d $MODPATH/system/bin >&2
unzip -j -o "${ZIPFILE}" 'clash_service.sh' -d $MODPATH >&2
unzip -j -o "${ZIPFILE}" 'clash_tproxy.sh' -d $MODPATH >&2
unzip -j -o "${ZIPFILE}" 'service.sh' -d $MODPATH >&2
unzip -j -o "${ZIPFILE}" 'uninstall.sh' -d $MODPATH >&2
unzip -j -o "${ZIPFILE}" 'module.prop' -d $MODPATH >&2

set_perm_recursive $MODPATH 0 0 0755 0644
set_perm  $MODPATH/service.sh    0  0  0755
set_perm  $MODPATH/uninstall.sh    0  0  0755
set_perm  $MODPATH/system/bin/clash 0 ${sdcard_rw_id} 6755
set_perm  $MODPATH/system/bin/clash_control 0 0 0755
set_perm  $MODPATH/clash_service.sh 0 0 0755
set_perm  $MODPATH/clash_tproxy.sh 0 0 0755