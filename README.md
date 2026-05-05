# OpenTavern

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.11+-blue.svg" alt="Flutter">
  <img src="https://img.shields.io/badge/platform-iOS%20%7C%20Android%20%7C%20macOS%20%7C%20Windows%20%7C%20Linux%20%7C%20Web-lightgrey.svg" alt="Platform">
  <img src="https://img.shields.io/badge/license-MIT-green.svg" alt="License">
</p>

**OpenTavern** is an open-source, mobile-first character chat client. Compatible with the SillyTavern ecosystem, it lets you import character cards and chat with local or remote LLMs — no server deployment required.

> **OpenTavern** = SillyTavern on mobile + zero-config setup + modern UX

[English](#features) | [中文](#功能特性)

---

## Features

- 🤖 **Multi-Provider LLM Support** — OpenAI-compatible APIs, Ollama, KoboldCpp, vLLM / TabbyAPI
- 🎭 **Character Card System** — Import PNG (embedded metadata) and JSON (SillyTavern V2/V3) character cards
- 💬 **Immersive Chat** — Streaming output, message editing, regeneration, and context control
- 🌍 **Bilingual UI** — English / Chinese with system-language detection
- 🎨 **Adaptive Themes** — Light, dark, and system-aware color schemes
- 📱 **Mobile-First** — Native iOS & Android experience, also runs on desktop and web
- 🔒 **Privacy-First** — Local storage by default; your data never leaves your device unless you configure a remote model

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `^3.11.4`
- A valid IDE (VS Code / Android Studio / Xcode)

### Run the app

```bash
# 1. Clone the repo
git clone https://github.com/yourusername/opentavern.git
cd opentavern

# 2. Install dependencies
flutter pub get

# 3. Generate localization files
flutter gen-l10n

# 4. Run on your device or simulator
flutter run
```

### Project Structure

```
lib/
 ├─ main.dart
 └─ src/
    ├─ app/           # App entry, routing, theme, localization
    ├─ core/          # Models, LLM providers, storage abstractions
    │  ├─ llm/        # Provider interface & OpenAI-compatible implementation
    │  ├─ models/     # Domain models (Character, ChatMessage, Conversation...)
    │  ├─ providers/  # Riverpod state management
    │  └─ site/       # Character-site adapter abstractions
    └─ features/      # Feature-first pages & widgets
       ├─ chat/       # Chat detail, message bubbles, composer
       ├─ characters/ # Character list, import, detail
       ├─ discover/   # Browse and import from character sites
       ├─ settings/   # Provider config, generation params, appearance
       └─ shell/      # Bottom navigation shell
```

## Tech Stack

| Layer | Package |
|-------|---------|
| Framework | [Flutter](https://flutter.dev) |
| State Management | [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) |
| Routing | [go_router](https://pub.dev/packages/go_router) |
| Networking | [dio](https://pub.dev/packages/dio) |
| Storage | `shared_preferences` + local file storage |
| Localization | `flutter_localizations` + `intl` |
| Markdown Rendering | [flutter_markdown](https://pub.dev/packages/flutter_markdown) |

## Roadmap

- [x] Chat UI with streaming & message actions
- [x] Character import (PNG / JSON)
- [x] Multi-provider LLM configuration
- [x] Localization (EN / ZH)
- [x] Theme & appearance settings
- [ ] Lorebook (World Book) support
- [ ] Character site adapters (Chub, etc.)
- [ ] Export / import conversations
- [ ] Desktop & web polish

## Contributing

Contributions are welcome! Please open an issue first to discuss what you would like to change.

## License

[MIT](LICENSE)

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
| 存储 | `shared_preferences` + 本地文件存储 |
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

[MIT](LICENSE)
