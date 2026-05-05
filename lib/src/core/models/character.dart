enum CharacterImportFormat { manual, jsonV1, jsonV2, pngV1, pngV2, siteImport }

class Character {
  const Character({
    required this.id,
    required this.name,
    required this.description,
    required this.personality,
    required this.scenario,
    required this.firstMessage,
    required this.avatar,
    this.avatarImagePath,
    this.avatarImageBase64,
    required this.tags,
    this.creator,
    this.creatorNotes,
    this.systemPrompt,
    this.postHistoryInstructions,
    this.alternateGreetings = const <String>[],
    this.exampleMessages,
    this.extensions = const <String, dynamic>{},
    this.sourceFormat = CharacterImportFormat.manual,
    this.sourceSite,
    this.sourceUrl,
    this.importedAt,
    this.rawCardJson,
    this.isFavorite = false,
    this.createdAt,
    this.updatedAt,
    this.lastUsedAt,
  });

  final String id;
  final String name;
  final String description;
  final String personality;
  final String scenario;
  final String firstMessage;
  final String avatar;
  final String? avatarImagePath;
  final String? avatarImageBase64;
  final List<String> tags;
  final String? creator;
  final String? creatorNotes;
  final String? systemPrompt;
  final String? postHistoryInstructions;
  final List<String> alternateGreetings;
  final String? exampleMessages;
  final Map<String, dynamic> extensions;
  final CharacterImportFormat sourceFormat;
  final String? sourceSite;
  final String? sourceUrl;
  final DateTime? importedAt;
  final String? rawCardJson;
  final bool isFavorite;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastUsedAt;

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      personality: json['personality'] as String? ?? '',
      scenario: json['scenario'] as String? ?? '',
      firstMessage: json['firstMessage'] as String? ?? '',
      avatar: json['avatar'] as String? ?? 'C',
      avatarImagePath: json['avatarImagePath'] as String?,
      avatarImageBase64: json['avatarImageBase64'] as String?,
      tags: [
        for (final item
            in (json['tags'] as List<dynamic>? ?? const <dynamic>[]))
          if (item is String && item.trim().isNotEmpty) item.trim(),
      ],
      creator: json['creator'] as String?,
      creatorNotes: json['creatorNotes'] as String?,
      systemPrompt: json['systemPrompt'] as String?,
      postHistoryInstructions: json['postHistoryInstructions'] as String?,
      alternateGreetings: [
        for (final item
            in (json['alternateGreetings'] as List<dynamic>? ??
                const <dynamic>[]))
          if (item is String && item.trim().isNotEmpty) item,
      ],
      exampleMessages: json['exampleMessages'] as String?,
      extensions: json['extensions'] is Map
          ? Map<String, dynamic>.from(json['extensions'] as Map)
          : const <String, dynamic>{},
      sourceFormat: json['sourceFormat'] == null
          ? CharacterImportFormat.manual
          : CharacterImportFormat.values.byName(json['sourceFormat'] as String),
      sourceSite: json['sourceSite'] as String?,
      sourceUrl: json['sourceUrl'] as String?,
      importedAt: json['importedAt'] == null
          ? null
          : DateTime.tryParse(json['importedAt'] as String),
      rawCardJson: json['rawCardJson'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.tryParse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.tryParse(json['updatedAt'] as String),
      lastUsedAt: json['lastUsedAt'] == null
          ? null
          : DateTime.tryParse(json['lastUsedAt'] as String),
    );
  }

  Character copyWith({
    String? id,
    String? name,
    String? description,
    String? personality,
    String? scenario,
    String? firstMessage,
    String? avatar,
    String? avatarImagePath,
    bool clearAvatarImagePath = false,
    String? avatarImageBase64,
    bool clearAvatarImageBase64 = false,
    List<String>? tags,
    String? creator,
    bool clearCreator = false,
    String? creatorNotes,
    bool clearCreatorNotes = false,
    String? systemPrompt,
    bool clearSystemPrompt = false,
    String? postHistoryInstructions,
    bool clearPostHistoryInstructions = false,
    List<String>? alternateGreetings,
    String? exampleMessages,
    bool clearExampleMessages = false,
    Map<String, dynamic>? extensions,
    CharacterImportFormat? sourceFormat,
    String? sourceSite,
    bool clearSourceSite = false,
    String? sourceUrl,
    bool clearSourceUrl = false,
    DateTime? importedAt,
    bool clearImportedAt = false,
    String? rawCardJson,
    bool clearRawCardJson = false,
    bool? isFavorite,
    DateTime? createdAt,
    bool clearCreatedAt = false,
    DateTime? updatedAt,
    bool clearUpdatedAt = false,
    DateTime? lastUsedAt,
    bool clearLastUsedAt = false,
  }) {
    return Character(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      personality: personality ?? this.personality,
      scenario: scenario ?? this.scenario,
      firstMessage: firstMessage ?? this.firstMessage,
      avatar: avatar ?? this.avatar,
      avatarImagePath: clearAvatarImagePath
          ? null
          : avatarImagePath ?? this.avatarImagePath,
      avatarImageBase64: clearAvatarImageBase64
          ? null
          : avatarImageBase64 ?? this.avatarImageBase64,
      tags: tags ?? this.tags,
      creator: clearCreator ? null : creator ?? this.creator,
      creatorNotes: clearCreatorNotes
          ? null
          : creatorNotes ?? this.creatorNotes,
      systemPrompt: clearSystemPrompt
          ? null
          : systemPrompt ?? this.systemPrompt,
      postHistoryInstructions: clearPostHistoryInstructions
          ? null
          : postHistoryInstructions ?? this.postHistoryInstructions,
      alternateGreetings: alternateGreetings ?? this.alternateGreetings,
      exampleMessages: clearExampleMessages
          ? null
          : exampleMessages ?? this.exampleMessages,
      extensions: extensions ?? this.extensions,
      sourceFormat: sourceFormat ?? this.sourceFormat,
      sourceSite: clearSourceSite ? null : sourceSite ?? this.sourceSite,
      sourceUrl: clearSourceUrl ? null : sourceUrl ?? this.sourceUrl,
      importedAt: clearImportedAt ? null : importedAt ?? this.importedAt,
      rawCardJson: clearRawCardJson ? null : rawCardJson ?? this.rawCardJson,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: clearCreatedAt ? null : createdAt ?? this.createdAt,
      updatedAt: clearUpdatedAt ? null : updatedAt ?? this.updatedAt,
      lastUsedAt: clearLastUsedAt ? null : lastUsedAt ?? this.lastUsedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'personality': personality,
      'scenario': scenario,
      'firstMessage': firstMessage,
      'avatar': avatar,
      'avatarImagePath': avatarImagePath,
      'avatarImageBase64': avatarImageBase64,
      'tags': tags,
      'creator': creator,
      'creatorNotes': creatorNotes,
      'systemPrompt': systemPrompt,
      'postHistoryInstructions': postHistoryInstructions,
      'alternateGreetings': alternateGreetings,
      'exampleMessages': exampleMessages,
      'extensions': extensions,
      'sourceFormat': sourceFormat.name,
      'sourceSite': sourceSite,
      'sourceUrl': sourceUrl,
      'importedAt': importedAt?.toIso8601String(),
      'rawCardJson': rawCardJson,
      'isFavorite': isFavorite,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastUsedAt': lastUsedAt?.toIso8601String(),
    };
  }
}
