import '../models/model_endpoint.dart';
import '../storage/app_storage.dart';

class ModelEndpointRepository {
  const ModelEndpointRepository(this._storage);

  static const String storageKey = 'settings.model_endpoints.v1';

  final AppStorage _storage;

  List<ModelEndpoint> loadAll() {
    return [
      for (final item in _storage.readJsonList(storageKey))
        ModelEndpoint.fromJson(item),
    ];
  }

  Future<void> saveAll(List<ModelEndpoint> models) {
    return _storage.writeJsonList(storageKey, [
      for (final model in models) model.toJson(),
    ]);
  }
}
