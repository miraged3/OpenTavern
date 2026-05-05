import '../../models/chat_message.dart';

String roleName(MessageRole role) {
  return switch (role) {
    MessageRole.user => 'user',
    MessageRole.assistant => 'assistant',
    MessageRole.system => 'system',
  };
}

List<Map<String, String>> openAiMessages(List<ChatMessage> messages) {
  return [
    for (final message in messages)
      {'role': roleName(message.role), 'content': message.content},
  ];
}
