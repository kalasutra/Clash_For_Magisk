#!/system/bin/sh

# override the official Magisk module installer
SKIPUNZIP=1

if [ $BOOTMODE ! = true ]; then
   abort "! Please install in Magisk Manager"
fi

find /system -name curl > $MODPATH/curl.txt
if [ -p $MODPATH/directory.txt ]; then
   ui_print "- Your device does not have a curl command." 
   ui_print "- Use local official core."
   if [ "${ARCH}" ! = "arm64" ] ; then
      abort "- Local core only support ${ARCH} architecture, stop install."
   fi
fi
rm -rf $MODPATH/curl.txt

sdcard_rw_id="1015"
clash_data_dir="/sdcard/Documents/clash"
preview_clash_link="https://tmpclashpremiumbindary.cf"

mkdir -p $MODPATH/system/bin
mkdir -p ${clash_data_dir}

unzip -j -o "${ZIPFILE}" 'clash' -d $MODPATH/system/bin >&2
unzip -j -o "${ZIPFILE}" 'clash_control' -d $MODPATH/system/bin >&2
unzip -j -o "${ZIPFILE}" 'clash_service.sh' -d $MODPATH >&2
unzip -j -o "${ZIPFILE}" 'clash_tproxy.sh' -d $MODPATH >&2
unzip -j -o "${ZIPFILE}" 'service.sh' -d $MODPATH >&2
unzip -j -o "${ZIPFILE}" 'uninstall.sh' -d $MODPATH >&2
unzip -j -o "${ZIPFILE}" 'module.prop' -d $MODPATH >&2

ui_print "- Download latest Clash core ${latest_version}"
case "${ARCH}" in
  arm)
    latest_version=`curl -k -s https://tmpclashpremiumbindary.cf | grep -o clash-linux-armv7-*.*.*.*.gz | awk -F '>' '{print $2}'`
    download_clash_link="${preview_clash_link}/${latest_version}"
    ;;
  arm64)
    latest_version=`curl -k -s https://tmpclashpremiumbindary.cf | grep -o clash-linux-armv8-*.*.*.*.gz | awk -F '>' '{print $2}'`
    download_clash_link="${preview_clash_link}/${latest_version}"
    ;;
  x86_64)
    latest_version=`curl -k -s https://tmpclashpremiumbindary.cf | grep -o clash-linux-amd64-*.*.*.*.gz | awk -F '>' '{print $2}'`
    download_clash_link="${preview_clash_link}/${latest_version}"
    ;;
esac
if [ "${latest_version}" = "" ] ; then
   abort "- Error: Connect preview Clash download link failed." 
fi
curl "${download_clash_link}" -k -L -o "$MODPATH/clash.gz" >&2
if [ "$?" != "0" ] ; then
   abort "- Error: Download Clash core failed."
fi
ui_print "- Extracting Clash core file"
gzip -d $MODPATH/clash.gz
mv $MODPATH/clash $MODPATH/system/bin

ui_print "- Generate module.prop"
rm -rf $MODPATH/module.prop
touch $MODPATH/module.prop
echo "id=clash_premium" > $MODPATH/module.prop
echo "name=Clash Premium For Magisk" >> $MODPATH/module.prop
echo -n "version=preview-" >> $MODPATH/module.prop
echo ${latest_version} >> $MODPATH/module.prop
echo "versionCode=40000" >> $MODPATH/module.prop
echo "author=shell scripts by kalasutra. clash premium by Dreamacro" >> $MODPATH/module.prop
echo "description=clash premium with service scripts for Android.Only supports tun mode transparent proxy.Default disable ipv6." >> $MODPATH/module.prop

ui_print "- Set permissions"
set_perm_recursive $MODPATH 0 0 0755 0644
set_perm  $MODPATH/service.sh    0  0  0755
set_perm  $MODPATH/uninstall.sh    0  0  0755
set_perm  $MODPATH/system/bin/clash 0 ${sdcard_rw_id} 6755
set_perm  $MODPATH/system/bin/clash_control 0 0 0755
set_perm  $MODPATH/clash_service.sh 0 0 0755
set_perm  $MODPATH/clash_tproxy.sh 0 0 0755
