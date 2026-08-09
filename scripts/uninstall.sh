#!/bin/bash
# ip_hook 模块卸载脚本

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}=== ip_hook 模块卸载 ===${NC}"

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}错误: 请使用 sudo 运行此脚本${NC}"
    exit 1
fi

# 检查模块是否已加载
if ! lsmod | grep -q "^ip_hook "; then
    echo -e "${YELLOW}模块未加载${NC}"
    exit 0
fi

# 卸载模块
echo -e "${YELLOW}正在卸载模块...${NC}"
rmmod ip_hook

if ! lsmod | grep -q "^ip_hook "; then
    echo -e "${GREEN}✓ 模块卸载成功${NC}"
else
    echo -e "${RED}错误: 模块卸载失败${NC}"
    exit 1
fi
