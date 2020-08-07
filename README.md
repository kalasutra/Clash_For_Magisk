# Clash Premium Magisk Module

[简体中文](<https://github.com/kalasutra/Clash_Premium_For_Magisk/blob/master/README_CN.md>)

This is a clash premium module for Magisk, and includes binaries for arm,arm64,x64,x86.

## Included

* [clash premium](<https://github.com/Dreamacro/clash/releases/tag/premium>)
* [magisk-module-installer](<https://github.com/topjohnwu/magisk-module-installer>)
* [magisk-disable-ipv6](<https://github.com/njallam/magisk-disable-ipv6>)

* clash premium service script and Android transparent proxy iptables scripts.

## Install

You can download the release installer zip file and install it via the Magisk Manager App.

## Config

* The clash data directory is in `/sdcard/Documents/clash`.
* Please put the `config.yaml` file and `Country.mmdb` in the data directory.
* Tips: Ensure that the tun field and dns field exist in the `config.yaml` file, otherwise the transparent proxy will not work.

## Usage

### Manage service start / stop

* Use the `clash_control` command under andoid termux, the available parameters enable|disable|restart, for example, the command for service startup is `clash_control enable`.

* It is recommended to use [Dashboard App](<https://github.com/Dashboard2/Dashboard>) management.

### Select which App to proxy

* If you expect transparent proxy ( read Transparent proxy section for more detail ) for specific Apps, just write down these Apps' uid in file `/sdcard/Documents/clash/appid.list` .
* Each App's uid should separate by space or just one App's uid per line. ( for Android App's uid , you can search App's package name in file `/data/system/packages.list` , or you can look into some App like Shadowsocks. )
* If you expect all Apps proxy by V2Ray with transparent proxy, just write a single number `ALL` in file `/sdcard/Documents/clash/appid.list` .
* If you expect all Apps proxy by V2Ray with transparent proxy EXCEPT specific Apps, write down `bypass` at the first line then these Apps' uid separated as above in file `/sdcard/Documents/clash/appid.list`.
* Transparent proxy won't take effect until the V2Ray service start normally and file `/sdcard/Documents/clash/appid.list` is not empty.

## Transparent proxy

### What is "Transparent proxy"

> "A 'transparent proxy' is a proxy that does not modify the request or response beyond what is required for proxy authentication and identification". "A 'non-transparent proxy' is a proxy that modifies the request or response in order to provide some added service to the user agent, such as group annotation services, media type transformation, protocol reduction, or anonymity filtering".
>
> ​                                -- [Transparent proxy explanation in Wikipedia](<https://en.wikipedia.org/wiki/Proxy_server#Transparent_proxy>)

## Uninstall

* Uninstall the module via Magisk Manager App.
