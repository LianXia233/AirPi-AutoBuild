#!/bin/bash
set -e

echo "=== Start DIY Script ==="

# 更新 feeds
./scripts/feeds update -a
./scripts/feeds install -a

# 函数：更新或安装指定插件
UPDATE_PACKAGE() {
    local PKG_NAME=$1
    local PKG_REPO=$2
    local PKG_BRANCH=$3
    local PKG_SPECIAL=$4
    local REPO_NAME=${PKG_REPO#*/}

    # 删除本地可能存在的同名包
    find ../feeds/luci/ ../feeds/packages/ -maxdepth 3 -type d -iname "*$PKG_NAME*" -exec rm -rf {} \;

    # 克隆 GitHub 仓库
    git clone --depth=1 --single-branch --branch $PKG_BRANCH "https://github.com/$PKG_REPO.git"

    # 如果是 pkg，则从大杂烩中提取插件目录
    if [[ $PKG_SPECIAL == "pkg" ]]; then
        find ./$REPO_NAME/*/ -maxdepth 3 -type d -iname "*$PKG_NAME*" -prune -exec cp -rf {} ./ \;
        rm -rf ./$REPO_NAME/
    fi
}

# =======================
# 添加插件
# =======================

# QModem
UPDATE_PACKAGE "qmodem" "FUjr/QModem" "main" "pkg"

# HomeProxy
UPDATE_PACKAGE "homeproxy" "immortalwrt/homeproxy" "main" "pkg"

# modem_feeds
if ! grep -q "src-git modem" feeds.conf.default; then
    echo 'src-git modem https://github.com/FUjr/modem_feeds.git;main' >> feeds.conf.default
fi
./scripts/feeds update modem
./scripts/feeds install -a -p modem
./scripts/feeds install -a -f -p modem

echo "=== DIY Script Finished ==="
