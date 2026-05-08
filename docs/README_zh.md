# OpenTavern

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.11+-blue.svg" alt="Flutter">
  <img src="https://img.shields.io/badge/platform-iOS%20%7C%20Android%20%7C%20macOS%20%7C%20Windows%20%7C%20Linux%20%7C%20Web-lightgrey.svg" alt="Platform">
  <img src="https://img.shields.io/badge/license-MIT-green.svg" alt="License">
</p>

**OpenTavern** 是一个开源的、移动优先的角色聊天客户端。兼容 SillyTavern 生态，支持导入角色卡并与本地或远程 LLM 聊天 —— 无需部署服务器。

> **OpenTavern** = 手机上的 SillyTavern + 零配置 + 现代体验

[English](../README.md) | [中文](./README_zh.md)

---

## 功能特性

- 🤖 **多模型后端支持** — OpenAI 兼容 API、Ollama、KoboldCpp、vLLM / TabbyAPI
- 🎭 **角色卡系统** — 导入 PNG（内嵌元数据）和 JSON（SillyTavern V2/V3）角色卡
- 💬 **沉浸式聊天** — 流式输出、消息编辑、重新生成、上下文控制
- 🌍 **双语界面** — 英文 / 中文，支持跟随系统语言自动切换
- 🎨 **自适应主题** — 浅色、深色、跟随系统
- 📱 **移动优先** — 原生 iOS 与 Android 体验，同时支持桌面端与 Web
- 🔒 **隐私优先** — 默认本地存储；除非你自己配置远程模型，否则数据不会离开设备

## 快速开始

### 环境要求

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `^3.11.4`
- 任意 IDE（VS Code / Android Studio / Xcode）

### 运行项目

```bash
# 1. 克隆仓库
git clone https://github.com/yourusername/opentavern.git
cd opentavern

# 2. 安装依赖
flutter pub get

# 3. 生成本地化文件
flutter gen-l10n

# 4. 运行到你的设备或模拟器
flutter run
```

## 技术栈

| 层级 | 依赖 |
|------|------|
| 框架 | [Flutter](https://flutter.dev) |
| 状态管理 | [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) |
| 路由 | [go_router](https://pub.dev/packages/go_router) |
| 网络 | [dio](https://pub.dev/packages/dio) |
| 存储 | SQLite |
| 本地化 | `flutter_localizations` + `intl` |
| Markdown 渲染 | [flutter_markdown](https://pub.dev/packages/flutter_markdown) |

## 开发路线

- [x] 聊天界面（流式输出 & 消息操作）
- [x] 角色导入（PNG / JSON）
- [x] 多模型 Provider 配置
- [x] 本地化（中 / 英）
- [x] 主题与外观设置
- [ ] 世界书（Lorebook）
- [ ] 角色站点接入（Chub 等）
- [ ] 对话导出 / 导入
- [ ] 桌面端与 Web 体验优化

## 参与贡献

欢迎提交 Issue 和 PR！建议先开 Issue 讨论你想要改动的内容。

## 许可证

[MIT](../LICENSE)
