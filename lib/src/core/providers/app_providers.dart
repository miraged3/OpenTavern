import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../import/character_card_importer.dart';
import '../llm/character_prompt_builder.dart';
import '../llm/llm_stream_event.dart';
import '../llm/provider_registry.dart';
import '../models/app_log_entry.dart';
import '../models/character.dart';
import '../models/chat_message.dart';
import '../models/conversation.dart';
import '../models/generation_config.dart';
import '../models/model_endpoint.dart';
import '../models/provider_config.dart';
import '../models/user_persona.dart';
import '../repositories/character_repository.dart';
import '../repositories/conversation_repository.dart';
import '../repositories/model_endpoint_repository.dart';
import '../repositories/user_persona_repository.dart';
import '../sample_data/sample_data.dart';
import '../storage/app_storage.dart';
import '../storage/character_avatar_store.dart';

final characterRepositoryProvider = Provider<CharacterRepository>(
  (ref) => CharacterRepository(ref.watch(appStorageProvider)),
);

final characterAvatarStoreProvider = Provider<CharacterAvatarStore>(
  (ref) => const CharacterAvatarStore(),
);

final charactersProvider =
    NotifierProvider<CharactersNotifier, List<Character>>(
      CharactersNotifier.new,
    );

class CharactersNotifier extends Notifier<List<Character>> {
  CharacterRepository get _repository => ref.read(characterRepositoryProvider);
  CharacterAvatarStore get _avatarStore =>
      ref.read(characterAvatarStoreProvider);

  @override
  List<Character> build() {
    return _repository.loadAll();
  }

  Future<void> upsert(Character character) async {
    final now = DateTime.now();
    final existing = state.where((item) => item.id == character.id).firstOrNull;
    final draftCharacter = character.copyWith(
      createdAt: existing?.createdAt ?? character.createdAt ?? now,
      updatedAt: now,
    );
    if (existing?.avatarImagePath != null &&
        existing!.avatarImagePath!.isNotEmpty &&
        draftCharacter.avatarImageBase64 != null &&
        draftCharacter.avatarImageBase64!.isNotEmpty) {
      await _avatarStore.deleteIfExists(existing);
    }
    if (existing?.avatarImagePath != null &&
        existing!.avatarImagePath!.isNotEmpty &&
        draftCharacter.avatarImagePath == null &&
        (draftCharacter.avatarImageBase64 == null ||
            draftCharacter.avatarImageBase64!.isEmpty)) {
      await _avatarStore.deleteIfExists(existing);
    }
    final nextCharacter = await _avatarStore.persistIfNeeded(draftCharacter);
    final next = [
      nextCharacter,
      for (final item in state)
        if (item.id != character.id) item,
    ];
    state = next;
    await _repository.saveAll(next);
  }

  Future<void> delete(String id) async {
    final character = state.where((item) => item.id == id).firstOrNull;
    if (character != null) {
      await _avatarStore.deleteIfExists(character);
    }
    final next = [
      for (final character in state)
        if (character.id != id) character,
    ];
    state = next;
    await _repository.saveAll(next);
  }

  Future<void> deleteMany(Set<String> ids) async {
    for (final character in state) {
      if (ids.contains(character.id)) {
        await _avatarStore.deleteIfExists(character);
      }
    }
    final next = [
      for (final character in state)
        if (!ids.contains(character.id)) character,
    ];
    state = next;
    await _repository.saveAll(next);
  }

  Future<void> toggleFavorite(String id) async {
    final now = DateTime.now();
    final next = [
      for (final character in state)
        if (character.id == id)
          character.copyWith(isFavorite: !character.isFavorite, updatedAt: now)
        else
          character,
    ];
    state = next;
    await _repository.saveAll(next);
  }

  Future<void> setSelectedFavorite(Set<String> ids, bool isFavorite) async {
    final now = DateTime.now();
    final next = [
      for (final character in state)
        if (ids.contains(character.id))
          character.copyWith(isFavorite: isFavorite, updatedAt: now)
        else
          character,
    ];
    state = next;
    await _repository.saveAll(next);
  }

