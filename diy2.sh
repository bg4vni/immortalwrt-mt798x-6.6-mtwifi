#!/bin/bash
set -e

echo "[diy2] 开始替换 xray-core 和 v2ray-geodata"

# 1. 删除旧版
[ -d feeds/packages/net/xray-core ] && rm -rf feeds/packages/net/xray-core
[ -d feeds/packages/net/v2ray-geodata ] && rm -rf feeds/packages/net/v2ray-geodata

# 2. 稀疏抽离最新版
git clone --depth 1 --filter=blob:none --sparse \
  https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git temp_passwall
cd temp_passwall
git sparse-checkout set xray-core v2ray-geodata
cd ..

# 3. 移动到 feeds 源码目录完成替换
mv -f temp_passwall/xray-core feeds/packages/net/xray-core
mv -f temp_passwall/v2ray-geodata feeds/packages/net/v2ray-geodata

# 4. 清理临时目录
rm -rf temp_passwall

# 5. 打印版本号确认
echo "[diy2] xray-core: $(grep -m1 PKG_VERSION feeds/packages/net/xray-core/Makefile)"
echo "[diy2] v2ray-geodata: $(grep -m1 PKG_VERSION feeds/packages/net/v2ray-geodata/Makefile)"
echo "[diy2] 替换完成"
