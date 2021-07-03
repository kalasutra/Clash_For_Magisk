#!/bin/env bash

cd ./clash
GOARCH=arm64 GOOS=android CGO_ENABLED=0 go build -trimpath -ldflags "-X 'github.com/Dreamacro/clash/constant.Version=$(git describe --tags)' -X 'github.com/Dreamacro/clash/constant.BuildTime=$(date -u)' -w -s -buildid="

zip -r Clash_For_Magisk.zip binary cacert.pem clash.config customize.sh META-INF scripts template module.prop service.sh uninstall.sh clash-dashboard/dist

yarn install
yarn build
# 这是一个备份,预计以后写成脚本