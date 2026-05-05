enum ProviderType {
  openAi,
  openAiCompatible,
  anthropic,
  gemini,
  cohere,
  mistral,
  deepSeek,
  openRouter,
  groq,
  ollama,
  lmStudio,
  koboldCpp,
  vllm,
  custom,
}

enum ApiEndpointFormat {
  openAiChatCompletions,
  openAiResponses,
  anthropicMessages,
  geminiGenerateContent,
  cohereV2Chat,
}

class ProviderConfig {
  const ProviderConfig({
    required this.id,
    required this.label,
    required this.type,
    required this.apiFormat,
    required this.baseUrl,
    required this.defaultModel,
    this.apiKey,
    this.isEnabled = true,
    this.supportsStreaming = true,
  });

  final String id;
  final String label;
  final ProviderType type;
  final ApiEndpointFormat apiFormat;
  final String baseUrl;
  final String defaultModel;
  final String? apiKey;
  final bool isEnabled;
  final bool supportsStreaming;
}
