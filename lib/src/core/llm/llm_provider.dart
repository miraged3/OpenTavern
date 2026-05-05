import '../models/chat_message.dart';
import '../models/generation_config.dart';
import '../models/provider_config.dart';
import 'llm_stream_event.dart';

abstract class LlmProvider {
  const LlmProvider(this.config);

  final ProviderConfig config;

  String get name => config.label;

  Future<List<String>> listModels();

  Future<String> generate({
    required List<ChatMessage> messages,
    required GenerationConfig config,
  });

  Stream<LlmStreamEvent> streamGenerate({
    required List<ChatMessage> messages,
    required GenerationConfig config,
  });
}
