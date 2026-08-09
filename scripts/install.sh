#!/bin/bash
# ip_hook 模块安装脚本
# 优化：环境检查、权限验证、错误处理

set -e  # 任何错误立即退出

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== ip_hook 模块安装 ===${NC}"

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}错误: 请使用 sudo 运行此脚本${NC}"
    echo "Usage: sudo ./scripts/install.sh"
    exit 1
fi

# 检查内核版本兼容性
KERNEL_VERSION=$(uname -r)
echo -e "${YELLOW}当前内核版本: $KERNEL_VERSION${NC}"

# 检查内核头文件
if [ ! -d "/lib/modules/$(uname -r)/build" ]; then
    echo -e "${RED}错误: 内核头文件未安装${NC}"
    echo "请先安装: sudo apt-get install linux-headers-$(uname -r)"
    exit 1
fi

# 编译模块
echo -e "${YELLOW}正在编译模块...${NC}"
cd "$(dirname "$0")/.."
make clean > /dev/null 2>&1 || true
make

if [ ! -f "ip_hook.ko" ]; then
    echo -e "${RED}错误: 编译失败，找不到 ip_hook.ko${NC}"
    exit 1
fi

# 检查模块是否已加载
if lsmod | grep -q "^ip_hook "; then
    echo -e "${YELLOW}模块已加载，正在卸载...${NC}"
    rmmod ip_hook
fi

# 加载模块
echo -e "${YELLOW}正在加载模块...${NC}"
insmod ip_hook.ko

if lsmod | grep -q "^ip_hook "; then
    echo -e "${GREEN}✓ 模块加载成功！${NC}"

    # 显示模块信息
    echo -e "\n${YELLOW}=== 模块信息 ===${NC}"
    modinfo ip_hook

    # 显示最近日志
    echo -e "\n${YELLOW}=== 内核日志 (最后10行) ===${NC}"
    dmesg | tail -10 | grep -i "ip_hook\|check_ip"

    echo -e "\n${GREEN}安装完成！使用 ./scripts/status.sh 查看状态，./scripts/logs.sh 查看日志${NC}"
else
    echo -e "${RED}错误: 模块加载失败${NC}"
    echo "查看详细错误: dmesg | tail -20"
    exit 1
fi
