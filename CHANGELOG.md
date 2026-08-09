# Changelog

本文档记录 ip_hook 项目的所有重要变更。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)。

版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

---

## [Unreleased]

## [0.2.0] - 2025-08-09

### Added (新增)
- **智能安装脚本** (`install.sh`) - 环境检查、编译、加载一体化
- **智能卸载脚本** (`uninstall.sh`) - 安全卸载模块
- **状态检查脚本** (`status.sh`) - 模块信息、配置、日志查看
- **日志查看器** (`logs.sh`) 支持多种模式：
  - `-f` 实时跟踪（类似 `tail -f`）
  - `-d` 只显示丢弃的数据包
  - `-n` 自定义行数
- **配置更新脚本** (`update_config.sh`) - 动态更新过滤IP，无需修改源代码
- **实时监控面板** (`watch_logs.sh`) - 2D 仪表板，持续监控模块状态和统计
- **增强的 Makefile**:
  - 自动版本信息（Git + 构建时间）
  - 内置依赖检查 (`make check`)
  - 快速日志查看 (`make logs`)
  - 自动备份机制
  - 颜色化输出
  - 详细帮助系统 (`make help`)
- **Git 忽略文件** (`.gitignore`) - 控制编译临时文件和备份文件的提交
- **优化总结文档** (`OPTIMIZATION_SUMMARY.md`) - 详细的优化说明和使用指南

### Changed (变更)
- 全面重写 README.md:
  - 新增快速开始指南
  - 添加架构图和流程说明
  - 详细的 API/脚本使用说明
  - 完整的 FAQ 章节
  - 安全注意事项

### Fixed (修复)
- 模块加载失败时提供明确的错误诊断信息
- 脚本权限验证增强，防止非 root 用户误操作

### Improved (改进)
- 所有脚本增加了 ANSI 颜色支持，提升可读性
- 错误提示更友好，包含修复建议
- 所有脚本包含完整的 `--help` 支持
- 配置更新采用原子替换，避免不一致状态

### Docs (文档)
- 每个脚本都有详细的内联注释
- 自顶向下的使用说明：从快速开始到高级功能
- 为生产环境使用提供警告和替代方案建议

---

## [0.1.0] - Initial Release

### Added
- 基础 Netfilter 内核模块
- 基于 5 个 Netfilter 钩子点：
  - `NF_INET_PRE_ROUTING` (PASS)
  - `NF_INET_LOCAL_IN` (DROP 源IP匹配)
  - `NF_INET_FORWARD` (PASS)
  - `NF_INET_LOCAL_OUT` (DROP 目标IP匹配)
  - `NF_INET_POST_ROUTING` (PASS)
- `ip_hook.c` - 核心过滤逻辑（160 行）
- `ip_hook.h` - 内核头文件
- `ip_setting.h` - 配置（硬编码 IP: 192.168.0.201）
- 基础 Makefile（编译/安装/卸载/清理）
- 简单的 README.md（4 行）

---

## [术语说明]

- **版本**: 采用语义化版本 (例如: 0.2.0)
- **日期**: YYYY-MM-DD 格式
- **类型**:
  - `Added` - 新功能
  - `Changed` - 功能变更
  - `Deprecated` - 即将废弃的功能
  - `Removed` - 已删除的功能
  - `Fixed` - Bug 修复
  - `Security` - 安全性改进

---

## [贡献指南]

所有变更应在此文件中记录，包括：
- 变更类型
- 影响的用户
- 向后兼容性影响
- 迁移指南（如需要）

查看 [README.md](README.md) 了解完整的项目信息。
