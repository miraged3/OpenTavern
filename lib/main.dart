import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app/open_tavern_app.dart';
import 'src/core/providers/app_providers.dart';
import 'src/core/storage/app_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appStorage = await AppStorage.create();
  runApp(
    ProviderScope(
      overrides: [appStorageProvider.overrideWithValue(appStorage)],
      child: const OpenTavernApp(),
    ),
  );
}
