enum ReasoningMode { off, automatic, low, medium, high }

class GenerationConfig {
  const GenerationConfig({
    this.temperature = 0.9,
    this.maxTokens = 512,
    this.topP = 0.95,
    this.reasoningMode = ReasoningMode.automatic,
    this.stop,
  });

  final double temperature;
  final int maxTokens;
  final double topP;
  final ReasoningMode reasoningMode;
  final List<String>? stop;

  GenerationConfig copyWith({
    double? temperature,
    int? maxTokens,
    double? topP,
    ReasoningMode? reasoningMode,
    List<String>? stop,
  }) {
    return GenerationConfig(
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      topP: topP ?? this.topP,
      reasoningMode: reasoningMode ?? this.reasoningMode,
      stop: stop ?? this.stop,
    );
  }

  factory GenerationConfig.fromJson(Map<String, dynamic> json) {
    return GenerationConfig(
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.9,
      maxTokens: (json['maxTokens'] as num?)?.toInt() ?? 512,
      topP: (json['topP'] as num?)?.toDouble() ?? 0.95,
      reasoningMode: _reasoningModeFromJson(json['reasoningMode']),
      stop: json['stop'] is List
          ? [
              for (final item in json['stop'] as List)
                if (item is String) item,
            ]
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'temperature': temperature,
      'maxTokens': maxTokens,
      'topP': topP,
      'reasoningMode': reasoningMode.name,
      if (stop != null) 'stop': stop,
    };
  }

  static ReasoningMode _reasoningModeFromJson(Object? value) {
    if (value is! String) {
      return ReasoningMode.automatic;
    }
    return ReasoningMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => ReasoningMode.automatic,
    );
  }
}
