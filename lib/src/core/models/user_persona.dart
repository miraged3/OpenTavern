class UserPersona {
  const UserPersona({
    required this.id,
    required this.name,
    required this.description,
    required this.profilePrompt,
    this.avatarImagePath,
    this.avatarImageBase64,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String description;
  final String profilePrompt;
  final String? avatarImagePath;
  final String? avatarImageBase64;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory UserPersona.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return UserPersona(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'User',
      description: json['description'] as String? ?? '',
      profilePrompt: json['profilePrompt'] as String? ?? '',
      avatarImagePath: json['avatarImagePath'] as String?,
      avatarImageBase64: json['avatarImageBase64'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? now
          : DateTime.tryParse(json['createdAt'] as String) ?? now,
      updatedAt: json['updatedAt'] == null
          ? now
          : DateTime.tryParse(json['updatedAt'] as String) ?? now,
    );
  }

  UserPersona copyWith({
    String? id,
    String? name,
    String? description,
    String? profilePrompt,
    String? avatarImagePath,
    bool clearAvatarImagePath = false,
    String? avatarImageBase64,
    bool clearAvatarImageBase64 = false,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserPersona(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      profilePrompt: profilePrompt ?? this.profilePrompt,
      avatarImagePath: clearAvatarImagePath
          ? null
          : avatarImagePath ?? this.avatarImagePath,
      avatarImageBase64: clearAvatarImageBase64
          ? null
          : avatarImageBase64 ?? this.avatarImageBase64,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'profilePrompt': profilePrompt,
      'avatarImagePath': avatarImagePath,
      'avatarImageBase64': avatarImageBase64,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
