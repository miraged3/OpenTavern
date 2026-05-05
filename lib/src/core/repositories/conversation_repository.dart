import '../models/conversation.dart';
import '../storage/app_storage.dart';

class ConversationRepository {
  const ConversationRepository(this._storage);

  static const String storageKey = 'chat.conversations.v1';

  final AppStorage _storage;

  List<Conversation> loadAll() {
    return [
      for (final item in _storage.readJsonList(storageKey))
        Conversation.fromJson(item),
    ];
  }

  Future<void> saveAll(List<Conversation> conversations) {
    return _storage.writeJsonList(storageKey, [
      for (final conversation in conversations) conversation.toJson(),
    ]);
  }
}
