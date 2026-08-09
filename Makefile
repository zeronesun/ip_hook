# ================================================
# 优化的 ip_hook Makefile
# 增强功能：安装时检查、自动备份、详细日志
# ================================================

target = ip_hook
obj-m := $(target).o
KERNEL_DIR := /lib/modules/$(shell uname -r)/build
PWD := $(shell pwd)

# 颜色定义
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m

# 版本信息（自动）
VERSION := $(shell git describe --tags --always 2>/dev/null || echo "unknown")
BUILD_TIME := $(shell date '+%Y-%m-%d %H:%M:%S')
BUILD_USER := $(shell whoami)

.PHONY: default install uninstall clean help check info backup

# 默认目标
default:
	@echo -e "$(GREEN)=== 编译 ip_hook 模块 ===$(NC)"
	@$(MAKE) -C $(KERNEL_DIR) M=$(PWD) modules
	@echo -e "$(GREEN)=== 编译完成 ===$(NC)"
	@echo -e "$(BLUE)构建信息:$(NC)"
	@echo -e "  版本: $(VERSION)"
	@echo -e "  时间: $(BUILD_TIME)"
	@echo -e "  用户: $(BUILD_USER)"
	@echo -e "$(YELLOW)下一步: sudo make install$(NC)"

# 安装目标（使用脚本）
install: backup
	@echo -e "$(BLUE)=== 检查权限 ===$(NC)"
	@if [ "$$(id -u)" -ne 0 ]; then \
		echo -e "$(RED)错误: 需要 sudo 权限$(NC)"; \
		exit 1; \
	fi
	@echo -e "$(YELLOW)正在加载模块...$(NC)"
	@if insmod $(target).ko; then \
		echo -e "$(GREEN)✓ 模块加载成功$(NC)"; \
		@echo "  查看: dmesg | tail -20"; \
	else \
		echo -e "$(RED)✗ 模块加载失败$(NC)"; \
		dmesg | tail -10; \
		exit 1; \
	fi

# 卸载目标
uninstall:
	@echo -e "$(YELLOW)=== 卸载模块 ===$(NC)"
	@if [ "$$(id -u)" -ne 0 ]; then \
		echo -e "$(RED)错误: 需要 sudo 权限$(NC)"; \
		exit 1; \
	fi
	@if lsmod | grep -q "^$(target) "; then \
		rmmod $(target).ko; \
		echo -e "$(GREEN)✓ 模块卸载成功$(NC)"; \
	else \
		echo -e "$(YELLOW)模块未加载$(NC)"; \
	fi

# 备份目标
backup:
	@echo -e "$(YELLOW)正在备份...$(NC)"
	@if [ -f $(target).ko ]; then \
		cp $(target).ko $(target).ko.backup; \
		echo -e "$(GREEN)✓ 已备份到 $(target).ko.backup$(NC)"; \
	fi

# 清理目标
clean:
	@echo -e "$(YELLOW)清理编译文件...$(NC)"
	@rm -f *.o *.mod.c *.ko *.order Module.symvers .*cmd .tmp_versions
	@echo -e "$(GREEN)✓ 清理完成$(NC)"

# 检查目标（依赖检查）
check:
	@echo -e "$(BLUE)=== 依赖检查 ===$(NC)"
	@echo -e "$(YELLOW)内核版本:$(NC) $$(uname -r)"
	@if [ ! -d "$(KERNEL_DIR)" ]; then \
		echo -e "$(RED)✗ 内核头文件未安装$(NC)"; \
		exit 1; \
	else \
		echo -e "$(GREEN)✓ 内核头文件: $(KERNEL_DIR)$(NC)"; \
	fi
	@if command -v insmod >/dev/null 2>&1; then \
		echo -e "$(GREEN)✓ insmod 可用$(NC)"; \
	else \
		echo -e "$(RED)✗ insmod 不可用$(NC)"; \
	fi

# 信息目标
info:
	@echo -e "$(BLUE)=== ip_hook 模块信息 ===$(NC)"
	@echo -e "$(YELLOW)版本:$(NC) $(VERSION)"
	@echo -e "$(YELLOW)内核:$(NC) $$(uname -r)"
	@echo -e "$(YELLOW)构建时间:$(NC) $(BUILD_TIME)"
	@echo -e "$(YELLOW)模块状态:$(NC)"
	@lsmod | grep -E "^$(target) " || echo "  未加载"
	@echo -e "\n$(YELLOW)过滤配置:$(NC)"
	@grep "denied_ip" ip_setting.h

# 模块日志（快速查看）
logs:
	@echo -e "$(BLUE)=== 内核日志 (最近20行) ===$(NC)"
	@dmesg | grep -i "ip_hook\|check_ip\|packet_\|droped" | tail -20

# 帮助目标
help:
	@echo -e "$(BLUE)ip_hook Makefile 使用说明$(NC)"
	@echo ""
	@echo "目标:"
	@echo "  $(GREEN)make$(NC)         编译模块"
	@echo "  $(GREEN)make install$(NC) 安装并加载模块（需要sudo）"
	@echo "  $(GREEN)make uninstall$(NC) 卸载模块（需要sudo）"
	@echo "  $(GREEN)make clean$(NC)   清理编译文件"
	@echo ""
	@echo "辅助目标:"
	@echo "  $(GREEN)make check$(NC)   检查依赖"
	@echo "  $(GREEN)make info$(NC)    显示模块信息"
	@echo "  $(GREEN)make logs$(NC)    查看内核日志"
	@echo "  $(GREEN)make help$(NC)    显示此帮助"
	@echo ""
	@echo "脚本使用 (推荐):"
	@echo "  $(GREEN)sudo ./scripts/install.sh$(NC)    智能安装"
	@echo "  $(GREEN)sudo ./scripts/uninstall.sh$(NC)  智能卸载"
	@echo "  $(GREEN)./scripts/status.sh$(NC)          查看状态"
	@echo "  $(GREEN)./scripts/logs.sh -f$(NC)         实时日志"
	@echo "  $(GREEN)./scripts/update_config.sh IP$(NC) 更新过滤IP"

# 自动显示帮助
.DEFAULT_GOAL := help
