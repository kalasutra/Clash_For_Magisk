#!/system/bin/sh

# override the official Magisk module installer
SKIPUNZIP=1

if [ $BOOTMODE ! = true ]; then
   abort "! Please install in Magisk Manager"
fi

if $(curl -V > /dev/null 2>&1) ; then
     online="true"
else
     ui_print "- Your device does not have a curl command." 
     ui_print "- Use local official core."
     online="false"
     tar -xf $MODPATH/clash.tar.xz -C $TMPDIR >&2
     case "${ARCH}" in
     arm)
        mv $TMPDIR/clash/clash-linux-armv7 $MODPATH/system/bin/clash
        ;;
     arm64)
        mv $TMPDIR/clash/clash-linux-armv8 $MODPATH/system/bin/clash
        ;;
     x86_64)
        mv $TMPDIR/clash/clash-linux-amd64 $MODPATH/system/bin/clash
        ;;
     esac
fi

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

if [ "${online}" = "true" ]; then
   for i in $(seq 1 10); do
   case "${ARCH}" in
   arm)
      latest_version=`curl -k -s ${preview_clash_link} | grep -o clash-linux-armv7-*.*.*.*.gz | awk -F '>' '{print $2}'`
      download_clash_link="${preview_clash_link}/${latest_version}"
      ;;
   arm64)
      latest_version=`curl -k -s ${preview_clash_link} | grep -o clash-linux-armv8-*.*.*.*.gz | awk -F '>' '{print $2}'`
      download_clash_link="${preview_clash_link}/${latest_version}"
      ;;
   x86_64)
      latest_version=`curl -k -s ${preview_clash_link} | grep -o clash-linux-amd64-*.*.*.*.gz | awk -F '>' '{print $2}'`
      download_clash_link="${preview_clash_link}/${latest_version}"
      ;;
   esac
   if curl "${download_clash_link}" -k -L -o "$MODPATH/clash.gz" >&2;then
   break;
   fi
   sleep 2
   if [[ $i == 5 ]]; then
      abort "- Error: Download Clash core failed."
   fi
   done
   ui_print "- Download latest Clash core ${latest_version}"

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
   echo "versionCode=$(date +%Y%m%d)" >> $MODPATH/module.prop
   echo "author=shell scripts by kalasutra. clash premium by Dreamacro" >> $MODPATH/module.prop
   echo "description=clash premium with service scripts for Android.Only supports tun mode transparent proxy.Default disable ipv6." >> $MODPATH/module.prop
fi

ui_print "- Set permissions"
set_perm_recursive $MODPATH 0 0 0755 0644
set_perm  $MODPATH/service.sh    0  0  0755
set_perm  $MODPATH/uninstall.sh    0  0  0755
set_perm  $MODPATH/system/bin/clash 0 ${sdcard_rw_id} 6755
set_perm  $MODPATH/system/bin/clash_control 0 0 0755
set_perm  $MODPATH/clash_service.sh 0 0 0755
set_perm  $MODPATH/clash_tproxy.sh 0 0 0755
