import '../models/character.dart';
import '../models/chat_message.dart';
import '../models/conversation.dart';
import '../models/user_persona.dart';

const String defaultUserName = 'User';
const String defaultUserPersonaId = 'persona-default';

UserPersona defaultUserPersona() {
  final now = DateTime.now();
  return UserPersona(
    id: defaultUserPersonaId,
    name: defaultUserName,
    description: '',
    profilePrompt: '',
    isDefault: true,
    createdAt: now,
    updatedAt: now,
  );
}

String renderCharacterCardText(
  String raw, {
  required Character character,
  required UserPersona userPersona,
}) {
  if (raw.isEmpty) {
    return raw;
  }

  var rendered = raw;
  final replacements = <Pattern, String>{
    RegExp(r'\{\{\s*char\s*\}\}', caseSensitive: false): character.name,
    RegExp(r'\{\{\s*bot\s*\}\}', caseSensitive: false): character.name,
    RegExp(r'\{\{\s*char_name\s*\}\}', caseSensitive: false): character.name,
    RegExp(r'\{\{\s*bot_name\s*\}\}', caseSensitive: false): character.name,
    RegExp(r'<\s*BOT\s*>', caseSensitive: false): character.name,
    RegExp(r'<\s*CHAR\s*>', caseSensitive: false): character.name,
    RegExp(r'<\s*CHAR_NAME\s*>', caseSensitive: false): character.name,
    RegExp(r'\{\{\s*user\s*\}\}', caseSensitive: false): userPersona.name,
    RegExp(r'\{\{\s*username\s*\}\}', caseSensitive: false): userPersona.name,
    RegExp(r'\{\{\s*user_name\s*\}\}', caseSensitive: false): userPersona.name,
    RegExp(r'\{\{\s*persona\s*\}\}', caseSensitive: false): userPersona.name,
    RegExp(r'<\s*USER\s*>', caseSensitive: false): userPersona.name,
    RegExp(r'<\s*USERNAME\s*>', caseSensitive: false): userPersona.name,
  };

  for (final entry in replacements.entries) {
    rendered = rendered.replaceAll(entry.key, entry.value);
  }

  return rendered;
}

/// 提示词区块，[depth] 控制注入位置：
/// - 0: 放在对话顶部（作为 system 消息）
/// - N (>0): 插入到历史倒数第 N 条消息之前
/// - -1: 放在对话末尾
class _PromptBlock {
  const _PromptBlock({required this.content, this.depth = 0});

  final String content;
  final int depth;
}

List<_PromptBlock> _buildPromptBlocks(
  Character character, {
  required UserPersona userPersona,
}) {
  final blocks = <_PromptBlock>[];

  String render(String? text) {
    if (text == null || text.trim().isEmpty) {
      return '';
    }
    return renderCharacterCardText(
      text.trim(),
      character: character,
      userPersona: userPersona,
    );
  }

  // 第一层：核心身份指令
  blocks.add(
    _PromptBlock(
      content:
          'You are ${character.name}. Stay in character and respond as ${character.name}.\n${userPersona.name} is the user you are talking to.',
      depth: 0,
    ),
  );

  // 第二层：角色定义
  final description = render(character.description);
  final personality = render(character.personality);
  final scenario = render(character.scenario);
  if (description.isNotEmpty || personality.isNotEmpty || scenario.isNotEmpty) {
    final parts = <String>[];
    if (description.isNotEmpty) {
      parts.add('Character description:\n$description');
    }
    if (personality.isNotEmpty) {
      parts.add('Personality:\n$personality');
    }
    if (scenario.isNotEmpty) {
      parts.add('Scenario:\n$scenario');
    }
    blocks.add(_PromptBlock(content: parts.join('\n\n'), depth: 0));
  }

  // 第三层：用户定义
  final userDesc = render(userPersona.description);
  final userPrompt = render(userPersona.profilePrompt);
  if (userDesc.isNotEmpty || userPrompt.isNotEmpty) {
    final parts = <String>[];
    if (userDesc.isNotEmpty) {
      parts.add('User description:\n$userDesc');
    }
    if (userPrompt.isNotEmpty) {
      parts.add('User persona:\n$userPrompt');
    }
    blocks.add(_PromptBlock(content: parts.join('\n\n'), depth: 0));
  }

  // 第四层：作者备注
  final creatorNotes = render(character.creatorNotes);
  if (creatorNotes.isNotEmpty) {
    blocks.add(_PromptBlock(content: 'Author notes:\n$creatorNotes', depth: 0));
  }

  // 第五层：系统提示词
  final systemPrompt = render(character.systemPrompt);
  if (systemPrompt.isNotEmpty) {
    blocks.add(_PromptBlock(content: systemPrompt, depth: 0));
  }

  // 第六层：示例对话
  final exampleMessages = render(character.exampleMessages);
  if (exampleMessages.isNotEmpty) {
    final formatted = _formatExampleDialogue(exampleMessages);
    blocks.add(
      _PromptBlock(content: 'Example dialogue:\n$formatted', depth: 0),
    );
  }

  // 第七层：后 history 指令（depth 4，在历史倒数第 4 条前重复）
  final postHistory = render(character.postHistoryInstructions);
  if (postHistory.isNotEmpty) {
    blocks.add(
      _PromptBlock(
        content: 'Post-history instructions:\n$postHistory',
        depth: 4,
      ),
    );
  }

  // 程序级禁令：禁止模型扮演GM或向用户提问
  blocks.add(
    _PromptBlock(
      content:
          'You must ONLY speak and act as ${character.name}. '
          'You are NEVER a narrator, game master, or storyteller. '
          'Do NOT describe the scene objectively or from an outside perspective. '
          'Do NOT ask the user what they want to do, how they respond, or present options. '
          'Do NOT end your message with questions. '
          'Always stay in character and drive the scene forward through your own actions, dialogue, and thoughts.',
      depth: 0,
    ),
  );

  return blocks;
}

