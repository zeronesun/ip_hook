#!/bin/bash
# ip_hook 模块状态检查脚本

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== ip_hook 模块状态 ===${NC}\n"

# 检查模块是否加载
if lsmod | grep -q "^ip_hook "; then
    echo -e "${GREEN}● 模块状态: 已加载${NC}"
    echo -e "${YELLOW}模块信息:${NC}"
    lsmod | grep ip_hook
else
    echo -e "${RED}○ 模块状态: 未加载${NC}"
    exit 0
fi

# 显示模块详细信息
echo -e "\n${YELLOW}=== 模块详细信息 ===${NC}"
modinfo ip_hook 2>/dev/null || echo "无法获取模块信息"

# 显示过滤的IP配置
echo -e "\n${YELLOW}=== 当前过滤配置 ===${NC}"
grep "denied_ip" "$(dirname "$0")/../ip_setting.h" 2>/dev/null || echo "无法读取配置"

# 显示最近的内核日志
echo -e "\n${YELLOW}=== 最近的内核日志 (过滤相关) ===${NC}"
dmesg | grep -i "ip_hook\|check_ip\|packet_\|droped" | tail -20

# 统计已丢弃的数据包
DROP_COUNT=$(dmesg | grep -c "droped" 2>/dev/null || echo "0")
echo -e "\n${YELLOW}=== 统计信息 ===${NC}"
echo -e "已丢弃数据包数: ${RED}$DROP_COUNT${NC}"
echo -e "内核版本: $(uname -r)"

# 显示模块依赖
echo -e "\n${YELLOW}=== 模块依赖 ===${NC}"
lsmod | grep "^ip_hook " || true
