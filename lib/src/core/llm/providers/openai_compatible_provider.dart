import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../../models/chat_message.dart';
import '../../models/generation_config.dart';
import '../../models/provider_config.dart';
import '../llm_provider.dart';
import '../llm_stream_event.dart';
import 'endpoint_format_helpers.dart';

class OpenAiCompatibleProvider extends LlmProvider {
  OpenAiCompatibleProvider(super.config)
    : _dio = Dio(
        BaseOptions(
          baseUrl: config.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
          headers: {
            if ((config.apiKey ?? '').isNotEmpty)
              'Authorization': 'Bearer ${config.apiKey}',
          },
        ),
      );

  final Dio _dio;

  @override
  Future<List<String>> listModels() async {
    if (config.type == ProviderType.ollama || _looksLikeOllamaEndpoint()) {
      return _listOllamaModels();
    }

    return _listOpenAiModels();
  }

  bool _looksLikeOllamaEndpoint() {
    final uri = Uri.tryParse(config.baseUrl);
    if (uri == null) {
      return false;
    }

    return uri.port == 11434 || uri.host.toLowerCase().contains('ollama');
  }

  Future<List<String>> _listOpenAiModels() async {
    final response = await _dio.get<Map<String, dynamic>>('/models');
    final data = response.data?['data'] as List<dynamic>?;
    return [
      for (final item in data ?? const <dynamic>[])
        if (item is Map<String, dynamic> && item['id'] is String)
          item['id'] as String,
    ];
  }

  Future<List<String>> _listOllamaModels() async {
    var url = '/api/tags';
    final baseUri = Uri.tryParse(config.baseUrl);
    if (baseUri != null && baseUri.path.endsWith('/v1')) {
      final cleanPath = baseUri.path.substring(0, baseUri.path.length - 3);
      final cleanUri = baseUri.replace(
        path: cleanPath.isEmpty ? '' : cleanPath,
      );
      url = '${cleanUri.toString()}/api/tags';
    }

    final response = await _dio.get<Map<String, dynamic>>(url);
    final payload = response.data;
    final models = (payload?['models'] ?? payload?['data']) as List<dynamic>?;
    return [
      for (final item in models ?? const <dynamic>[])
        if (item is Map<String, dynamic>)
          (item['name'] ?? item['model'] ?? item['id']) as String?,
    ].whereType<String>().toList(growable: false);
  }

  /// 把 system 消息合并到第一条 user 消息中。
  /// 很多第三方 OpenAI 兼容代理/中转不支持 role: system，
  /// 把系统提示词放在 user 消息里是最兼容的做法。
  List<Map<String, String>> _openAiCompatibleMessages(
    List<ChatMessage> messages,
  ) {
    final systemParts = <String>[];
    final others = <ChatMessage>[];

    for (final message in messages) {
      if (message.role == MessageRole.system) {
        systemParts.add(message.content);
      } else {
        others.add(message);
      }
    }

    if (systemParts.isEmpty) {
      return openAiMessages(others);
    }

    final systemText = systemParts.join('\n\n');
    final firstIndex = others.indexWhere((m) => m.role == MessageRole.user);
    if (firstIndex != -1) {
      final first = others[firstIndex];
      others[firstIndex] = ChatMessage(
        id: first.id,
        role: first.role,
        content: '$systemText\n\n---\n\n${first.content}',
        timestamp: first.timestamp,
        isTemplate: first.isTemplate,
      );
    } else {
      others.insert(
        0,
        ChatMessage(
          id: 'sys-converted',
          role: MessageRole.user,
          content: systemText,
          timestamp: DateTime.now(),
        ),
      );
    }

    return openAiMessages(others);
  }

  @override
  Future<String> generate({
    required List<ChatMessage> messages,
    required GenerationConfig config,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/chat/completions',
      data: {
        'model': this.config.defaultModel,
        'messages': _openAiCompatibleMessages(messages),
        'temperature': config.temperature,
        'top_p': config.topP,
        'max_tokens': config.maxTokens,
        ..._reasoningOptions(config),
        if (config.stop != null) 'stop': config.stop,
      },
    );
    final choices = response.data?['choices'] as List<dynamic>?;
    final first = choices?.firstOrNull as Map<String, dynamic>?;
    final message = first?['message'] as Map<String, dynamic>?;
    return message?['content'] as String? ??
        message?['reasoning'] as String? ??
        '';
  }

  @override
  Stream<LlmStreamEvent> streamGenerate({
    required List<ChatMessage> messages,
    required GenerationConfig config,
  }) async* {
    final response = await _dio.post<ResponseBody>(
      '/chat/completions',
      data: {
        'model': this.config.defaultModel,
        'messages': _openAiCompatibleMessages(messages),
        'temperature': config.temperature,
        'top_p': config.topP,
        'max_tokens': config.maxTokens,
        ..._reasoningOptions(config),
        'stream': true,
        if (config.stop != null) 'stop': config.stop,
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

      final choices = decoded['choices'];
      if (choices is! List || choices.isEmpty) {
        continue;
      }

      final first = choices.first;
      if (first is! Map<String, dynamic>) {
        continue;
      }

      final delta = first['delta'];
      if (delta is Map<String, dynamic>) {
        final content = delta['content'];
        if (content is String && content.isNotEmpty) {
          yield LlmStreamEvent.text(content);
          continue;
        }
        final reasoning = delta['reasoning'];
        if (reasoning is String && reasoning.isNotEmpty) {
          yield LlmStreamEvent.reasoning(reasoning);
          continue;
        }
      }

      final message = first['message'];
      if (message is Map<String, dynamic>) {
        final content = message['content'];
        if (content is String && content.isNotEmpty) {
          yield LlmStreamEvent.text(content);
        }
        final reasoning = message['reasoning'];
        if (reasoning is String && reasoning.isNotEmpty) {
          yield LlmStreamEvent.reasoning(reasoning);
        }
      }
    }
  }

  Map<String, dynamic> _reasoningOptions(GenerationConfig config) {
    return switch (config.reasoningMode) {
      ReasoningMode.off => {'include_reasoning': false},
      ReasoningMode.automatic => const <String, dynamic>{},
      ReasoningMode.low => {
        'reasoning_effort': 'low',
        'include_reasoning': true,
      },
      ReasoningMode.medium => {
        'reasoning_effort': 'medium',
        'include_reasoning': true,
      },
      ReasoningMode.high => {
        'reasoning_effort': 'high',
        'include_reasoning': true,
      },
    };
  }

  Dio get client => _dio;
}
