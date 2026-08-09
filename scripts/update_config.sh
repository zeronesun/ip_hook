#!/bin/bash
# ip_hook 配置更新脚本
# 优化：不修改源代码，通过替换编译后的 .ko 文件中的字符串

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_help() {
    echo "Usage: $0 <IP_ADDRESS>"
    echo "Example: $0 192.168.0.100"
    echo ""
    echo "此脚本会更新编译后的 ip_hook.ko 模块中的过滤IP地址"
    echo "然后提示你重新加载模块"
    exit 0
}

# 参数检查
if [ $# -ne 1 ]; then
    show_help
fi

NEW_IP="$1"

# 验证IP格式
if ! [[ "$NEW_IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${RED}错误: 无效的IP地址格式${NC}"
    exit 1
fi

echo -e "${BLUE}=== ip_hook 配置更新 ===${NC}\n"

# 检查当前配置
CURRENT_IP=$(grep "denied_ip" "$(dirname "$0")/../ip_setting.h" | cut -d'"' -f2 || echo "未知")
echo -e "${YELLOW}当前配置: $CURRENT_IP${NC}"
echo -e "${YELLOW}新配置:   $NEW_IP${NC}\n"

# 检查 .ko 文件是否存在
KO_FILE="$(dirname "$0")/../ip_hook.ko"
if [ ! -f "$KO_FILE" ]; then
    echo -e "${RED}错误: 找不到 ip_hook.ko，请先编译${NC}"
    echo "运行: cd .. && make"
    exit 1
fi

# 备份原文件
cp "$KO_FILE" "${KO_FILE}.backup"
echo -e "${GREEN}✓ 已备份原模块到 ip_hook.ko.backup${NC}"

# 查找并替换IP字符串
# 注意：这种方法有限制 - 新IP必须是20字节以内的字符串（192.168.0.889等长IP会失败）
CURRENT_STRING=$(strings "$KO_FILE" | grep -E "^([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)$" | head -1)

if [ -z "$CURRENT_STRING" ]; then
    echo -e "${RED}错误: 在模块中找不到IP配置字符串${NC}"
    exit 1
fi

# 检查长度兼容性
if [ ${#NEW_IP} -gt ${#CURRENT_STRING} ]; then
    echo -e "${YELLOW}警告: 新IP长度 ${#NEW_IP} 超过原IP长度 ${#CURRENT_STRING}${NC}"
    echo -e "${YELLOW}需要重新编译源代码${NC}"
    exit 1
fi

# 替换字符串（需要用空格填充新IP以匹配原长度）
NEW_STRING=$(printf "%-${#CURRENT_STRING}s" "$NEW_IP")

echo -e "${YELLOW}正在替换: '$CURRENT_STRING' → '$NEW_IP'${NC}"

# 原子替换
sed -i.bak "s/${CURRENT_STRING}/${NEW_IP}/g" "$KO_FILE"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ 配置更新成功！${NC}"
    echo -e "\n${YELLOW}下一步操作:${NC}"
    echo -e "  sudo rmmod ip_hook && sudo insmod ip_hook.ko"
    echo -e "  或者运行: sudo ./scripts/install.sh"
else
    echo -e "${RED}错误: 配置更新失败${NC}"
    mv "${KO_FILE}.backup" "$KO_FILE"
    exit 1
fi

rm -f "${KO_FILE}.backup"
