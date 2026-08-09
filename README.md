# ip_hook - Linux内核Netfilter包过滤器

[![Kernel Version](https://img.shields.io/badge/kernel-4.4.0--142-generic-blue.svg)](https://www.kernel.org/)
[![License](https://img.shields.io/badge/license-GPL-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Ubuntu%2014.04-orange.svg)](https://ubuntu.com/)

基于Netfilter钩子框架的Linux内核级IP数据包过滤模块。

---

## 📋 目录

- [功能特性](#功能特性)
- [系统要求](#系统要求)
- [快速开始](#快速开始)
- [使用方法](#使用方法)
- [配置管理](#配置管理)
- [监控和调试](#监控和调试)
- [工作原理](#工作原理)
- [常见问题](#常见问题)
- [安全注意事项](#安全注意事项)

---

## ✨ 功能特性

- ✅ **内核级过滤** - 使用Netfilter钩子实现高层性能
- ✅ **双向控制** - 支持入站和出站数据包过滤
- ✅ **实时日志** - 通过 `dmesg` 输出详细的过滤日志
- ✅ **易于部署** - 一键安装/卸载脚本
- ✅ **状态监控** - 实时监控面板和日志工具
- ✅ **动态配置** - 支持在线更新过滤IP（无需重新编译）

---

## 🔧 系统要求

| 项目 | 要求 |
|------|------|
| 操作系统 | Ubuntu 14.04.6 LTS |
| 内核版本 | 4.4.0-142-generic (兼容其他Linux内核) |
| 权限 | root/sudo (加载/卸载内核模块) |
| 依赖 | `linux-headers-$(uname -r)` |

### 依赖安装

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y linux-headers-$(uname -r) build-essential

# RHEL/CentOS
sudo yum install -y kernel-devel kernel-headers make
```

---

## 🚀 快速开始

### 1. 编译模块

```bash
cd ip_hook
make
```

### 2. 安装并加载（推荐使用智能脚本）

```bash
sudo ./scripts/install.sh
```

### 3. 验证安装

```bash
./scripts/status.sh
```

### 4. 查看日志

```bash
./scripts/logs.sh -f  # 实时跟踪日志
```

### 5. 卸载模块

```bash
sudo ./scripts/uninstall.sh
```

---

## 📖 使用方法

### 基本命令

| 命令 | 描述 |
|------|------|
| `make` | 编译模块 |
| `make install` | 手动安装（使用脚本更好） |
| `make uninstall` | 手动卸载 |
| `make clean` | 清理编译文件 |
| `make help` | 显示所有可用命令 |

### 脚本工具

项目包含以下辅助脚本（推荐使用）：

| 脚本 | 功能 | 说明 |
|------|------|------|
| `scripts/install.sh` | 智能安装 | 自动检查环境、编译、加载 |
| `scripts/uninstall.sh` | 智能卸载 | 卸载模块 |
| `scripts/status.sh` | 状态检查 | 显示模块信息、统计、最近日志 |
| `scripts/logs.sh` | 日志查看 | 支持 `-f` 实时、`-d` 只看丢弃、`-n N` 行数 |
| `scripts/update_config.sh` | 配置更新 | 动态更新过滤IP（--需重载模块） |
| `scripts/watch_logs.sh` | 实时监控 | 2D仪表板监控面板 |

### 日志脚本示例

```bash
# 查看最近50条日志
./scripts/logs.sh -n 50

# 只看被丢弃的包
./scripts/logs.sh -d

# 实时跟踪（带颜色高亮）
./scripts/logs.sh -f
```

---

## ⚙️ 配置管理

### 当前配置

默认过滤IP配置在 `ip_setting.h`：

```c
const unsigned char *denied_ip = "192.168.0.201";
```

### 更新过滤IP（无需修改源代码）

#### 方法1: 使用配置更新脚本（推荐）

```bash
./scripts/update_config.sh 192.168.0.100
sudo rmmod ip_hook && sudo insmod ip_hook.ko
```

#### 方法2: 手动编辑并重新编译

```bash
# 修改 ip_setting.h 中的IP
vim ip_setting.h

# 重新编译和加载
make clean && make
sudo ./scripts/install.sh
```

⚠️ **注意**: 更新配置后必须重新加载模块才能生效！

---

## 🔍 监控和调试

### 快速状态查看

```bash
./scripts/status.sh
```

输出示例：
```
=== ip_hook 模块状态 ===

● 模块状态: 已加载
模块信息:
ip_hook                2784  0
模块信息:
modules:         ip_hook 0.0.1
author:          zerosun
...

=== 当前过滤配置 ===
const unsigned char *denied_ip = "192.168.0.201";//过滤IP

=== 最近的内核日志 ===
[ 23456.789] packetsIN  droped for    src_ip=192.168.0.201
[ 23457.123] packetsOUT droped for    dst_ip=192.168.0.201

=== 统计信息 ===
已丢弃数据包数: 42
内核版本: 4.4.0-142-generic
```

### 实时监控面板

```bash
./scripts/watch_logs.sh
```

提供2D仪表板，每2秒刷新一次，显示：
- 模块状态
- 过滤配置
- 实时统计数据（已接受/已丢弃）
- 最近丢弃记录
- 最新日志

### 查看 `dmesg` 日志

```bash
# 所有相关日志
sudo dmesg | grep -i "ip_hook\|check_ip\|packet_\|droped"

# 只看丢弃的包
sudo dmesg | grep "droped"

# 实时跟踪
sudo dmesg -w | grep -i "droped"
```

### 常见日志含义

```bash
# 数据包进入
packet_in:
src_ip:192.168.0.201    dst_ip:192.168.0.1

# 数据包发出
packet_out:
src_ip:192.168.0.1      dst_ip:192.168.0.201

# 丢弃日志（错误级别）
packetsIN  droped for    src_ip=192.168.0.201
packetsOUT droped for    dst_ip=192.168.0.201
```

---

## 🧠 工作原理

### Netfilter 钩子流程

```
┌─────────────────────────────────────────────────────────┐
│                    网络数据包进入                        │
└─────────────────────────────────────────────────────────┘
                         │
                         ▼
         ┌───────────────────────────────┐
         │  NF_INET_PRE_ROUTING         │  ← 钩子1: PASS
         │  (路由前处理)                 │
         └───────────────────────────────┘
                         │
             ┌───────────┴──────────┐
             ▼                      ▼
   ┌────────────────┐      ┌────────────────┐
   │ LOCAL_IN       │      │ FORWARD        │  ← 钩子2/3: DROP
   │ (本地接收)     │      │ (转发)         │     源IP匹配时
   │  [源IP过滤]    │      │  [通过]        │
   └────────────────┘      └────────────────┘
             │                      │
             └───────────┬──────────┘
                         ▼
         ┌───────────────────────────────┐
         │  NF_INET_LOCAL_OUT           │  ← 钩子4: DROP
         │  (本地发出)                   │     目标IP匹配时
         │  [目标IP过滤]                │
         └───────────────────────────────┘
                         │
                         ▼
         ┌───────────────────────────────┐
         │  NF_INET_POST_ROUTING        │  ← 钩子5: PASS
         │  (路由后处理)                │
         └───────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│                    网络数据包发出                        │
└─────────────────────────────────────────────────────────┘
```

### 过滤逻辑

| 钩子点 | 行为 | 条件 |
|--------|------|------|
| `NF_INET_LOCAL_IN` | DROP | 源IP = denied_ip |
| `NF_INET_LOCAL_OUT` | DROP | 目标IP = denied_ip |
| 其他 | ACCEPT | - |

### 优先级设置

```c
.priority = NF_IP_PRI_FILTER-1
```

比标准 iptables 过滤器优先级更高，确保在规则前处理。

---

## ❓ 常见问题

### Q: 编译时提示 "linux/netfilter.h not found"

**A:** 安装内核头文件：
```bash
sudo apt-get install linux-headers-$(uname -r)
```

### Q: insmod 时提示 "checksum error"

**A:** 内核版本不兼容，检查并匹配内核头文件：
```bash
uname -r
ls /lib/modules/
```

### Q: 模块加载后没有日志输出

**A:** 确认内核消息级别：
```bash
# 查看级别
cat /proc/sys/kernel/printk

# 临时提高级别
sudo bash -c "echo 8 > /proc/sys/kernel/printk"
```

### Q: update_config.sh 失败: "IP长度超过"

**A:** 新IP比当前IP长，需要重新编译源代码：
```bash
vim ip_setting.h  # 修改 denied_ip
make clean && make
sudo ./scripts/install.sh
```

### Q: 如何禁用所有过滤？

**A:** 使用不存在的IP（这不会匹配任何数据包）：
```bash
./scripts/update_config.sh 255.255.255.255
sudo rmmod ip_hook && sudo insmod ip_hook.ko
```

或直接卸载：
```bash
sudo ./scripts/uninstall.sh
```

### Q: 模块丢失导致系统无法启动？

**A:** 极少见（不是启动加载）。如遇到：
```bash
# 进入恢复模式，卸载
rmmod ip_hook
```

---

## ⚠️ 安全注意事项

1. **仅用于测试/学习环境** - 这是演示项目，不是生产级防火墙
2. **硬编码配置** - 默认配置在编译时嵌入，安全性有限
3. **无加密/签名验证** - 模块可以被篡改
4. **root权限** - 内核模块拥有最高权限，错误可能导致系统崩溃
5. **不持久化** - 重启后需手动加载（如需持久化添加到 `/etc/modules`）
6. **单IP限制** - 每次只能过滤一个IP地址

### 生产环境替代方案

考虑使用成熟工具：
- **iptables** / **nftables** - 标准包过滤
- **ufw** - 简化的防火墙
- **firewalld** - 企业级防火墙管理
- **conntrack-tools** - 高级连接跟踪

---

## 📚 参考

- [Netfilter Hook Architecture](https://www.kernel.org/doc/Documentation/networking/nf-hooks.txt)
- [Linux Kernel Module Programming Guide](https://sysprog21.github.io/lkmpg/)
- [skbuff Structure](https://elixir.bootlin.com/linux/v4.4/source/include/linux/skbuff.h)

---

## 📄 许可证

GPL - 见 LICENSE 文件

---

## 👤 作者

zerosun

---

## 🤝 贡献

这是一个学习/演示项目，欢迎提交 Issue 和 PR！

---

**提示:** 使用 `-f` 参数实时查看日志：`./scripts/logs.sh -f`
