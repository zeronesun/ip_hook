#!/bin/bash
# 高级日志监控脚本
# 实时显示丢包统计、连接数、流量

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     ip_hook 实时监控面板${NC}             ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}\n"

# 获取过滤的IP
FILTERED_IP=$(grep "denied_ip" "$(dirname "$0")/../ip_setting.h" | cut -d'"' -f2)

while true; do
    # 清屏并显示时间
    clear
    echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     ip_hook 实时监控面板${NC}             ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
    echo -e "${CYAN}时间: $(date '+%Y-%m-%d %H:%M:%S')${NC}\n"

    # 模块状态
    if lsmod | grep -q "^ip_hook "; then
        echo -e "${GREEN}模块状态: ✓ 已加载${NC}"
    else
        echo -e "${RED}模块状态: ✗ 未加载${NC}"
    fi

    # 配置信息
    echo -e "${YELLOW}过滤IP: $FILTERED_IP${NC}"
    echo -e "${YELLOW}内核版本: $(uname -r)${NC}\n"

    # 统计信息
    TOTAL_LOGS=$(dmesg 2>/dev/null | grep -cE "packet_in|packet_out|droped" || echo "0")
    DROPPED=$(dmesg 2>/dev/null | grep -c "droped" || echo "0")
    ACCEPTED=$((TOTAL_LOGS - DROPPED))

    echo -e "${BLUE}══════ 数据包统计 ══════${NC}"
    echo -e "${GREEN}已接受: $ACCEPTED${NC}"
    echo -e "${RED}已丢弃: $DROPPED${NC}"
    echo -e "${YELLOW}总计:   $TOTAL_LOGS${NC}\n"

    # 最近的丢弃记录
    echo -e "${BLUE}══════ 最近丢弃记录 (最近5条) ══════${NC}"
    dmesg 2>/dev/null | grep "droped" | tail -5 | nl -w2 -s'.  ' | \
        sed "s/\(.*droped\)/${RED}\1${NC}/" || echo -e "${YELLOW}无丢弃记录${NC}"

    echo -e "\n${BLUE}══════ 最新日志 (最近10条) ══════${NC}"
    dmesg 2>/dev/null | grep -E "packet_in|packet_out|droped" | tail -10 | nl -w2 -s'.  ' || echo -e "${YELLOW}无日志记录${NC}"

    echo -e "\n${CYAN}[按 Ctrl+C 退出] 刷新间隔: 2秒${NC}"
    sleep 2
done
