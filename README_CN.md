# Clash Premium Magisk 模块

这是一个clash premium for magisk模块, 已经内置clash premium内核。

## 模块包含项目

* [clash premium](<https://github.com/Dreamacro/clash/releases/tag/premium>)
* [magisk-module-installer](<https://github.com/topjohnwu/magisk-module-installer>)
* [magisk-disable-ipv6](<https://github.com/njallam/magisk-disable-ipv6>)

* clash premium 服务脚本和Android透明代理脚本.

## 安装

你可以打包下载zip文件，然后通过Magisk Manager应用程序进行安装。

## 配置文件

* clash的数据目录位于 `/sdcard/Documents/clash`。
* 请把 `config.yaml` 和 `Country.mmdb`这两个文件放置于数据目录中。
* 提示: 确保`config.yaml` 文件中存在tun字段和dns字段, 否则透明代理将不起作用。

## 使用方法

### 启动/停止服务

* 在termux下使用 `clash_control`命令, 可用参数有 `enable|disable|restart`, 例如，用于启动服务的命令为 `clash_control enable`。

* 建议搭配 [Dashboard App](<https://github.com/Dashboard2/Dashboard>) 使用。

### 黑白名单使用方法

* 如果您希望使用白名单功能，即特定应用程序具有透明代理（有关更多详细信息，请参见透明代理部分），只需在`/sdcard/Documents/clash/appid.list`文件中写下这些应用程序的uid。
* 每个应用程序的uid应以空格分隔，或每行仅写一个应用程序的uid。（对于Android应用程序的uid, 您可以在`/data/system/packages.list`文件中搜索应用程序的包名, 也可以借助某些APP来查看应用uid，例如Shadowsocks。）
* 如果您希望clash能够代理所有App，只需在`/sdcard/Documents/clash/appid.list`文件中写入`ALL`即可。
* 如果您希望使用黑名单功能，即不代理某些APP，请将`bypass`添加到`/sdcard/Documents/clash/appid.list`的第一行，从第二行开始写入你不希望代理的APP的uid。
* 如果`/sdcard/Documents/clash/appid.list`文件为空白，则clash服务正常启动后，透明代理不会生效。

## 透明代理

### What is "Transparent proxy"

> "A 'transparent proxy' is a proxy that does not modify the request or response beyond what is required for proxy authentication and identification". "A 'non-transparent proxy' is a proxy that modifies the request or response in order to provide some added service to the user agent, such as group annotation services, media type transformation, protocol reduction, or anonymity filtering".
>
> ​                                -- [Transparent proxy explanation in Wikipedia](<https://en.wikipedia.org/wiki/Proxy_server#Transparent_proxy>)

## Uninstall

* 通过Magisk Manager卸载.
