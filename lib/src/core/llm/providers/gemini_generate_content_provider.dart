import 'package:dio/dio.dart';

import '../../models/chat_message.dart';
import '../../models/generation_config.dart';
import '../llm_provider.dart';
import '../llm_stream_event.dart';
import 'streaming_helpers.dart';

class GeminiGenerateContentProvider extends LlmProvider {
  GeminiGenerateContentProvider(super.config)
    : _dio = Dio(llmBaseOptions(baseUrl: config.baseUrl));

  final Dio _dio;

  @override
  Future<List<String>> listModels() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/models',
      queryParameters: {
        if ((config.apiKey ?? '').isNotEmpty) 'key': config.apiKey,
      },
    );
    final models = response.data?['models'] as List<dynamic>?;
    return [
      for (final item in models ?? const <dynamic>[])
        if (item is Map<String, dynamic> && item['name'] is String)
          (item['name'] as String).replaceFirst('models/', ''),
    ];
  }

  @override
  Future<String> generate({
    required List<ChatMessage> messages,
    required GenerationConfig config,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/models/${this.config.defaultModel}:generateContent',
      queryParameters: {
        if ((this.config.apiKey ?? '').isNotEmpty) 'key': this.config.apiKey,
      },
      data: _requestBody(messages: messages, config: config),
    );
    final candidates = response.data?['candidates'] as List<dynamic>?;
    final first = candidates?.firstOrNull as Map<String, dynamic>?;
    final content = first?['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    final part = parts?.firstOrNull as Map<String, dynamic>?;
    return part?['text'] as String? ?? '';
  }

  @override
  Stream<LlmStreamEvent> streamGenerate({
    required List<ChatMessage> messages,
    required GenerationConfig config,
  }) async* {
    final response = await _dio.post<ResponseBody>(
      '/models/${this.config.defaultModel}:streamGenerateContent',
      queryParameters: {
        'alt': 'sse',
        if ((this.config.apiKey ?? '').isNotEmpty) 'key': this.config.apiKey,
      },
      data: _requestBody(messages: messages, config: config),
      options: Options(responseType: ResponseType.stream),
    );

    final responseBody = response.data;
    if (responseBody == null) {
      return;
    }

    await for (final decoded in decodeSseJson(responseBody)) {
      final candidates = decoded['candidates'];
      if (candidates is! List || candidates.isEmpty) {
        continue;
      }

      final first = candidates.first;
      if (first is! Map<String, dynamic>) {
        continue;
      }

      final content = first['content'];
      if (content is! Map<String, dynamic>) {
        continue;
      }

      final parts = content['parts'];
      if (parts is! List) {
        continue;
      }

      for (final part in parts) {
        if (part is! Map<String, dynamic>) {
          continue;
        }
        final text = part['text'];
        if (text is String && text.isNotEmpty) {
          yield LlmStreamEvent.text(text);
        }
        final thought = part['thought'];
        if (thought is String && thought.isNotEmpty) {
          yield LlmStreamEvent.reasoning(thought);
        }
      }
    }
  }

  Map<String, dynamic> _requestBody({
    required List<ChatMessage> messages,
    required GenerationConfig config,
  }) {
    return <String, dynamic>{
      'contents': [
        for (final message in messages)
          if (message.role != MessageRole.system)
            {
              'role': message.role == MessageRole.assistant ? 'model' : 'user',
              'parts': [
                {'text': message.content},
              ],
            },
      ],
      'generationConfig': {
        'temperature': config.temperature,
        'topP': config.topP,
        'maxOutputTokens': config.maxTokens,
        ..._thinkingConfig(config),
        if (config.stop != null) 'stopSequences': config.stop,
      },
      if (messages.any((message) => message.role == MessageRole.system))
        'systemInstruction': {
          'parts': [
            {
              'text': messages
                  .where((message) => message.role == MessageRole.system)
                  .map((message) => message.content)
                  .join('\n\n'),
            },
          ],
        },
    };
  }

  Map<String, dynamic> _thinkingConfig(GenerationConfig config) {
    final budget = switch (config.reasoningMode) {
      ReasoningMode.off => 0,
      ReasoningMode.automatic => null,
      ReasoningMode.low => 1024,
      ReasoningMode.medium => 4096,
      ReasoningMode.high => 8192,
    };
    if (budget == null) {
      return const <String, dynamic>{};
    }
    return {
      'thinkingConfig': {'thinkingBudget': budget},
    };
  }
}
