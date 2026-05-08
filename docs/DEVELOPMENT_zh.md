# OpenTavern 开发者指南

本文面向希望本地运行、调试或贡献代码的开发者。普通用户请优先阅读 [使用指南](./USER_GUIDE_zh.md)，直接下载 Release 构建。

## 环境要求

- Flutter SDK：项目 `pubspec.yaml` 要求 Dart SDK `^3.11.4`。
- Android 开发：Android Studio 或对应 Android SDK。
- iOS / macOS 开发：Xcode。
- Windows / Linux 桌面开发：对应平台的 Flutter 桌面依赖。

确认环境：

```bash
flutter doctor
```

## 本地运行

```bash
git clone https://github.com/miraged3/OpenTavern.git
cd OpenTavern
flutter pub get
flutter gen-l10n
flutter run
```

如果切换分支后本地化代码缺失，重新执行：

```bash
flutter gen-l10n
```

## 常用命令

```bash
# 获取依赖
flutter pub get

# 生成本地化代码
flutter gen-l10n

# 静态分析
flutter analyze

# 运行测试
flutter test

# Android release APK
flutter build apk --release

# macOS release
flutter build macos --release
```

## 目录结构

```text
lib/
 ├─ main.dart
 └─ src/
    ├─ app/           # App 入口、路由、主题、本地化、全局 UI 风格
    ├─ core/          # 领域模型、LLM Provider、存储、仓储、导入逻辑
    │  ├─ import/     # 角色卡导入
    │  ├─ llm/        # LLM 抽象、Provider 注册、API 预设
    │  ├─ models/     # Character、Conversation、ModelEndpoint 等模型
    │  ├─ providers/  # Riverpod 全局状态
    │  ├─ repositories/ # 本地数据读写封装
    │  └─ storage/    # SharedPreferences 和文件存储封装
    ├─ features/      # 按功能组织的页面
    │  ├─ characters/ # 角色列表、导入、编辑、详情
    │  ├─ chat/       # 聊天首页、聊天详情
    │  ├─ discover/   # 发现页和角色站点入口
    │  ├─ help/       # 帮助与关于
    │  ├─ settings/   # 设置、模型端点、用户人格、日志
    │  └─ shell/      # 主导航 Shell
    └─ shared/        # 跨功能复用的展示组件
```

## 架构约定

OpenTavern 使用 Flutter + Riverpod，整体按 feature-first 组织 UI，按 core 组织共享领域能力。

- UI 页面放在 `lib/src/features/<feature>/presentation/`。
- 跨页面共享的领域模型放在 `lib/src/core/models/`。
- LLM 接口适配放在 `lib/src/core/llm/providers/`。
- 本地数据读写通过 repository 封装，不直接在页面里操作底层存储。
- 本地化文案维护在 `lib/l10n/*.arb`，生成文件位于 `lib/src/app/generated/`。

## 新增模型 Provider

新增 Provider 通常需要：

1. 在 `ProviderType` 或 `ApiEndpointFormat` 中补充类型，前提是确实需要新协议。
2. 在 `lib/src/core/llm/providers/` 实现 `LlmProvider`。
3. 在 `ProviderRegistry` 中注册实现。
4. 在 `api_endpoint_catalog.dart` 中加入预设，方便用户选择。
5. 为错误处理、流式输出和基础请求格式补充测试或手动验证。

如果新服务兼容 OpenAI Chat Completions，优先复用现有 OpenAI-compatible Provider，不要新增重复实现。

## 本地化

修改文案时同时更新：

- `lib/l10n/app_en.arb`
- `lib/l10n/app_zh.arb`

然后执行：

```bash
flutter gen-l10n
```

生成文件不要手写编辑。

## 版本与发布

Flutter 应用版本来自 `pubspec.yaml`：

```yaml
version: 0.0.1+1
```

其中：

- `0.0.1` 是展示给用户看的版本号。
- `+1` 是构建号。

Android、iOS 和 macOS 的版本字段已经通过 Flutter 标准变量读取该配置。GitHub Release 由 tag 触发，当前 workflow 匹配 `vX.Y.Z` 形式的 tag，例如：

```bash
git tag -a v0.0.1 -m "Release v0.0.1"
git push origin v0.0.1
```

发布前建议先确认：

- `flutter analyze` 通过。
- `flutter test` 通过。
- README 和文档中的下载、版本、功能描述与当前代码一致。
- Release workflow 中需要的签名密钥和平台构建环境可用。

## 贡献建议

- 小改动保持提交聚焦，避免混入格式化无关文件。
- 新功能优先补充用户可见说明或文档入口。
- 修改 LLM 请求行为时，说明影响的 API 格式和服务商。
- 修改角色卡导入逻辑时，保留对常见 SillyTavern 格式的兼容性。

