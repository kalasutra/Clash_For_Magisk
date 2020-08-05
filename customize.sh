#!/system/bin/sh

# override the official Magisk module installer
SKIPUNZIP=1

if [ $BOOTMODE ! = true ]; then
   abort "! Please install in Magisk Manager"
fi

sdcard_rw_id="1015"
clash_data_dir="/sdcard/Documents/clash"
preview_clash_link="https://tmpclashpremiumbindary.cf"

#Create working directory
mkdir -p $MODPATH/system/bin
mkdir -p ${clash_data_dir}

#Extracting files
unzip -j -o "${ZIPFILE}" 'tools.tar.xz' -d $MODPATH >&2
unzip -j -o "${ZIPFILE}" 'clash.tar.xz' -d $MODPATH >&2
unzip -j -o "${ZIPFILE}" 'clash_control' -d $MODPATH/system/bin >&2
unzip -j -o "${ZIPFILE}" 'clash_service.sh' -d $MODPATH >&2
unzip -j -o "${ZIPFILE}" 'clash_tproxy.sh' -d $MODPATH >&2
unzip -j -o "${ZIPFILE}" 'service.sh' -d $MODPATH >&2
unzip -j -o "${ZIPFILE}" 'uninstall.sh' -d $MODPATH >&2
unzip -j -o "${ZIPFILE}" 'module.prop' -d $MODPATH >&2


# keycheck

tar -xf $MODPATH/tools.tar.xz -C $TMPDIR >&2
chmod -R 0755 $TMPDIR/tools
alias keycheck="$TMPDIR/tools/$ARCH32/keycheck"

keytest() {
  ui_print "- Vol Key Test"
  ui_print "   Press a Vol Key:"
  if (timeout 3 /system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $TMPDIR/events); then
    return 0
  else
    ui_print "   Try again:"
    timeout 3 keycheck
    local SEL=$?
    [ $SEL -eq 143 ] && abort "   Vol key not detected!" || return 1
  fi
}

chooseport() {
  # Original idea by chainfire @xda-developers, improved on by ianmacd @xda-developers
  #note from chainfire @xda-developers: getevent behaves weird when piped, and busybox grep likes that even less than toolbox/toybox grep
  while true; do
    /system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $TMPDIR/events
    if (`cat $TMPDIR/events 2>/dev/null | /system/bin/grep VOLUME >/dev/null`); then
      break
    fi
  done
  if (`cat $TMPDIR/events 2>/dev/null | /system/bin/grep VOLUMEUP >/dev/null`); then
    return 0
  else
    return 1
  fi
}

chooseportold() {
  # Keycheck binary by someone755 @Github, idea for code below by Zappo @xda-developers
  # Calling it first time detects previous input. Calling it second time will do what we want
  while true; do
    keycheck
    keycheck
    local SEL=$?
    if [ "$1" == "UP" ]; then
      UP=$SEL
      break
    elif [ "$1" == "DOWN" ]; then
      DOWN=$SEL
      break
    elif [ $SEL -eq $UP ]; then
      return 0
    elif [ $SEL -eq $DOWN ]; then
      return 1
    fi
  done
}

# Have user option to skip vol keys
OIFS=$IFS; IFS=\|; MID=false; NEW=false
case $(echo $(basename $ZIPFILE) | tr '[:upper:]' '[:lower:]') in
  *novk*) ui_print "- Skipping Vol Keys -";;
  *) if keytest; then
       VKSEL=chooseport
     else
       VKSEL=chooseportold
       ui_print "  ! Legacy device detected! Using old keycheck method"
       ui_print " "
       ui_print "- Vol Key Programming -"
       ui_print "  Press Vol Up Again:"
       $VKSEL "UP"
       ui_print "  Press Vol Down"
       $VKSEL "DOWN"
     fi;;
esac
IFS=$OIFS

ui_print "- Select installation mode -"
ui_print "- Vol Up = Local mod"
ui_print "- Vol Down = Online mod"
if $VKSEL; then
   ui_print "- Select Local mod."
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
else
   ui_print "- Select Online mod."
   if $(curl -V > /dev/null 2>&1) ; then
       ui_print "- Start download."
   else
       ui_print "- Your device does not have a curl command." 
       abort "- Please use local mod."
   fi
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

#Delete files
rm -rf $MODPATH/tools.tar.xz
rm -rf $MODPATH/clash.tar.xz

ui_print "- Set permissions"
set_perm_recursive $MODPATH 0 0 0755 0644
set_perm  $MODPATH/service.sh    0  0  0755
set_perm  $MODPATH/uninstall.sh    0  0  0755
set_perm  $MODPATH/system/bin/clash 0 ${sdcard_rw_id} 6755
set_perm  $MODPATH/system/bin/clash_control 0 0 0755
set_perm  $MODPATH/clash_service.sh 0 0 0755
set_perm  $MODPATH/clash_tproxy.sh 0 0 0755
