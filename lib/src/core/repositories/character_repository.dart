import '../models/character.dart';
import '../storage/app_storage.dart';

class CharacterRepository {
  const CharacterRepository(this._storage);

  static const String storageKey = 'characters.library.v1';

  final AppStorage _storage;

  List<Character> loadAll() {
    return [
      for (final item in _storage.readJsonList(storageKey))
        Character.fromJson(item),
    ];
  }

  Future<void> saveAll(List<Character> characters) {
    return _storage.writeJsonList(storageKey, [
      for (final character in characters) character.toJson(),
    ]);
  }
}
