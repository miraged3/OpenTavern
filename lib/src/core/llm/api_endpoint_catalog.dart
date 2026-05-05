import '../models/provider_config.dart';

enum ApiEndpointPresetGroup { cloud, selfHosted }

enum CloudVendorId {
  openAi,
  anthropic,
  gemini,
  cohere,
  mistral,
  deepSeek,
  openRouter,
  groq,
}

class ApiEndpointPreset {
  const ApiEndpointPreset({
    required this.name,
    required this.providerType,
    required this.apiFormat,
    required this.baseUrl,
    required this.exampleModel,
    required this.group,
    this.cloudVendorId,
  });

  final String name;
  final ProviderType providerType;
  final ApiEndpointFormat apiFormat;
  final String baseUrl;
  final String exampleModel;
  final ApiEndpointPresetGroup group;
  final CloudVendorId? cloudVendorId;
}

const apiEndpointPresets = <ApiEndpointPreset>[
  ApiEndpointPreset(
    name: 'OpenAI Responses',
    providerType: ProviderType.openAi,
    apiFormat: ApiEndpointFormat.openAiResponses,
    baseUrl: 'https://api.openai.com/v1',
    exampleModel: 'gpt-4.1',
    group: ApiEndpointPresetGroup.cloud,
    cloudVendorId: CloudVendorId.openAi,
  ),
  ApiEndpointPreset(
    name: 'Anthropic Messages',
    providerType: ProviderType.anthropic,
    apiFormat: ApiEndpointFormat.anthropicMessages,
    baseUrl: 'https://api.anthropic.com',
    exampleModel: 'claude-sonnet-4-20250514',
    group: ApiEndpointPresetGroup.cloud,
    cloudVendorId: CloudVendorId.anthropic,
  ),
  ApiEndpointPreset(
    name: 'Google Gemini',
    providerType: ProviderType.gemini,
    apiFormat: ApiEndpointFormat.geminiGenerateContent,
    baseUrl: 'https://generativelanguage.googleapis.com/v1beta',
    exampleModel: 'gemini-2.5-flash',
    group: ApiEndpointPresetGroup.cloud,
    cloudVendorId: CloudVendorId.gemini,
  ),
  ApiEndpointPreset(
    name: 'Cohere v2 Chat',
    providerType: ProviderType.cohere,
    apiFormat: ApiEndpointFormat.cohereV2Chat,
    baseUrl: 'https://api.cohere.com',
    exampleModel: 'command-a-03-2025',
    group: ApiEndpointPresetGroup.cloud,
    cloudVendorId: CloudVendorId.cohere,
  ),
  ApiEndpointPreset(
    name: 'Mistral Chat',
    providerType: ProviderType.mistral,
    apiFormat: ApiEndpointFormat.openAiChatCompletions,
    baseUrl: 'https://api.mistral.ai/v1',
    exampleModel: 'mistral-large-latest',
    group: ApiEndpointPresetGroup.cloud,
    cloudVendorId: CloudVendorId.mistral,
  ),
  ApiEndpointPreset(
    name: 'DeepSeek Chat',
    providerType: ProviderType.deepSeek,
    apiFormat: ApiEndpointFormat.openAiChatCompletions,
    baseUrl: 'https://api.deepseek.com',
    exampleModel: 'deepseek-v4-flash',
    group: ApiEndpointPresetGroup.cloud,
    cloudVendorId: CloudVendorId.deepSeek,
  ),
  ApiEndpointPreset(
    name: 'OpenRouter',
    providerType: ProviderType.openRouter,
    apiFormat: ApiEndpointFormat.openAiChatCompletions,
    baseUrl: 'https://openrouter.ai/api/v1',
    exampleModel: 'anthropic/claude-sonnet-4',
    group: ApiEndpointPresetGroup.cloud,
    cloudVendorId: CloudVendorId.openRouter,
  ),
  ApiEndpointPreset(
    name: 'Groq',
    providerType: ProviderType.groq,
    apiFormat: ApiEndpointFormat.openAiChatCompletions,
    baseUrl: 'https://api.groq.com/openai/v1',
    exampleModel: 'llama-3.3-70b-versatile',
    group: ApiEndpointPresetGroup.cloud,
    cloudVendorId: CloudVendorId.groq,
  ),
  ApiEndpointPreset(
    name: 'Ollama OpenAI-compatible',
    providerType: ProviderType.ollama,
    apiFormat: ApiEndpointFormat.openAiChatCompletions,
    baseUrl: 'http://localhost:11434/v1',
    exampleModel: 'llama3.1',
    group: ApiEndpointPresetGroup.selfHosted,
  ),
  ApiEndpointPreset(
    name: 'LM Studio OpenAI-compatible',
    providerType: ProviderType.lmStudio,
    apiFormat: ApiEndpointFormat.openAiChatCompletions,
    baseUrl: 'http://localhost:1234/v1',
    exampleModel: 'local-model',
    group: ApiEndpointPresetGroup.selfHosted,
  ),
  ApiEndpointPreset(
    name: 'vLLM OpenAI-compatible',
    providerType: ProviderType.vllm,
    apiFormat: ApiEndpointFormat.openAiChatCompletions,
    baseUrl: 'http://localhost:8000/v1',
    exampleModel: 'Qwen/Qwen3-8B',
    group: ApiEndpointPresetGroup.selfHosted,
  ),
  ApiEndpointPreset(
    name: 'KoboldCpp OpenAI-compatible',
    providerType: ProviderType.koboldCpp,
    apiFormat: ApiEndpointFormat.openAiChatCompletions,
    baseUrl: 'http://localhost:5001/v1',
    exampleModel: 'local-model',
    group: ApiEndpointPresetGroup.selfHosted,
  ),
];