  Future<void> markUsed(String id) async {
    final now = DateTime.now();
    final next = [
      for (final character in state)
        if (character.id == id)
          character.copyWith(lastUsedAt: now, updatedAt: now)
        else
          character,
    ];
    state = next;
    await _repository.saveAll(next);
  }
}

final conversationRepositoryProvider = Provider<ConversationRepository>(
  (ref) => ConversationRepository(ref.watch(appStorageProvider)),
);

final conversationsProvider =
    NotifierProvider<ConversationsNotifier, List<Conversation>>(
      ConversationsNotifier.new,
    );

class ConversationsNotifier extends Notifier<List<Conversation>> {
  ConversationRepository get _repository =>
      ref.read(conversationRepositoryProvider);

  @override
  List<Conversation> build() {
    final loaded = _repository.loadAll();
    final recovered = _recoverInterruptedConversations(loaded);
    if (!_sameConversationMessages(loaded, recovered)) {
      Future.microtask(() => _repository.saveAll(recovered));
    }
    return recovered;
  }

  Future<Conversation> createForCharacter(Character character) async {
    final now = DateTime.now();
    final greetingTemplate = pickCharacterGreetingTemplate(character);
    final defaultPersona = ref.read(defaultUserPersonaProvider);
    final conversation = Conversation(
      id: 'conv-${now.microsecondsSinceEpoch}',
      character: character,
      messages: [
        if (greetingTemplate.trim().isNotEmpty)
          ChatMessage(
            id: 'msg-${now.microsecondsSinceEpoch}',
            role: MessageRole.assistant,
            content: greetingTemplate,
            timestamp: now,
            isTemplate: true,
          ),
      ],
      userPersonaId: defaultPersona.id,
      updatedAt: now,
    );
    final next = [conversation, ...state];
    state = next;
    await _repository.saveAll(next);
    return conversation;
  }

  Future<void> replaceConversation(Conversation conversation) async {
    final next = [
      conversation,
      for (final item in state)
        if (item.id != conversation.id) item,
    ];
    state = next;
    await _repository.saveAll(next);
  }

  Future<void> delete(String id) async {
    final next = [
      for (final conversation in state)
        if (conversation.id != id) conversation,
    ];
    state = next;
    await _repository.saveAll(next);
  }

  Future<void> deleteMany(Set<String> ids) async {
    final next = [
      for (final conversation in state)
        if (!ids.contains(conversation.id)) conversation,
    ];
    state = next;
    await _repository.saveAll(next);
  }

  List<Conversation> _recoverInterruptedConversations(
    List<Conversation> conversations,
  ) {
    return [
      for (final conversation in conversations)
        if (conversation.messages.any((message) => message.isPending))
          _recoverInterruptedConversation(conversation)
        else
          conversation,
    ];
  }

  Conversation _recoverInterruptedConversation(Conversation conversation) {
    final recoveredMessages = <ChatMessage>[];
    var interrupted = false;
    for (final message in conversation.messages) {
      if (!message.isPending) {
        recoveredMessages.add(message);
        continue;
      }
      interrupted = true;
      if (message.role == MessageRole.assistant &&
          (message.content.trim().isNotEmpty ||
              message.reasoning.trim().isNotEmpty)) {
        recoveredMessages.add(message.copyWith(isPending: false));
      }
    }
    if (interrupted) {
      recoveredMessages.add(
        ChatMessage(
          id: 'sys-interrupted-${conversation.updatedAt.microsecondsSinceEpoch}',
          role: MessageRole.system,
          content: 'system_interrupted',
          timestamp: DateTime.now(),
        ),
      );
      Future.microtask(
        () => ref
            .read(appLogsProvider.notifier)
            .add(
              level: AppLogLevel.warning,
              scope: 'chat',
              message: 'Recovered interrupted reply',
              details: 'conversationId=${conversation.id}',
              force: true,
            ),
      );
    }
    return Conversation(
      id: conversation.id,
      character: conversation.character,
      messages: recoveredMessages,
      userPersonaId: conversation.userPersonaId,
      modelEndpointId: conversation.modelEndpointId,
      generationConfig: conversation.generationConfig,
      updatedAt: DateTime.now(),
    );
  }

