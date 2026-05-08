# 模型配置指南

OpenTavern 通过“模型端点”连接云端、本地或自托管 LLM 服务。每个端点包含名称、API 格式、Base URL、模型名、API Key、启用状态等信息。

## 基本概念

- 端点名称：显示在应用里的配置名称，可以按用途命名，例如 `OpenAI`、`Local Ollama`。
- API 格式：服务端使用的接口协议，例如 OpenAI Chat Completions、OpenAI Responses、Anthropic Messages。
- Base URL：API 根地址，不要填具体聊天接口路径，除非服务商文档明确要求。
- 模型名：服务端识别的模型 ID。
- API Key：云端服务通常需要；本地服务可能不需要。
- 默认模型：聊天时优先使用的模型端点。

## 支持的 API 格式

OpenTavern 当前支持以下 API 格式：

| API 格式 | 典型服务 |
| --- | --- |
| OpenAI Chat Completions | OpenAI 兼容服务、Mistral、DeepSeek、OpenRouter、Groq、Ollama、LM Studio、vLLM、KoboldCpp |
| OpenAI Responses | OpenAI Responses API |
| Anthropic Messages | Anthropic Claude |
| Gemini Generate Content | Google Gemini |
| Cohere v2 Chat | Cohere |

选择端点预设时，应用会自动填入常见 Base URL、API 格式和示例模型名。你仍需要确认模型名和 API Key 是否与你的账户或本地服务一致。

## 云端服务配置

### OpenAI Responses

- API 格式：OpenAI Responses
- Base URL：`https://api.openai.com/v1`
- 模型示例：`gpt-4.1`
- API Key：需要

### Anthropic Messages

- API 格式：Anthropic Messages
- Base URL：`https://api.anthropic.com`
- 模型示例：`claude-sonnet-4-20250514`
- API Key：需要

### Google Gemini

- API 格式：Gemini Generate Content
- Base URL：`https://generativelanguage.googleapis.com/v1beta`
- 模型示例：`gemini-2.5-flash`
- API Key：需要

### OpenAI 兼容云服务

Mistral、DeepSeek、OpenRouter、Groq 等服务通常使用 OpenAI Chat Completions 兼容格式。配置时重点检查三项：

- Base URL 是否来自服务商文档。
- 模型名是否为服务商当前可用的模型 ID。
- API Key 是否有对应模型的调用权限。

## 本地模型配置

移动设备访问本地模型时要特别注意网络地址。

如果模型服务运行在同一台电脑上：

- 桌面端 OpenTavern 可以使用 `localhost`。
- 手机端 OpenTavern 不能使用电脑的 `localhost`，需要使用电脑的局域网 IP，例如 `http://192.168.1.10:11434/v1`。

### Ollama

- API 格式：OpenAI Chat Completions
- 电脑本机 Base URL：`http://localhost:11434/v1`
- 手机访问示例：`http://你的电脑局域网IP:11434/v1`
- 模型示例：`llama3.1`

确保 Ollama 服务允许局域网访问，否则手机无法连接。

### LM Studio

- API 格式：OpenAI Chat Completions
- 默认 Base URL：`http://localhost:1234/v1`
- 模型名：以 LM Studio 服务实际暴露的模型名为准

### vLLM

- API 格式：OpenAI Chat Completions
- 默认 Base URL：`http://localhost:8000/v1`
- 模型示例：`Qwen/Qwen3-8B`

### KoboldCpp

- API 格式：OpenAI Chat Completions
- 默认 Base URL：`http://localhost:5001/v1`
- 模型名：以服务实际配置为准

## 生成参数

OpenTavern 支持基础生成参数：

- Temperature：控制随机性。数值越高，回复越发散。
- Top P：控制采样范围。一般保持默认即可。
- Max Tokens：控制单次最大输出长度。回复过慢或过长时可降低。
- Reasoning Mode：控制推理模式。不是所有模型都支持，具体效果取决于服务端。
- Stop：停止词。模型输出命中停止词时会提前结束。

## 排错

### 401 或鉴权失败

检查 API Key 是否正确、是否过期、是否复制了多余空格，以及账户是否有对应模型权限。

### 404 或模型不存在

检查模型名是否填写正确。很多服务商的模型 ID 区分大小写和前缀。

### 连接超时

检查网络、防火墙、代理设置和 Base URL。手机访问电脑本地模型时，确认手机和电脑在同一局域网。

### 本地模型能在电脑访问，手机不能访问

不要在手机端填写 `localhost`。改为电脑的局域网 IP，并确认本地模型服务监听地址允许外部设备访问。

### 回复为空或流式输出中断

尝试关闭流式输出、降低最大输出长度，或切换到服务商明确支持 Chat Completions / Responses 的模型。

