import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../../models/chat_message.dart';
import '../../models/generation_config.dart';
import '../llm_provider.dart';
import '../llm_stream_event.dart';
import 'endpoint_format_helpers.dart';

class CohereV2ChatProvider extends LlmProvider {
  CohereV2ChatProvider(super.config)
    : _dio = Dio(
        BaseOptions(
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
    final response = await _dio.get<Map<String, dynamic>>('/v1/models');
    final models = response.data?['models'] as List<dynamic>?;
    return [
      for (final item in models ?? const <dynamic>[])
        if (item is Map<String, dynamic> && item['name'] is String)
          item['name'] as String,
    ];
  }

  @override
  Future<String> generate({
    required List<ChatMessage> messages,
    required GenerationConfig config,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/v2/chat',
      data: {
        'model': this.config.defaultModel,
        'messages': openAiMessages(messages),
        'stream': false,
        'temperature': config.temperature,
        'p': config.topP,
        'max_tokens': config.maxTokens,
      },
    );
    final message = response.data?['message'] as Map<String, dynamic>?;
    final content = message?['content'] as List<dynamic>?;
    final first = content?.firstOrNull as Map<String, dynamic>?;
    return first?['text'] as String? ?? '';
  }

  @override
  Stream<LlmStreamEvent> streamGenerate({
    required List<ChatMessage> messages,
    required GenerationConfig config,
  }) async* {
    final response = await _dio.post<ResponseBody>(
      '/v2/chat',
      data: {
        'model': this.config.defaultModel,
        'messages': openAiMessages(messages),
        'stream': true,
        'temperature': config.temperature,
        'p': config.topP,
        'max_tokens': config.maxTokens,
      },
      options: Options(responseType: ResponseType.stream),
    );

    final responseBody = response.data;
    if (responseBody == null) {
      return;
    }

    await for (final line
        in utf8.decoder
            .bind(responseBody.stream)
            .transform(const LineSplitter())) {
      final trimmed = line.trim();
      if (!trimmed.startsWith('data:')) {
        continue;
      }

      final payload = trimmed.substring(5).trim();
      if (payload.isEmpty || payload == '[DONE]') {
        continue;
      }

      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) {
        continue;
      }

      final type = decoded['type'];
      if (type == 'content-delta') {
        final delta = decoded['delta'];
        if (delta is Map<String, dynamic>) {
          final message = delta['message'];
          if (message is Map<String, dynamic>) {
            final content = message['content'];
            if (content is Map<String, dynamic>) {
              final text = content['text'];
              if (text is String && text.isNotEmpty) {
                yield LlmStreamEvent.text(text);
              }
            }
          }
        }
        continue;
      }

      final message = decoded['message'];
      if (message is Map<String, dynamic>) {
        final content = message['content'];
        if (content is List) {
          for (final item in content) {
            if (item is! Map<String, dynamic>) {
              continue;
            }
            final text = item['text'];
            if (text is String && text.isNotEmpty) {
              yield LlmStreamEvent.text(text);
            }
          }
        }
      }
    }
  }
}
