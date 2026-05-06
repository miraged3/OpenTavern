import 'chat_message.dart';
import 'conversation.dart';

Conversation normalizeConversationTree(Conversation conversation) {
  final normalizedMessages = <ChatMessage>[];
  final seenIds = <String>{};
  String? previousId;
  var changed = false;

  for (final message in conversation.messages) {
    final parentId = message.parentId;
    final hasValidParent = parentId == null || seenIds.contains(parentId);
    final normalizedParentId = hasValidParent ? parentId : previousId;
    if (normalizedParentId != parentId) {
      changed = true;
    }
    if (message.parentId == null && previousId != null) {
      changed = true;
      normalizedMessages.add(message.copyWith(parentId: previousId));
    } else {
      normalizedMessages.add(
        normalizedParentId == parentId
            ? message
            : message.copyWith(parentId: normalizedParentId),
      );
    }
    seenIds.add(message.id);
    previousId = message.id;
  }

  final activeLeafId = _validActiveLeafId(
    normalizedMessages,
    conversation.activeLeafMessageId,
  );
  if (activeLeafId != conversation.activeLeafMessageId) {
    changed = true;
  }

  if (!changed) {
    return conversation;
  }
  return conversation.copyWith(
    messages: normalizedMessages,
    activeLeafMessageId: activeLeafId,
  );
}

List<ChatMessage> activeConversationPath(Conversation conversation) {
  final normalized = normalizeConversationTree(conversation);
  if (normalized.messages.isEmpty) {
    return const <ChatMessage>[];
  }
  final byId = {for (final message in normalized.messages) message.id: message};
  final leafId =
      normalized.activeLeafMessageId ?? normalized.messages.lastOrNull?.id;
  final leaf = leafId == null ? null : byId[leafId];
  if (leaf == null) {
    return List<ChatMessage>.unmodifiable(normalized.messages);
  }

  final path = <ChatMessage>[];
  final visited = <String>{};
  ChatMessage? cursor = leaf;
  while (cursor != null && visited.add(cursor.id)) {
    path.add(cursor);
    cursor = cursor.parentId == null ? null : byId[cursor.parentId];
  }
  return List<ChatMessage>.unmodifiable(path.reversed);
}

String? activeConversationLeafId(Conversation conversation) {
  return activeConversationPath(conversation).lastOrNull?.id;
}

String? latestDescendantLeafId(Conversation conversation, String messageId) {
  final childrenByParent = _childrenByParent(conversation.messages);
  var cursorId = messageId;
  while (true) {
    final children = childrenByParent[cursorId] ?? const <ChatMessage>[];
    if (children.isEmpty) {
      return cursorId;
    }
    cursorId = children.last.id;
  }
}

MessageSiblingInfo siblingInfoForMessage(
  Conversation conversation,
  String messageId,
) {
  final message = conversation.messages
      .where((message) => message.id == messageId)
      .firstOrNull;
  if (message == null) {
    return const MessageSiblingInfo(index: 0, count: 1);
  }
  final siblings = conversation.messages
      .where((item) => item.parentId == message.parentId)
      .toList(growable: false);
  final index = siblings.indexWhere((item) => item.id == messageId);
  return MessageSiblingInfo(
    index: index == -1 ? 0 : index,
    count: siblings.isEmpty ? 1 : siblings.length,
    previousMessageId: index > 0 ? siblings[index - 1].id : null,
    nextMessageId: index >= 0 && index < siblings.length - 1
        ? siblings[index + 1].id
        : null,
  );
}

String? replacementLeafAfterDeletingMessage(
  Conversation conversation,
  String messageId,
) {
  final message = conversation.messages
      .where((message) => message.id == messageId)
      .firstOrNull;
  if (message == null) {
    return activeConversationLeafId(conversation);
  }

  final siblingInfo = siblingInfoForMessage(conversation, messageId);
  final replacementSiblingId =
      siblingInfo.nextMessageId ?? siblingInfo.previousMessageId;
  if (replacementSiblingId != null) {
    return latestDescendantLeafId(conversation, replacementSiblingId);
  }

  final parentId = message.parentId;
  if (parentId != null &&
      conversation.messages.any((message) => message.id == parentId)) {
    return parentId;
  }

  final deletedIds = {
    messageId,
    for (final descendant in descendantsOfMessage(conversation, messageId))
      descendant.id,
  };
  return conversation.messages
      .where((message) => !deletedIds.contains(message.id))
      .lastOrNull
      ?.id;
}

List<ChatMessage> descendantsOfMessage(
  Conversation conversation,
  String messageId,
) {
  final childrenByParent = _childrenByParent(conversation.messages);
  final descendants = <ChatMessage>[];
  final stack = <ChatMessage>[...?childrenByParent[messageId]];
  while (stack.isNotEmpty) {
    final message = stack.removeLast();
    descendants.add(message);
    stack.addAll(childrenByParent[message.id] ?? const <ChatMessage>[]);
  }
  return descendants;
}

Map<String, List<ChatMessage>> _childrenByParent(List<ChatMessage> messages) {
  final childrenByParent = <String, List<ChatMessage>>{};
  for (final message in messages) {
    final parentId = message.parentId;
    if (parentId == null) {
      continue;
    }
    childrenByParent.putIfAbsent(parentId, () => <ChatMessage>[]).add(message);
  }
  return childrenByParent;
}

String? _validActiveLeafId(List<ChatMessage> messages, String? activeLeafId) {
  if (messages.isEmpty) {
    return null;
  }
  if (activeLeafId != null &&
      messages.any((message) => message.id == activeLeafId)) {
    return activeLeafId;
  }
  return messages.last.id;
}

class MessageSiblingInfo {
  const MessageSiblingInfo({
    required this.index,
    required this.count,
    this.previousMessageId,
    this.nextMessageId,
  });

  final int index;
  final int count;
  final String? previousMessageId;
  final String? nextMessageId;

  bool get hasSiblings => count > 1;
}