  bool _sameConversationMessages(
    List<Conversation> left,
    List<Conversation> right,
  ) {
    if (identical(left, right)) {
      return true;
    }
    if (left.length != right.length) {
      return false;
    }
    for (var i = 0; i < left.length; i++) {
      final a = left[i];
      final b = right[i];
      if (a.id != b.id || a.messages.length != b.messages.length) {
        return false;
      }
      for (var j = 0; j < a.messages.length; j++) {
        final am = a.messages[j];
        final bm = b.messages[j];
        if (am.id != bm.id ||
            am.content != bm.content ||
            am.role != bm.role ||
            am.reasoning != bm.reasoning ||
            am.isPending != bm.isPending) {
          return false;
        }
      }
    }
    return true;
  }
}

final conversationCountProvider = Provider<int>(
  (ref) => ref.watch(conversationsProvider).length,
);

final conversationByIdProvider = Provider.family<Conversation?, String>((
  ref,
  conversationId,
) {
  for (final conversation in ref.watch(conversationsProvider)) {
    if (conversation.id == conversationId) {
      return conversation;
    }
  }

  return null;
});

final chatGenerationControllerProvider =
    NotifierProvider<ChatGenerationController, Set<String>>(
      ChatGenerationController.new,
    );

final isConversationGeneratingProvider = Provider.family<bool, String>((
  ref,
  conversationId,
) {
  return ref.watch(chatGenerationControllerProvider).contains(conversationId);
});

class ChatGenerationController extends Notifier<Set<String>> {
  final Map<String, StreamSubscription<LlmStreamEvent>> _subscriptions = {};
  final Map<String, Completer<void>> _completers = {};
  final Map<String, String> _pendingAssistantIds = {};

  @override
  Set<String> build() {
    ref.onDispose(() {
      for (final subscription in _subscriptions.values) {
        subscription.cancel();
      }
    });
    return <String>{};
  }

  Future<void> sendMessage({
    required String conversationId,
    required String rawInput,
  }) async {
    final conversation = ref.read(conversationByIdProvider(conversationId));
    if (conversation == null || state.contains(conversationId)) {
      return;
    }
    final trimmed = rawInput.trim();
    if (trimmed.isEmpty) {
      return;
    }
    final defaultUserPersona = ref.read(defaultUserPersonaProvider);
    final userPersona = conversation.userPersonaId == null
        ? defaultUserPersona
        : ref.read(userPersonaByIdProvider(conversation.userPersonaId!)) ??
              defaultUserPersona;
    final now = DateTime.now();
    final userMessage = ChatMessage(
      id: 'msg-${now.microsecondsSinceEpoch}',
      role: MessageRole.user,
      content: trimmed,
      timestamp: now,
    );
    final updatedConversation = Conversation(
      id: conversation.id,
      character: conversation.character,
      messages: [...conversation.messages, userMessage],
      userPersonaId: conversation.userPersonaId,
      modelEndpointId: conversation.modelEndpointId,
      generationConfig: conversation.generationConfig,
      updatedAt: now,
    );
    await _replaceConversation(updatedConversation);
    await ref
        .read(appLogsProvider.notifier)
        .add(
          level: AppLogLevel.info,
          scope: 'chat',
          message: 'Queued user message',
          details: 'conversationId=$conversationId',
        );
    await generateReplyForConversation(
      updatedConversation,
      userPersona: userPersona,
    );
  }

