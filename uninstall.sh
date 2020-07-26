#!/system/bin/sh

clash_data_dir="/sdcard/Documents/clash"

remove_clash_data_dir() {
  rm -rf ${clash_data_dir}
}

remove_clash_data_dir