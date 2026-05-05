enum AppLogLevel { info, warning, error }

class AppLogEntry {
  const AppLogEntry({
    required this.id,
    required this.timestamp,
    required this.level,
    required this.scope,
    required this.message,
    this.details,
  });

  final String id;
  final DateTime timestamp;
  final AppLogLevel level;
  final String scope;
  final String message;
  final String? details;

  AppLogEntry copyWith({
    String? id,
    DateTime? timestamp,
    AppLogLevel? level,
    String? scope,
    String? message,
    String? details,
  }) {
    return AppLogEntry(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      level: level ?? this.level,
      scope: scope ?? this.scope,
      message: message ?? this.message,
      details: details ?? this.details,
    );
  }

  factory AppLogEntry.fromJson(Map<String, dynamic> json) {
    return AppLogEntry(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      level: AppLogLevel.values.byName(json['level'] as String),
      scope: json['scope'] as String,
      message: json['message'] as String,
      details: json['details'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'level': level.name,
      'scope': scope,
      'message': message,
      'details': details,
    };
  }
}
