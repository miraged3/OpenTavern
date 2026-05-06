# OpenTavern

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.11+-blue.svg" alt="Flutter">
  <img src="https://img.shields.io/badge/platform-iOS%20%7C%20Android%20%7C%20macOS%20%7C%20Windows%20%7C%20Linux%20%7C%20Web-lightgrey.svg" alt="Platform">
  <img src="https://img.shields.io/badge/license-MIT-green.svg" alt="License">
</p>

**OpenTavern** is an open-source, mobile-first character chat client. Compatible with the SillyTavern ecosystem, it lets you import character cards and chat with local or remote LLMs — no server deployment required.

> **OpenTavern** = SillyTavern on mobile + zero-config setup + modern UX

[English](./README.md) | [中文](./docs/README_zh.md)

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

### Download the app

OpenTavern is distributed through GitHub Releases. For normal use, download the latest build directly instead of building from source:

1. Open the [latest release](https://github.com/miraged3/OpenTavern/releases/latest).
2. Download the package for your platform.
3. Install or unpack it and run OpenTavern.

Available release artifacts depend on the current release workflow, and may include Android APK, macOS app zip, Windows x64 bundle, and Linux bundles.

### Build from source

Building from source is intended for development, testing, or contributing.

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `^3.11.4`
- A valid IDE (VS Code / Android Studio / Xcode)

### Run locally

```bash
# 1. Clone the repo
git clone https://github.com/miraged3/OpenTavern.git
cd OpenTavern

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