  Future<void> generateReplyForConversation(
    Conversation conversation, {
    required UserPersona userPersona,
  }) async {
    if (state.contains(conversation.id)) {
      return;
    }
    final modelEndpoint = conversation.modelEndpointId != null
        ? ref.read(modelEndpointByIdProvider(conversation.modelEndpointId!))
        : ref.read(activeModelEndpointProvider);
    if (modelEndpoint == null) {
      await ref
          .read(appLogsProvider.notifier)
          .add(
            level: AppLogLevel.error,
            scope: 'chat',
            message: 'Reply generation failed: missing model',
            details: 'conversationId=${conversation.id}',
          );
      await _appendSystemMessage(conversation, 'system_send_failed');
      return;
    }

    final now = DateTime.now();
    final assistantPlaceholder = ChatMessage(
      id: 'msg-${now.microsecondsSinceEpoch + 1}',
      role: MessageRole.assistant,
      content: '',
      timestamp: now,
      isPending: true,
    );
    final pendingConversation = Conversation(
      id: conversation.id,
      character: conversation.character,
      messages: [...conversation.messages, assistantPlaceholder],
      userPersonaId: conversation.userPersonaId,
      modelEndpointId: conversation.modelEndpointId,
      generationConfig: conversation.generationConfig,
      updatedAt: now,
    );

    state = {...state, conversation.id};
    _pendingAssistantIds[conversation.id] = assistantPlaceholder.id;
    await _replaceConversation(pendingConversation);
    await ref
        .read(appLogsProvider.notifier)
        .add(
          level: AppLogLevel.info,
          scope: 'chat',
          message: 'Started reply generation',
          details:
              'conversationId=${conversation.id}, model=${modelEndpoint.model}',
        );

    try {
      final requestMessages = buildConversationMessagesForModel(
        conversation,
        userPersona: userPersona,
      );
      final provider = ref
          .read(providerRegistryProvider)
          .create(
            ProviderConfig(
              id: modelEndpoint.id,
              label: modelEndpoint.name,
              type: modelEndpoint.providerType,
              apiFormat: modelEndpoint.apiFormat,
              baseUrl: modelEndpoint.baseUrl,
              defaultModel: modelEndpoint.model,
              apiKey: modelEndpoint.apiKey,
            ),
          );
      var aggregatedReply = '';
      var aggregatedReasoning = '';
      var loggedReasoningStart = false;
      final completer = Completer<void>();
      _completers[conversation.id] = completer;
      _subscriptions[conversation.id] = provider
          .streamGenerate(
            messages: requestMessages,
            config:
                conversation.generationConfig ??
                ref.read(defaultGenerationConfigProvider),
          )
          .listen(
            (event) async {
              if (event.type == LlmStreamEventType.reasoningDelta) {
                aggregatedReasoning += event.delta;
                if (!loggedReasoningStart) {
                  loggedReasoningStart = true;
                  await ref
                      .read(appLogsProvider.notifier)
                      .add(
                        level: AppLogLevel.info,
                        scope: 'chat',
                        message: 'Model emitted reasoning',
                        details: 'conversationId=${conversation.id}',
                      );
                }
              } else {
                aggregatedReply += event.delta;
              }
              await _replaceConversation(
                pendingConversation.copyWith(
                  messages: [
                    ...conversation.messages,
                    assistantPlaceholder.copyWith(
                      content: aggregatedReply,
                      reasoning: aggregatedReasoning,
                      isPending: true,
                    ),
                  ],
                  updatedAt: DateTime.now(),
                ),
              );
            },
            onError: (Object error, StackTrace stackTrace) async {
              await _handleGenerationFailure(
                conversation.id,
                assistantPlaceholder.id,
                _formatSendError(error),
              );
              if (!completer.isCompleted) {
                completer.complete();
              }
            },
            onDone: () async {
              if (!_subscriptions.containsKey(conversation.id)) {
                if (!completer.isCompleted) {
                  completer.complete();
                }
                return;
              }
              if (aggregatedReply.trim().isEmpty) {
                aggregatedReply = '...';
              }
              await _replaceConversation(
                pendingConversation.copyWith(
                  messages: [
                    ...conversation.messages,
                    assistantPlaceholder.copyWith(
                      content: aggregatedReply,
                      reasoning: aggregatedReasoning,
                      isPending: false,
                    ),
                  ],
                  updatedAt: DateTime.now(),
                ),
              );
              await ref
                  .read(appLogsProvider.notifier)
                  .add(
                    level: AppLogLevel.info,
                    scope: 'chat',
                    message: 'Completed reply generation',
                    details:
                        'conversationId=${conversation.id}, textLength=${aggregatedReply.length}, reasoningLength=${aggregatedReasoning.length}',
                  );
              _finishGeneration(conversation.id);
              if (!completer.isCompleted) {
                completer.complete();
              }
            },
          );
      await completer.future;
    } catch (error) {
      await _handleGenerationFailure(
        conversation.id,
        assistantPlaceholder.id,
        _formatSendError(error),
      );
    }
  }

