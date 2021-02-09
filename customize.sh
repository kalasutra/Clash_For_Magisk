SKIPUNZIP=1

architecture=""
required_version=""
system_gid="1000"
clash_data_dir="/data/Clash"
geoip_file_path="${clash_data_dir}/Country.mmdb"
modules_dir="/data/adb/modules"
CPFM_mode_dir="${modules_dir}/clash_premium"
clash_releases_link="https://github.com/Dreamacro/clash/releases"
geoip_download_link="https://github.com/Hackl0us/GeoIP2-CN/raw/release/Country.mmdb"

if [ -d "${CPFM_mode_dir}" ] ; then
    touch ${CPFM_mode_dir}/disable && ui_print "- CPFM模块在重启后将会禁用."
fi

case "${ARCH}" in
    arm)
        ui_print "- 暂不支持"
        ;;
    arm64)
        architecture="armv8"
        ;;
esac

mkdir -p ${MODPATH}/system/bin
mkdir -p ${clash_data_dir}

if [ ! -f ${geoip_file_path} ] ; then
    ui_print "- 开始下载Country.mmdb."
    wget ${geoip_download_link} -O ${geoip_file_path}
fi

ui_print "- 开始下载Clash内核."
wget ${clash_releases_link}/latest -O ${TMPDIR}/version
required_version=$(cat ${TMPDIR}/version | grep -o "v[0-9]\.[0-9]\.[0-9]" | sort -u)
wget ${clash_releases_link}/download/${required_version}/clash-linux-${architecture}-${required_version}.gz -O ${MODPATH}/system/bin/clash.gz

cd ${MODPATH}/system/bin && gzip -d clash.gz
unzip -o "${ZIPFILE}" -x 'META-INF/*' -d $MODPATH >&2

set_perm_recursive ${MODPATH} 0 0 0755 0644
set_perm_recursive ${MODPATH}/scripts 0 ${system_gid} 0755 0755
set_perm_recursive ${clash_data_dir} 0 ${system_gid} 0755 0644
set_perm  ${MODPATH}/system/bin/clash  0  ${system_gid}  6755