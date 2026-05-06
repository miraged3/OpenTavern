# OpenTavern 使用指南

本文面向普通用户，说明如何下载、安装并完成第一次对话。开发者请参考 [开发者指南](./DEVELOPMENT_zh.md)。

## 下载与安装

OpenTavern 通过 GitHub Releases 分发，日常使用不需要自行构建源码。

1. 打开 [最新 Release](https://github.com/miraged3/OpenTavern/releases/latest)。
2. 根据你的系统下载对应文件：
   - Android：下载 `.apk` 文件。
   - macOS：下载 macOS `.zip`，解压后运行 `.app`。
   - Windows：下载 Windows x64 bundle，解压后运行应用。
   - Linux：下载对应架构的 Linux bundle，解压后运行应用。
3. 首次启动后进入设置页，配置至少一个模型端点。

如果 Release 页面暂时没有你需要的平台产物，说明当前版本的自动构建尚未提供该平台包。可以等待后续版本，或按 [开发者指南](./DEVELOPMENT_zh.md) 从源码运行。

## 首次使用流程

1. 打开应用。
2. 进入“设置”。
3. 打开“模型设置”，添加一个模型端点。
4. 在“角色”页导入或创建角色。
5. 回到聊天入口，选择角色开始对话。

OpenTavern 默认把角色、对话、模型配置等数据保存在本机。除非你主动配置远程模型服务，否则聊天内容不会发送到第三方服务。

## 配置模型

OpenTavern 本身不内置模型，也不提供云端推理服务。你需要配置一个可用的 API 端点。

常见选择：

- 云端模型：OpenAI、Anthropic、Gemini、Cohere、Mistral、DeepSeek、OpenRouter、Groq。
- 本地或自托管模型：Ollama、LM Studio、vLLM、KoboldCpp，以及其他 OpenAI Chat Completions 兼容服务。

详细配置方式见 [模型配置指南](./MODEL_CONFIG_zh.md)。

## 导入角色

OpenTavern 支持导入 SillyTavern 生态常见角色卡：

- PNG 角色卡：支持内嵌 `chara` 或 `ccv3` 元数据。
- JSON 角色卡：支持常见 V1 格式，以及 `chara_card_v2` / `chara_card_v3` 数据结构。

导入后可以查看角色详情，并基于角色创建或继续对话。详细说明见 [角色卡与聊天指南](./CHARACTER_CHAT_zh.md)。

## 使用建议

- 第一次配置模型后，先使用“测试”确认端点可用。
- 移动设备连接本地模型时，`localhost` 通常指手机自身，不是电脑。请使用电脑在局域网中的 IP 地址。
- 如果模型回复很慢，先降低最大输出长度，或改用响应更快的模型。
- 如果出现鉴权错误，检查 API Key、Base URL 和 API 格式是否匹配。

## 常见问题

### 为什么应用不能直接聊天？

OpenTavern 是客户端，不自带大语言模型。你需要先配置一个云端或本地模型端点。

### Android 安装 APK 时提示风险怎么办？

从 GitHub Release 下载的 APK 不是应用商店安装包，Android 可能提示来自未知来源。确认下载来源是 OpenTavern 官方仓库后，再按系统提示允许安装。

### macOS 提示应用来自未知开发者怎么办？

未签名或未公证的开源构建可能触发 macOS Gatekeeper 提示。可以在系统设置的隐私与安全中允许打开，或自行从源码构建。

### 数据保存在哪里？

当前应用使用本地偏好存储和本地文件存储。不同系统的实际目录由 Flutter 和系统平台决定。卸载应用或清理应用数据可能会删除本地角色、对话和设置。