  Future<void> cancelGeneration(String conversationId) async {
    if (!state.contains(conversationId)) {
      return;
    }
    final subscription = _subscriptions.remove(conversationId);
    await subscription?.cancel();
    final current = ref.read(conversationByIdProvider(conversationId));
    final pendingAssistantId = _pendingAssistantIds[conversationId];
    if (current != null && pendingAssistantId != null) {
      await _replaceConversation(
        current.copyWith(
          messages: current.messages
              .where((message) => message.id != pendingAssistantId)
              .toList(),
          updatedAt: DateTime.now(),
        ),
      );
    }
    _pendingAssistantIds.remove(conversationId);
    final completer = _completers.remove(conversationId);
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
    state = {...state}..remove(conversationId);
    await ref
        .read(appLogsProvider.notifier)
        .add(
          level: AppLogLevel.warning,
          scope: 'chat',
          message: 'Cancelled reply generation',
          details: 'conversationId=$conversationId',
        );
  }

  Future<void> _handleGenerationFailure(
    String conversationId,
    String assistantMessageId,
    String message,
  ) async {
    final current = ref.read(conversationByIdProvider(conversationId));
    if (current != null) {
      final nextConversation = current.copyWith(
        messages: current.messages
            .where((item) => item.id != assistantMessageId)
            .toList(),
        updatedAt: DateTime.now(),
      );
      await _replaceConversation(nextConversation);
      await _appendSystemMessage(nextConversation, 'system_send_failed');
    }
    await ref
        .read(appLogsProvider.notifier)
        .add(
          level: AppLogLevel.error,
          scope: 'chat',
          message: 'Reply generation failed',
          details: 'conversationId=$conversationId, error=$message',
        );
    _finishGeneration(conversationId);
  }

  void _finishGeneration(String conversationId) {
    _subscriptions.remove(conversationId);
    _pendingAssistantIds.remove(conversationId);
    _completers.remove(conversationId);
    state = {...state}..remove(conversationId);
  }

  Future<void> _replaceConversation(Conversation conversation) {
    return ref
        .read(conversationsProvider.notifier)
        .replaceConversation(conversation);
  }

  Future<void> _appendSystemMessage(Conversation conversation, String content) {
    final now = DateTime.now();
    return _replaceConversation(
      conversation.copyWith(
        messages: [
          ...conversation.messages,
          ChatMessage(
            id: 'sys-${now.microsecondsSinceEpoch}',
            role: MessageRole.system,
            content: content,
            timestamp: now,
          ),
        ],
        updatedAt: now,
      ),
    );
  }

  String _formatSendError(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('failed host lookup') ||
        message.contains('connection error') ||
        message.contains('socketexception')) {
      return 'Network connection failed, please check API address and network';
    }
    if (message.contains('timeout')) {
      return 'Request timed out, please retry later';
    }
    if (message.contains('401') || message.contains('unauthorized')) {
      return 'API Key invalid or expired';
    }
    if (message.contains('429') || message.contains('too many requests')) {
      return 'Too many requests, please retry later';
    }
    if (message.contains('5') && message.contains('http')) {
      return 'Server error, please retry later';
    }
    return error.toString();
  }
}

