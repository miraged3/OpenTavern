import '../models/provider_config.dart';
import 'llm_provider.dart';
import 'providers/anthropic_messages_provider.dart';
import 'providers/cohere_v2_chat_provider.dart';
import 'providers/gemini_generate_content_provider.dart';
import 'providers/openai_compatible_provider.dart';
import 'providers/openai_responses_provider.dart';

class ProviderRegistry {
  const ProviderRegistry();

  LlmProvider create(ProviderConfig config) {
    return switch (config.apiFormat) {
      ApiEndpointFormat.openAiChatCompletions => OpenAiCompatibleProvider(
        config,
      ),
      ApiEndpointFormat.openAiResponses => OpenAiResponsesProvider(config),
      ApiEndpointFormat.anthropicMessages => AnthropicMessagesProvider(config),
      ApiEndpointFormat.geminiGenerateContent => GeminiGenerateContentProvider(
        config,
      ),
      ApiEndpointFormat.cohereV2Chat => CohereV2ChatProvider(config),
    };
  }
}
