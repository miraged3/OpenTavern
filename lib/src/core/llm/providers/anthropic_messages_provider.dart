import 'package:dio/dio.dart';

import '../../models/chat_message.dart';
import '../../models/generation_config.dart';
import '../llm_provider.dart';
import '../llm_stream_event.dart';
import 'endpoint_format_helpers.dart';
import 'streaming_helpers.dart';

class AnthropicMessagesProvider extends LlmProvider {
  AnthropicMessagesProvider(super.config)
    : _dio = Dio(
        llmBaseOptions(
          baseUrl: config.baseUrl,
          headers: {
            if ((config.apiKey ?? '').isNotEmpty) 'x-api-key': config.apiKey,
            'anthropic-version': '2023-06-01',
          },
        ),
      );

  final Dio _dio;

  @override
  Future<List<String>> listModels() async {
    final response = await _dio.get<Map<String, dynamic>>('/v1/models');
    final data = response.data?['data'] as List<dynamic>?;
    return [
      for (final item in data ?? const <dynamic>[])
        if (item is Map<String, dynamic> && item['id'] is String)
          item['id'] as String,
    ];
  }

  @override
  Future<String> generate({
    required List<ChatMessage> messages,
    required GenerationConfig config,
  }) async {
    final system = messages
        .where((message) => message.role == MessageRole.system)
        .map((message) => message.content)
        .join('\n\n');
    final chatMessages = messages
        .where((message) => message.role != MessageRole.system)
        .toList(growable: false);

    final response = await _dio.post<Map<String, dynamic>>(
      '/v1/messages',
      data: {
        'model': this.config.defaultModel,
        'max_tokens': config.maxTokens,
        'temperature': config.temperature,
        'top_p': config.topP,
        ..._thinkingOptions(config),
        if (system.isNotEmpty) 'system': system,
        'messages': openAiMessages(chatMessages),
      },
    );
    final content = response.data?['content'] as List<dynamic>?;
    final first = content?.firstOrNull as Map<String, dynamic>?;
    return first?['text'] as String? ?? '';
  }

  @override
  Stream<LlmStreamEvent> streamGenerate({
    required List<ChatMessage> messages,
    required GenerationConfig config,
  }) async* {
    final system = messages
        .where((message) => message.role == MessageRole.system)
        .map((message) => message.content)
        .join('\n\n');
    final chatMessages = messages
        .where((message) => message.role != MessageRole.system)
        .toList(growable: false);

    final response = await _dio.post<ResponseBody>(
      '/v1/messages',
      data: {
        'model': this.config.defaultModel,
        'max_tokens': config.maxTokens,
        'temperature': config.temperature,
        'top_p': config.topP,
        ..._thinkingOptions(config),
        'stream': true,
        if (system.isNotEmpty) 'system': system,
        'messages': openAiMessages(chatMessages),
      },
      options: Options(responseType: ResponseType.stream),
    );

    final responseBody = response.data;
    if (responseBody == null) {
      return;
    }

    await for (final decoded in decodeSseJson(responseBody)) {
      if (decoded['type'] != 'content_block_delta') {
        continue;
      }

      final delta = decoded['delta'];
      if (delta is! Map<String, dynamic>) {
        continue;
      }

      final deltaType = delta['type'];
      if (deltaType == 'text_delta') {
        final text = delta['text'];
        if (text is String && text.isNotEmpty) {
          yield LlmStreamEvent.text(text);
        }
        continue;
      }
      if (deltaType == 'thinking_delta') {
        final thinking = delta['thinking'];
        if (thinking is String && thinking.isNotEmpty) {
          yield LlmStreamEvent.reasoning(thinking);
        }
      }
    }
  }

  Map<String, dynamic> _thinkingOptions(GenerationConfig config) {
    final budgetTokens = switch (config.reasoningMode) {
      ReasoningMode.off || ReasoningMode.automatic => null,
      ReasoningMode.low => 1024,
      ReasoningMode.medium => 4096,
      ReasoningMode.high => 8192,
    };
    if (budgetTokens == null) {
      return const <String, dynamic>{};
    }
    return {
      'thinking': {'type': 'enabled', 'budget_tokens': budgetTokens},
    };
  }
}
