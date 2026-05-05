import 'provider_config.dart';

enum ModelEndpointStatus { unknown, available, failed, testing }

class ModelEndpoint {
  const ModelEndpoint({
    required this.id,
    required this.name,
    required this.providerType,
    required this.apiFormat,
    required this.baseUrl,
    required this.model,
    required this.apiKey,
    required this.apiKeyLabel,
    required this.apiKeyFingerprint,
    required this.isEnabled,
    required this.isDefault,
    required this.status,
    required this.latencyMs,
  });

  final String id;
  final String name;
  final ProviderType providerType;
  final ApiEndpointFormat apiFormat;
  final String baseUrl;
  final String model;
  final String? apiKey;
  final String apiKeyLabel;
  final String apiKeyFingerprint;
  final bool isEnabled;
  final bool isDefault;
  final ModelEndpointStatus status;
  final int? latencyMs;

  factory ModelEndpoint.fromJson(Map<String, dynamic> json) {
    return ModelEndpoint(
      id: json['id'] as String,
      name: json['name'] as String,
      providerType: ProviderType.values.byName(json['providerType'] as String),
      apiFormat: ApiEndpointFormat.values.byName(json['apiFormat'] as String),
      baseUrl: json['baseUrl'] as String,
      model: json['model'] as String,
      apiKey: json['apiKey'] as String?,
      apiKeyLabel: json['apiKeyLabel'] as String? ?? 'Unnamed Key',
      apiKeyFingerprint: json['apiKeyFingerprint'] as String? ?? 'No Key',
      isEnabled: json['isEnabled'] as bool? ?? true,
      isDefault: json['isDefault'] as bool? ?? false,
      status: json['status'] == null
          ? ModelEndpointStatus.unknown
          : ModelEndpointStatus.values.byName(json['status'] as String),
      latencyMs: json['latencyMs'] as int?,
    );
  }

  ModelEndpoint copyWith({
    String? id,
    String? name,
    ProviderType? providerType,
    ApiEndpointFormat? apiFormat,
    String? baseUrl,
    String? model,
    String? apiKey,
    bool clearApiKey = false,
    String? apiKeyLabel,
    String? apiKeyFingerprint,
    bool? isEnabled,
    bool? isDefault,
    ModelEndpointStatus? status,
    int? latencyMs,
    bool clearLatency = false,
  }) {
    return ModelEndpoint(
      id: id ?? this.id,
      name: name ?? this.name,
      providerType: providerType ?? this.providerType,
      apiFormat: apiFormat ?? this.apiFormat,
      baseUrl: baseUrl ?? this.baseUrl,
      model: model ?? this.model,
      apiKey: clearApiKey ? null : apiKey ?? this.apiKey,
      apiKeyLabel: apiKeyLabel ?? this.apiKeyLabel,
      apiKeyFingerprint: apiKeyFingerprint ?? this.apiKeyFingerprint,
      isEnabled: isEnabled ?? this.isEnabled,
      isDefault: isDefault ?? this.isDefault,
      status: status ?? this.status,
      latencyMs: clearLatency ? null : latencyMs ?? this.latencyMs,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'providerType': providerType.name,
      'apiFormat': apiFormat.name,
      'baseUrl': baseUrl,
      'model': model,
      'apiKey': apiKey,
      'apiKeyLabel': apiKeyLabel,
      'apiKeyFingerprint': apiKeyFingerprint,
      'isEnabled': isEnabled,
      'isDefault': isDefault,
      'status': status.name,
      'latencyMs': latencyMs,
    };
  }
}
