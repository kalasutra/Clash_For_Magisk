#!/system/bin/sh

# override the official Magisk module installer
SKIPUNZIP=1

if [ "${ARCH}" = "arm64" ] ; then
    ui_print "The module supports ${ARCH} architecture, continue to install."
else
    abort "The module does not support ${ARCH} architecture, stop install."
fi

unzip -j -o "${ZIPFILE}" 'service.sh' -d $MODPATH >&2
unzip -j -o "${ZIPFILE}" 'uninstall.sh' -d $MODPATH >&2
unzip -j -o "${ZIPFILE}" 'module.prop' -d $MODPATH >&2

set_perm_recursive $MODPATH 0 0 0755 0644
set_perm  $MODPATH/service.sh    0  0  0755
set_perm  $MODPATH/uninstall.sh    0  0  0755