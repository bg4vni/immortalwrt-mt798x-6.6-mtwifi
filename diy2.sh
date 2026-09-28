#!/bin/bash
set -e

echo "[diy2] 开始替换 xray-core 和 v2ray-geodata"

# 1. 删除旧版 (带目录判断写法)
[ -d feeds/packages/lang/golang ] && rm -rf feeds/packages/lang/golang
[ -d feeds/packages/net/xray-core ] && rm -rf feeds/packages/net/xray-core
[ -d feeds/packages/net/v2ray-geodata ] && rm -rf feeds/packages/net/v2ray-geodata

# 2. 稀疏拉取 openwrt/packages 的整个 lang/golang 模块
git clone --depth 1 --filter=blob:none --sparse \
  https://github.com/openwrt/packages.git temp_pkgs
cd temp_pkgs
git sparse-checkout set lang/golang
cd ..
# 正确方式：整体替换 lang/golang 目录，确保 golang-package.mk 等核心规则文件一并更新
mv -f temp_pkgs/lang/golang feeds/packages/lang/golang
rm -rf temp_pkgs

# 3. 稀疏拉取 PassWall 的 xray-core 和 v2ray-geodata
git clone --depth 1 --filter=blob:none --sparse \
  https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git temp_passwall
cd temp_passwall
git sparse-checkout set xray-core v2ray-geodata
cd ..

#  移动到 feeds 源码目录完成替换
mv -f temp_passwall/xray-core feeds/packages/net/xray-core
mv -f temp_passwall/v2ray-geodata feeds/packages/net/v2ray-geodata

#  清理临时目录
rm -rf temp_passwall

# 5. 【关键一步】重新刷新 feeds 索引并安装软链接
echo "[diy2] 正在刷新 feeds 索引..."
./scripts/feeds update -i -p packages
./scripts/feeds install -p packages -f golang xray-core v2ray-geodata

# 6. 打印版本号确认
GO_VER=$(grep -m1 'GO_VERSION:=' feeds/packages/lang/golang/golang-values.mk 2>/dev/null | cut -d'=' -f2 | tr -d ' ' || echo "最新版")
echo "[diy2] ========================================"
echo "[diy2] golang: $GO_VER"
echo "[diy2] xray-core: $(grep -m1 PKG_VERSION feeds/packages/net/xray-core/Makefile)"
echo "[diy2] v2ray-geodata: $(grep -m1 PKG_VERSION feeds/packages/net/v2ray-geodata/Makefile)"
echo "[diy2] 替换完成"
