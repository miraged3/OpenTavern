import 'package:dio/dio.dart';

import '../../models/chat_message.dart';
import '../../models/generation_config.dart';
import '../llm_provider.dart';
import '../llm_stream_event.dart';
import 'streaming_helpers.dart';

class OpenAiResponsesProvider extends LlmProvider {
  OpenAiResponsesProvider(super.config)
    : _dio = Dio(
        llmBaseOptions(
          baseUrl: config.baseUrl,
          headers: {
            if ((config.apiKey ?? '').isNotEmpty)
              'Authorization': 'Bearer ${config.apiKey}',
          },
        ),
      );

  final Dio _dio;

  @override
  Future<List<String>> listModels() async {
    final response = await _dio.get<Map<String, dynamic>>('/models');
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
    final response = await _dio.post<Map<String, dynamic>>(
      '/responses',
      data: {
        'model': this.config.defaultModel,
        'input': [
          for (final message in messages)
            {'role': _responsesRole(message.role), 'content': message.content},
        ],
        'temperature': config.temperature,
        'top_p': config.topP,
        'max_output_tokens': config.maxTokens,
        ..._reasoningOptions(config),
      },
    );
    return response.data?['output_text'] as String? ?? '';
  }

  @override
  Stream<LlmStreamEvent> streamGenerate({
    required List<ChatMessage> messages,
    required GenerationConfig config,
  }) async* {
    final response = await _dio.post<ResponseBody>(
      '/responses',
      data: {
        'model': this.config.defaultModel,
        'input': [
          for (final message in messages)
            {'role': _responsesRole(message.role), 'content': message.content},
        ],
        'temperature': config.temperature,
        'top_p': config.topP,
        'max_output_tokens': config.maxTokens,
        ..._reasoningOptions(config),
        'stream': true,
      },
      options: Options(responseType: ResponseType.stream),
    );

    final responseBody = response.data;
    if (responseBody == null) {
      return;
    }

    await for (final decoded in decodeSseJson(responseBody)) {
      final type = decoded['type'];
      if (type == 'response.output_text.delta') {
        final delta = decoded['delta'];
        if (delta is String && delta.isNotEmpty) {
          yield LlmStreamEvent.text(delta);
        }
        continue;
      }

      if (type == 'response.reasoning_text.delta' ||
          type == 'response.reasoning.delta') {
        final delta = decoded['delta'];
        if (delta is String && delta.isNotEmpty) {
          yield LlmStreamEvent.reasoning(delta);
        }
      }
    }
  }

  Map<String, dynamic> _reasoningOptions(GenerationConfig config) {
    return switch (config.reasoningMode) {
      ReasoningMode.off => {
        'reasoning': {'effort': 'minimal'},
      },
      ReasoningMode.automatic => const <String, dynamic>{},
      ReasoningMode.low => {
        'reasoning': {'effort': 'low'},
      },
      ReasoningMode.medium => {
        'reasoning': {'effort': 'medium'},
      },
      ReasoningMode.high => {
        'reasoning': {'effort': 'high'},
      },
    };
  }
}

String _responsesRole(MessageRole role) {
  return switch (role) {
    MessageRole.user => 'user',
    MessageRole.assistant => 'assistant',
    MessageRole.system => 'system',
  };
}
