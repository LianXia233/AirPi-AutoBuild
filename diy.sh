#!/bin/bash
set -e

# 更新 feeds 并添加 QModem/HomeProxy
UPDATE_PACKAGE() {
    local PKG_NAME=$1
    local PKG_REPO=$2
    local PKG_BRANCH=$3
    local PKG_SPECIAL=$4
    local REPO_NAME=${PKG_REPO#*/}

    # 删除本地可能存在的同名包
    find ../feeds/luci/ ../feeds/packages/ -maxdepth 3 -type d -iname "*$PKG_NAME*" -exec rm -rf {} \;

    # 克隆仓库
    git clone --depth=1 --single-branch --branch $PKG_BRANCH "https://github.com/$PKG_REPO.git"

    # 如果是 pkg，则从大杂烩中提取
    if [[ $PKG_SPECIAL == "pkg" ]]; then
        find ./$REPO_NAME/*/ -maxdepth 3 -type d -iname "*$PKG_NAME*" -prune -exec cp -rf {} ./ \;
        rm -rf ./$REPO_NAME/
    fi
}

# 添加插件
UPDATE_PACKAGE "qmodem" "FUjr/QModem" "main" "pkg"
UPDATE_PACKAGE "homeproxy" "immortalwrt/homeproxy" "main" "pkg"

# 更新 feeds
./scripts/feeds update -a
./scripts/feeds install -a