final defaultGenerationConfigProvider =
    NotifierProvider<DefaultGenerationConfigNotifier, GenerationConfig>(
      DefaultGenerationConfigNotifier.new,
    );

class DefaultGenerationConfigNotifier extends Notifier<GenerationConfig> {
  static const _storageKey = 'generation.default.config';

  AppStorage get _storage => ref.read(appStorageProvider);

  @override
  GenerationConfig build() {
    final rawValue = _storage.readString(_storageKey);
    if (rawValue == null) {
      return const GenerationConfig();
    }
    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is Map) {
        return GenerationConfig.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      return const GenerationConfig();
    }
    return const GenerationConfig();
  }

  Future<void> setConfig(GenerationConfig config) async {
    state = config;
    await _storage.writeString(_storageKey, jsonEncode(config.toJson()));
  }
}

final providerConfigsProvider = Provider<List<ProviderConfig>>(
  (ref) => sampleProviderConfigs,
);

final appLoggingEnabledProvider =
    NotifierProvider<AppLoggingEnabledNotifier, bool>(
      AppLoggingEnabledNotifier.new,
    );

class AppLoggingEnabledNotifier extends Notifier<bool> {
  static const _storageKey = 'app.logging.enabled';

  AppStorage get _storage => ref.read(appStorageProvider);

  @override
  bool build() {
    return _storage.readBool(_storageKey) ?? false;
  }

  Future<void> setValue(bool value) async {
    state = value;
    await _storage.writeBool(_storageKey, value);
  }
}

final appLogsProvider = NotifierProvider<AppLogsNotifier, List<AppLogEntry>>(
  AppLogsNotifier.new,
);

class AppLogsNotifier extends Notifier<List<AppLogEntry>> {
  static const _storageKey = 'app.runtime.logs';
  static const _maxEntries = 500;

  AppStorage get _storage => ref.read(appStorageProvider);

  @override
  List<AppLogEntry> build() {
    return [
      for (final item in _storage.readJsonList(_storageKey))
        AppLogEntry.fromJson(item),
    ];
  }

  Future<void> add({
    required AppLogLevel level,
    required String scope,
    required String message,
    String? details,
    bool force = false,
  }) async {
    final enabled = ref.read(appLoggingEnabledProvider);
    if (!force && !enabled) {
      return;
    }
    final now = DateTime.now();
    final entry = AppLogEntry(
      id: 'log-${now.microsecondsSinceEpoch}',
      timestamp: now,
      level: level,
      scope: scope,
      message: message,
      details: details,
    );
    final next = [...state, entry];
    final trimmed = next.length > _maxEntries
        ? next.sublist(next.length - _maxEntries)
        : next;
    state = trimmed;
    await _storage.writeJsonList(_storageKey, [
      for (final item in trimmed) item.toJson(),
    ]);
  }

  Future<void> clear() async {
    state = const [];
    await _storage.writeJsonList(_storageKey, const []);
  }
}

final userPersonaRepositoryProvider = Provider<UserPersonaRepository>(
  (ref) => UserPersonaRepository(ref.watch(appStorageProvider)),
);

final userPersonasProvider =
    NotifierProvider<UserPersonasNotifier, List<UserPersona>>(
      UserPersonasNotifier.new,
    );

class UserPersonasNotifier extends Notifier<List<UserPersona>> {
  UserPersonaRepository get _repository =>
      ref.read(userPersonaRepositoryProvider);

  @override
  List<UserPersona> build() {
    return _normalizeDefault(_repository.loadAll());
  }

  Future<void> upsert(UserPersona persona) async {
    final now = DateTime.now();
    final existing = state.where((item) => item.id == persona.id).firstOrNull;
    final nextPersona = persona.copyWith(
      createdAt: existing?.createdAt ?? persona.createdAt,
      updatedAt: now,
    );
    await _setState(
      _normalizeDefault([
        nextPersona,
        for (final item in state)
          if (item.id != persona.id) item,
      ]),
    );
  }

  Future<void> delete(String id) async {
    await _setState(
      _normalizeDefault([
        for (final persona in state)
          if (persona.id != id) persona,
      ]),
    );
  }

