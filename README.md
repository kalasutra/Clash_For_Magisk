# Clash for Magisk

基于shell脚本控制[clash](https://github.com/Dreamacro/clash)的启动与停止以及达到某些目的,例如:tproxy的透明代理,基于uid的黑白名单功能,或者你只是想单独启动clash core进程,这些都可以.

## 注意事项

* 由于此模块只是简单的shell包装,更改以及插入代码相对容易,我不能够确保在非[本仓库](https://github.com/kalasutra/Clash_For_Magisk)下载的zip包是否有内嵌的恶意代码,也不对此进行负责,请尽量在本仓库[Releases](https://github.com/kalasutra/Clash_For_Magisk/releases)中下载,或自行下载源码打包.

* 由于[本人](https://github.com/kalasutra)写了两个版本的`clash magisk模块`,[cpfm](https://github.com/kalasutra/Clash_For_Magisk/releases/tag/Dev)和[cfm](https://github.com/kalasutra/Clash_For_Magisk)以及[Kr328](https://github.com/Kr328)的[cfm](https://github.com/Kr328/ClashForMagisk)的存在已导致版本混乱,Kr328的cfm也是Magisk官方模块仓库的版本,需注意你所下载的版本是否是你需要的版本.

* 现阶段存在两个版本的Dashborad,[Jkkoi/DashBoard](https://github.com/Jkkoi/DashBoard)需配合此仓库的cfm使用,[Dashboard2/Dashboard](https://github.com/Dashboard2/Dashboard)需配合cpfm或者Kr328的cfm使用.

* 不能承诺每次更新都不会出问题,包括不限于无法使用,请考虑好在选择是否更新,或加入telegram群进行讨论,telegram群组[Dashboard 闲聊吹水[NSFJB]](https://t.me/blowH2O).

## 安装

通过Magisk Manager安装.

## 卸载

通过Magisk Manager卸载.

## 配置

模块目录: `{magisk 安装目录}/Clash_For_Magisk`

数据目录: `/data/clash`

数据目录包含以下文件:

* `template` - 模板文件

* `config.yaml` - clash配置文件,注意: 实际使用时,`从第一行到proxies:的前一行`使用的是`template`文件的内容.

* `Country.mmdb` - geoip文件,clash需要.

* `packages.list` - 黑白名单过滤列表,填包名.

* `clash.config` - 模块配置文件.

### `clash.config`配置介绍

* `mode` -可选值: 黑名单- `blacklist`,白名单-  `whitelist`,仅启动内核- `core`.功能: 选择启动模式.

* `auto_subscription` -可选值: `false`, `true`.功能: 自动订阅开关.

* `update_interval` - 参考[crond](https://www.runoob.com/w3cnote/linux-crontab-tasks.html)教程.

* `subscription_url` -可选值: 订阅链接. 功能: 自动订阅所使用的链接.

## 使用方式

* 通过禁用与开启模块来启停clash,或者使用Dashboard软件.
