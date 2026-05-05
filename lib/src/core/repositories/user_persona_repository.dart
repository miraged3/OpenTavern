import '../models/user_persona.dart';
import '../storage/app_storage.dart';

class UserPersonaRepository {
  const UserPersonaRepository(this._storage);

  static const String storageKey = 'settings.user_personas.v1';

  final AppStorage _storage;

  List<UserPersona> loadAll() {
    return [
      for (final item in _storage.readJsonList(storageKey))
        UserPersona.fromJson(item),
    ];
  }

  Future<void> saveAll(List<UserPersona> personas) {
    return _storage.writeJsonList(storageKey, [
      for (final persona in personas) persona.toJson(),
    ]);
  }
}
