import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_tavern/src/app/open_tavern_app.dart';
import 'package:open_tavern/src/core/providers/app_providers.dart';

void main() {
  testWidgets('renders app shell tabs', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: const OpenTavernApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(CupertinoTabBar), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.chat_bubble_2_fill), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.person_crop_square), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.sparkles), findsOneWidget);
  });
}
