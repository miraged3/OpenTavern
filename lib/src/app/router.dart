import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/models/character.dart';
import '../core/providers/app_providers.dart';
import '../features/chat/presentation/chat_detail_page.dart';
import '../features/chat/presentation/chat_home_page.dart';
import '../features/discover/presentation/discover_page.dart';
import '../features/help/presentation/help_page.dart';
import '../features/characters/presentation/character_detail_page.dart';
import '../features/characters/presentation/character_editor_page.dart';
import '../features/characters/presentation/character_import_page.dart';
import '../features/characters/presentation/characters_page.dart';
import '../features/settings/presentation/model_settings_page.dart';
import '../features/settings/presentation/app_logs_page.dart';
import '../features/settings/presentation/settings_page.dart';
import '../features/settings/presentation/user_personas_page.dart';
import '../features/shell/presentation/main_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/chat',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chat',
                name: 'chat',
                builder: (context, state) => const ChatHomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/characters',
                name: 'characters',
                builder: (context, state) => const CharactersPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/discover',
                name: 'discover',
                builder: (context, state) => const DiscoverPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/chat/:conversationId',
        name: 'chat_detail',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          final conversationId = state.pathParameters['conversationId']!;
          return CupertinoPage<void>(
            key: state.pageKey,
            child: ChatDetailPage(conversationId: conversationId),
          );
        },
      ),
      GoRoute(
        path: '/characters/import',
        name: 'character_import',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) =>
            const CupertinoPage<void>(child: CharacterImportPage()),
      ),
      GoRoute(
        path: '/characters/new',
        name: 'character_create',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) =>
            const CupertinoPage<Character?>(child: CharacterEditorPage()),
      ),
      GoRoute(
        path: '/characters/:characterId/edit',
        name: 'character_edit',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          final characterId = state.pathParameters['characterId']!;
          return CupertinoPage<Character?>(
            key: state.pageKey,
            child: Consumer(
              builder: (context, ref, child) {
                final character = ref
                    .watch(charactersProvider)
                    .where((item) => item.id == characterId)
                    .firstOrNull;
                return CharacterEditorPage(existing: character);
              },
            ),
          );
        },
      ),
      GoRoute(
        path: '/characters/:characterId',
        name: 'character_detail',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          final characterId = state.pathParameters['characterId']!;
          return CupertinoPage<void>(
            key: state.pageKey,
            child: CharacterDetailPage(characterId: characterId),
          );
        },
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) =>
            const CupertinoPage<void>(child: SettingsPage()),
      ),
      GoRoute(
        path: '/help',
        name: 'help',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) =>
            const CupertinoPage<void>(child: HelpPage()),
      ),
      GoRoute(
        path: '/settings/models',
        name: 'model_settings',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => CupertinoPage<void>(
          key: state.pageKey,
          child: const ModelSettingsPage(),
        ),
      ),
      GoRoute(
        path: '/settings/logs',
        name: 'app_logs',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) =>
            CupertinoPage<void>(key: state.pageKey, child: const AppLogsPage()),
      ),
      GoRoute(
        path: '/settings/user-personas',
        name: 'user_personas',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => CupertinoPage<void>(
          key: state.pageKey,
          child: const UserPersonasPage(),
        ),
      ),
    ],
  );
});
