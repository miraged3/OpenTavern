import 'character.dart';
import 'chat_message.dart';
import 'generation_config.dart';

class Conversation {
  const Conversation({
    required this.id,
    required this.character,
    required this.messages,
    required this.userPersonaId,
    this.modelEndpointId,
    this.generationConfig,
    required this.updatedAt,
  });

  final String id;
  final Character character;
  final List<ChatMessage> messages;
  final String? userPersonaId;
  final String? modelEndpointId;
  final GenerationConfig? generationConfig;
  final DateTime updatedAt;

  Conversation copyWith({
    String? id,
    Character? character,
    List<ChatMessage>? messages,
    String? userPersonaId,
    String? modelEndpointId,
    Object? generationConfig = _unset,
    DateTime? updatedAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      character: character ?? this.character,
      messages: messages ?? this.messages,
      userPersonaId: userPersonaId ?? this.userPersonaId,
      modelEndpointId: modelEndpointId ?? this.modelEndpointId,
      generationConfig: generationConfig == _unset
          ? this.generationConfig
          : generationConfig as GenerationConfig?,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      character: Character.fromJson(
        Map<String, dynamic>.from(json['character'] as Map),
      ),
      messages: [
        for (final item
            in (json['messages'] as List<dynamic>? ?? const <dynamic>[]))
          if (item is Map)
            ChatMessage.fromJson(Map<String, dynamic>.from(item)),
      ],
      userPersonaId: json['userPersonaId'] as String?,
      modelEndpointId: json['modelEndpointId'] as String?,
      generationConfig: json['generationConfig'] is Map
          ? GenerationConfig.fromJson(
              Map<String, dynamic>.from(json['generationConfig'] as Map),
            )
          : null,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'character': character.toJson(),
      'messages': [for (final message in messages) message.toJson()],
      'userPersonaId': userPersonaId,
      'modelEndpointId': modelEndpointId,
      'generationConfig': generationConfig?.toJson(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

const Object _unset = Object();