  Future<void> setDefault(String id) async {
    await _setState(
      _normalizeDefault([
        for (final persona in state)
          persona.copyWith(
            isDefault: persona.id == id,
            updatedAt: DateTime.now(),
          ),
      ]),
    );
  }

  Future<void> _setState(List<UserPersona> next) async {
    state = next;
    await _repository.saveAll(next);
  }

  List<UserPersona> _normalizeDefault(List<UserPersona> personas) {
    if (personas.isEmpty) {
      return [defaultUserPersona()];
    }

    String? defaultId;
    for (final persona in personas) {
      if (persona.isDefault) {
        defaultId = persona.id;
        break;
      }
    }

    defaultId ??= personas.first.id;
    return [
      for (final persona in personas)
        persona.copyWith(isDefault: persona.id == defaultId),
    ];
  }
}

final defaultUserPersonaProvider = Provider<UserPersona>((ref) {
  final personas = ref.watch(userPersonasProvider);
  return personas.where((persona) => persona.isDefault).firstOrNull ??
      personas.firstOrNull ??
      defaultUserPersona();
});

final userPersonaByIdProvider = Provider.family<UserPersona?, String>((
  ref,
  id,
) {
  return ref
      .watch(userPersonasProvider)
      .where((persona) => persona.id == id)
      .firstOrNull;
});

final currentUserNameProvider = Provider<String>(
  (ref) => ref.watch(defaultUserPersonaProvider).name,
);

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

final appStorageProvider = Provider<AppStorage>(
  (ref) => AppStorage(ref.watch(sharedPreferencesProvider)),
);

final modelEndpointRepositoryProvider = Provider<ModelEndpointRepository>(
  (ref) => ModelEndpointRepository(ref.watch(appStorageProvider)),
);

final modelEndpointsProvider =
    NotifierProvider<ModelEndpointsNotifier, List<ModelEndpoint>>(
      ModelEndpointsNotifier.new,
    );

class ModelEndpointsNotifier extends Notifier<List<ModelEndpoint>> {
  ModelEndpointRepository get _repository =>
      ref.read(modelEndpointRepositoryProvider);

  @override
  List<ModelEndpoint> build() {
    return _normalizeDefaultModels(_repository.loadAll());
  }

  Future<void> upsert(ModelEndpoint model) async {
    final next = _normalizeDefaultModels([
      model,
      for (final item in state)
        if (item.id != model.id) item,
    ]);
    await _setState(next);
  }

  Future<void> updateModel(
    String id,
    ModelEndpoint Function(ModelEndpoint model) update,
  ) async {
    await _setState(
      _normalizeDefaultModels([
        for (final model in state) model.id == id ? update(model) : model,
      ]),
    );
  }

  Future<void> setSelectedEnabled(Set<String> ids, bool isEnabled) async {
    await _setState([
      for (final model in state)
        ids.contains(model.id) ? model.copyWith(isEnabled: isEnabled) : model,
    ]);
  }

  Future<void> deleteMany(Set<String> ids) async {
    await _setState([
      for (final model in state)
        if (!ids.contains(model.id)) model,
    ]);
  }

  Future<void> setDefault(String id) async {
    await _setState([
      for (final model in state)
        model.copyWith(isDefault: model.id == id, isEnabled: true),
    ]);
  }

  Future<void> _setState(List<ModelEndpoint> next) async {
    state = next;
    await _repository.saveAll(next);
  }

  List<ModelEndpoint> _normalizeDefaultModels(List<ModelEndpoint> models) {
    String? defaultId;
    for (final model in models) {
      if (model.isDefault) {
        defaultId = model.id;
        break;
      }
    }

    if (defaultId == null) {
      return models;
    }

    return [
      for (final model in models)
        model.isDefault == (model.id == defaultId)
            ? model
            : model.copyWith(isDefault: model.id == defaultId),
    ];
  }
}

