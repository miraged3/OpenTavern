import 'package:flutter_test/flutter_test.dart';
import 'package:open_tavern/src/core/models/character.dart';
import 'package:open_tavern/src/core/models/chat_message.dart';
import 'package:open_tavern/src/core/models/conversation.dart';
import 'package:open_tavern/src/core/models/conversation_tree.dart';

void main() {
  test('normalizes legacy linear messages into a parent chain', () {
    final now = DateTime(2026);
    final conversation = Conversation(
      id: 'conv',
      character: _character,
      messages: [
        ChatMessage(
          id: 'a',
          role: MessageRole.assistant,
          content: 'hello',
          timestamp: now,
        ),
        ChatMessage(
          id: 'u',
          role: MessageRole.user,
          content: 'hi',
          timestamp: now,
        ),
        ChatMessage(
          id: 'b',
          role: MessageRole.assistant,
          content: 'reply',
          timestamp: now,
        ),
      ],
      userPersonaId: null,
      updatedAt: now,
    );

    final normalized = normalizeConversationTree(conversation);

    expect(normalized.messages.map((message) => message.parentId), [
      null,
      'a',
      'u',
    ]);
    expect(normalized.activeLeafMessageId, 'b');
    expect(activeConversationPath(normalized).map((message) => message.id), [
      'a',
      'u',
      'b',
    ]);
  });

  test('active path follows the selected reply branch', () {
    final now = DateTime(2026);
    final conversation = Conversation(
      id: 'conv',
      character: _character,
      messages: [
        ChatMessage(
          id: 'a',
          role: MessageRole.assistant,
          content: 'hello',
          timestamp: now,
        ),
        ChatMessage(
          id: 'u',
          role: MessageRole.user,
          content: 'hi',
          timestamp: now,
          parentId: 'a',
        ),
        ChatMessage(
          id: 'b1',
          role: MessageRole.assistant,
          content: 'first',
          timestamp: now,
          parentId: 'u',
        ),
        ChatMessage(
          id: 'b2',
          role: MessageRole.assistant,
          content: 'second',
          timestamp: now,
          parentId: 'u',
        ),
      ],
      userPersonaId: null,
      activeLeafMessageId: 'b2',
      updatedAt: now,
    );

    expect(activeConversationPath(conversation).map((message) => message.id), [
      'a',
      'u',
      'b2',
    ]);

    final siblings = siblingInfoForMessage(conversation, 'b2');
    expect(siblings.index, 1);
    expect(siblings.count, 2);
    expect(siblings.previousMessageId, 'b1');
  });

  test('deleting one assistant reply selects the adjacent sibling reply', () {
    final now = DateTime(2026);
    final conversation = Conversation(
      id: 'conv',
      character: _character,
      messages: [
        ChatMessage(
          id: 'a',
          role: MessageRole.assistant,
          content: 'hello',
          timestamp: now,
        ),
        ChatMessage(
          id: 'u',
          role: MessageRole.user,
          content: 'hi',
          timestamp: now,
          parentId: 'a',
        ),
        ChatMessage(
          id: 'b1',
          role: MessageRole.assistant,
          content: 'first',
          timestamp: now,
          parentId: 'u',
        ),
        ChatMessage(
          id: 'b2',
          role: MessageRole.assistant,
          content: 'second',
          timestamp: now,
          parentId: 'u',
        ),
      ],
      userPersonaId: null,
      activeLeafMessageId: 'b1',
      updatedAt: now,
    );

    final replacementLeaf = replacementLeafAfterDeletingMessage(
      conversation,
      'b1',
    );
    final next = conversation.copyWith(
      messages: [
        for (final message in conversation.messages)
          if (message.id != 'b1') message,
      ],
      activeLeafMessageId: replacementLeaf,
    );

    expect(replacementLeaf, 'b2');
    expect(activeConversationPath(next).map((message) => message.id), [
      'a',
      'u',
      'b2',
    ]);
  });
}

const _character = Character(
  id: 'char',
  name: 'Character',
  description: '',
  personality: '',
  scenario: '',
  firstMessage: '',
  avatar: 'C',
  tags: <String>[],
);