String _formatExampleDialogue(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return '';
  }

  // 如果已经包含 <START>，说明已经格式化好了
  if (trimmed.toUpperCase().contains('<START>')) {
    return trimmed;
  }

  // 否则按空行分段，每段加 <START> 包裹
  final lines = trimmed.split('\n');
  final segments = <String>[];
  final buffer = <String>[];

  void flush() {
    if (buffer.isNotEmpty) {
      final segment = buffer.join('\n').trim();
      if (segment.isNotEmpty) {
        segments.add(segment);
      }
      buffer.clear();
    }
  }

  for (final line in lines) {
    if (line.trim().isEmpty) {
      flush();
    } else {
      buffer.add(line);
    }
  }
  flush();

  if (segments.isEmpty) {
    return trimmed;
  }

  return segments.map((s) => '<START>\n$s').join('\n\n');
}

String pickCharacterGreetingTemplate(Character character) {
  return character.firstMessage.trim().isNotEmpty
      ? character.firstMessage
      : character.alternateGreetings.firstWhere(
          (item) => item.trim().isNotEmpty,
          orElse: () => '',
        );
}

List<ChatMessage> buildConversationMessagesForModel(
  Conversation conversation, {
  required UserPersona userPersona,
}) {
  final timestamp = DateTime.now();
  final blocks = _buildPromptBlocks(
    conversation.character,
    userPersona: userPersona,
  );

  // 分离不同深度的区块
  final topBlocks = blocks.where((b) => b.depth == 0).toList();
  final deepBlocks = blocks.where((b) => b.depth > 0).toList();
  final endBlocks = blocks.where((b) => b.depth == -1).toList();

  // depth 0: 合并为一条 system 消息放在顶部
  // 很多 OpenAI 兼容接口只支持/只读取第一条 system 消息
  final topContent = topBlocks
      .map((b) => b.content.trim())
      .where((c) => c.isNotEmpty)
      .join('\n\n');
  final topMessages = topContent.isNotEmpty
      ? [
          ChatMessage(
            id: 'sys-top-${timestamp.microsecondsSinceEpoch}',
            role: MessageRole.system,
            content: topContent,
            timestamp: timestamp,
          ),
        ]
      : <ChatMessage>[];

  // 处理历史消息，先做变量替换
  final historyMessages = <ChatMessage>[
    for (final message in conversation.messages)
      if (message.role != MessageRole.system)
        ChatMessage(
          id: message.id,
          role: message.role,
          content: message.isTemplate
              ? renderCharacterCardText(
                  message.content,
                  character: conversation.character,
                  userPersona: userPersona,
                )
              : message.content,
          timestamp: message.timestamp,
          isTemplate: message.isTemplate,
        ),
  ];

  // depth > 0: 插入到历史倒数第 depth 条之前
  // 基于原始历史长度计算位置，从后往前插入避免索引偏移
  final originalLength = historyMessages.length;
  final insertions = <int, List<String>>{}; // position -> contents

  for (final block in deepBlocks) {
    final pos = originalLength >= block.depth
        ? originalLength - block.depth
        : 0;
    insertions.putIfAbsent(pos, () => []).add(block.content.trim());
  }

  final sortedPositions = insertions.keys.toList()
    ..sort((a, b) => b.compareTo(a)); // 从大到小，从后往前插入

  var workingHistory = List<ChatMessage>.from(historyMessages);
  for (final pos in sortedPositions) {
    final content = insertions[pos]!.where((c) => c.isNotEmpty).join('\n\n');
    if (content.isEmpty) continue;

    workingHistory.insert(
      pos,
      ChatMessage(
        id: 'sys-deep-${timestamp.microsecondsSinceEpoch}-$pos',
        role: MessageRole.system,
        content: content,
        timestamp: timestamp,
      ),
    );
  }

  // depth -1: 放在末尾
  final endMessages = <ChatMessage>[
    for (var i = 0; i < endBlocks.length; i++)
      if (endBlocks[i].content.trim().isNotEmpty)
        ChatMessage(
          id: 'sys-end-${timestamp.microsecondsSinceEpoch}-$i',
          role: MessageRole.system,
          content: endBlocks[i].content.trim(),
          timestamp: timestamp,
        ),
  ];

  return [
    ...topMessages,
    ...workingHistory,
    ...endMessages,
  ].toList(growable: false);
}
