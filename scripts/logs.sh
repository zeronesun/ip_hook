#!/bin/bash
# ip_hook 模块日志查看脚本
# 优化：实时日志、过滤、高亮

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 显示使用帮助
usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -f, --follow     实时跟踪日志 (类似 tail -f)"
    echo "  -d, --dropped    只显示被丢弃的数据包"
    echo "  -n NUM           显示最后 NUM 行 (默认: 50)"
    echo "  -h, --help       显示此帮助"
    exit 0
}

# 默认参数
FOLLOW=false
DROPPED_ONLY=false
NUM_LINES=50

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--follow)
            FOLLOW=true
            shift
            ;;
        -d|--dropped)
            DROPPED_ONLY=true
            shift
            ;;
        -n)
            NUM_LINES="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "未知选项: $1"
            usage
            ;;
    esac
done

echo -e "${BLUE}=== ip_hook 模块日志 ===${NC}\n"

# 构建过滤命令
if [ "$DROPPED_ONLY" = true ]; then
    FILTER="droped"
    echo -e "${YELLOW}只显示被丢弃的数据包...${NC}\n"
else
    FILTER="ip_hook|check_ip|packet_|droped"
    echo -e "${YELLOW}显示所有相关日志...${NC}\n"
fi

if [ "$FOLLOW" = true ]; then
    # 实时跟踪
    echo -e "${GREEN}实时跟踪日志 (Ctrl+C 退出)...${NC}\n"
    dmesg -w | grep --line-buffered -E "$FILTER" | \
        sed -e "s/droped/${RED}\&${NC}/g" \
            -e "s/ACCEPT/${GREEN}\&${NC}/g" \
            -e "s/packet_/${YELLOW}\&${NC}/g"
else
    # 显示历史日志
    echo -e "${YELLOW}最近 $NUM_LINES 行日志:${NC}\n"
    dmesg | grep -E "$FILTER" | tail -n "$NUM_LINES" | \
        sed -e "s/droped/${RED}\&${NC}/g" \
            -e "s/ACCEPT/${GREEN}\&${NC}/g" \
            -e "s/packet_/${YELLOW}\&${NC}/g" | \
        nl -w2 -s'.  '

    # 统计
    TOTAL=$(dmesg | grep -cE "$FILTER" || echo "0")
    DROPPED=$(dmesg | grep -c "droped" || echo "0")
    echo -e "\n${YELLOW}统计: 总计 $TOTAL 条，丢弃 $DROPPed 条${NC}"
fi