final activeModelEndpointProvider = Provider<ModelEndpoint?>((ref) {
  return ref
      .watch(modelEndpointsProvider)
      .where((model) => model.isDefault)
      .firstOrNull;
});

final modelEndpointByIdProvider = Provider.family<ModelEndpoint?, String>((
  ref,
  id,
) {
  return ref
      .watch(modelEndpointsProvider)
      .where((model) => model.id == id)
      .firstOrNull;
});

final enabledModelEndpointsProvider = Provider<List<ModelEndpoint>>(
  (ref) => ref
      .watch(modelEndpointsProvider)
      .where((model) => model.isEnabled)
      .toList(growable: false),
);

final activeConversationProvider = Provider<Conversation?>(
  (ref) => ref.watch(conversationsProvider).firstOrNull,
);

final activeCharacterProvider = Provider<Character?>(
  (ref) => ref.watch(activeConversationProvider)?.character,
);

final providerRegistryProvider = Provider<ProviderRegistry>(
  (ref) => const ProviderRegistry(),
);

final characterCardImporterProvider = Provider<CharacterCardImporter>(
  (ref) => const CharacterCardImporter(),
);

enum AppThemePreference { system, light, dark }

enum AppLanguagePreference { system, en, zh }

final languagePreferenceProvider =
    NotifierProvider<LanguagePreferenceNotifier, AppLanguagePreference>(
      LanguagePreferenceNotifier.new,
    );

class LanguagePreferenceNotifier extends Notifier<AppLanguagePreference> {
  static const _storageKey = 'settings.language_preference.v1';

  AppStorage get _storage => ref.read(appStorageProvider);

  @override
  AppLanguagePreference build() {
    final rawValue = _storage.readString(_storageKey);
    return switch (rawValue) {
      'en' => AppLanguagePreference.en,
      'zh' => AppLanguagePreference.zh,
      _ => AppLanguagePreference.system,
    };
  }

  Future<void> setPreference(AppLanguagePreference preference) async {
    state = preference;
    await _storage.writeString(_storageKey, switch (preference) {
      AppLanguagePreference.system => 'system',
      AppLanguagePreference.en => 'en',
      AppLanguagePreference.zh => 'zh',
    });
  }
}

final themePreferenceProvider =
    NotifierProvider<ThemePreferenceNotifier, AppThemePreference>(
      ThemePreferenceNotifier.new,
    );

class ThemePreferenceNotifier extends Notifier<AppThemePreference> {
  static const _storageKey = 'settings.theme_preference.v1';

  AppStorage get _storage => ref.read(appStorageProvider);

  @override
  AppThemePreference build() {
    final rawValue = _storage.readString(_storageKey);
    return switch (rawValue) {
      'light' => AppThemePreference.light,
      'dark' => AppThemePreference.dark,
      _ => AppThemePreference.system,
    };
  }

  Future<void> setPreference(AppThemePreference preference) async {
    state = preference;
    await _storage.writeString(_storageKey, switch (preference) {
      AppThemePreference.system => 'system',
      AppThemePreference.light => 'light',
      AppThemePreference.dark => 'dark',
    });
  }
}

final appThemeModeProvider = Provider<ThemeMode>((ref) {
  return switch (ref.watch(themePreferenceProvider)) {
    AppThemePreference.system => ThemeMode.system,
    AppThemePreference.light => ThemeMode.light,
    AppThemePreference.dark => ThemeMode.dark,
  };
});

final enterKeyToSendProvider = NotifierProvider<EnterKeyToSendNotifier, bool>(
  EnterKeyToSendNotifier.new,
);

class EnterKeyToSendNotifier extends Notifier<bool> {
  static const _storageKey = 'settings.enter_key_to_send.v1';

  AppStorage get _storage => ref.read(appStorageProvider);

  @override
  bool build() {
    final rawValue = _storage.readString(_storageKey);
    return rawValue == 'true';
  }

  Future<void> setValue(bool value) async {
    state = value;
    await _storage.writeString(_storageKey, value ? 'true' : 'false');
  }
}
