enum MessageRole { user, assistant, system }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isTemplate = false,
    this.isPending = false,
    this.reasoning = '',
    this.parentId,
  });

  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final bool isTemplate;
  final bool isPending;
  final String reasoning;
  final String? parentId;

  ChatMessage copyWith({
    String? id,
    MessageRole? role,
    String? content,
    DateTime? timestamp,
    bool? isTemplate,
    bool? isPending,
    String? reasoning,
    Object? parentId = _unset,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isTemplate: isTemplate ?? this.isTemplate,
      isPending: isPending ?? this.isPending,
      reasoning: reasoning ?? this.reasoning,
      parentId: parentId == _unset ? this.parentId : parentId as String?,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      role: MessageRole.values.byName(json['role'] as String),
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isTemplate: json['isTemplate'] as bool? ?? false,
      isPending: json['isPending'] as bool? ?? false,
      reasoning: json['reasoning'] as String? ?? '',
      parentId: json['parentId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'role': role.name,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isTemplate': isTemplate,
      'isPending': isPending,
      'reasoning': reasoning,
      'parentId': parentId,
    };
  }
}

const Object _unset = Object();
