import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:summaread/features/settings/presentation/settings_page.dart';
import 'package:summaread/services/providers.dart';
import 'package:summaread/services/secure_storage_service.dart';

class FakeApiKeyStorage implements ApiKeyStorage {
  FakeApiKeyStorage([this._value]);

  String? _value;

  @override
  Future<String?> read() async => _value;

  @override
  Future<void> write(String apiKey) async => _value = apiKey;

  @override
  Future<void> delete() async => _value = null;
}

void main() {
  Future<void> pumpSettingsPage(WidgetTester tester, ApiKeyStorage storage) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [apiKeyStorageProvider.overrideWithValue(storage)],
        child: const MaterialApp(home: SettingsPage()),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows "no key configured" and a disabled Clear button when none is set', (
    tester,
  ) async {
    await pumpSettingsPage(tester, FakeApiKeyStorage());

    expect(find.text('No API key configured'), findsOneWidget);
    final clearButton = tester.widget<OutlinedButton>(find.widgetWithText(OutlinedButton, 'Clear'));
    expect(clearButton.onPressed, isNull);
  });

  testWidgets('shows "configured" when a key is already stored', (tester) async {
    await pumpSettingsPage(tester, FakeApiKeyStorage('existing-key'));

    expect(find.text('An API key is configured'), findsOneWidget);
    final clearButton = tester.widget<OutlinedButton>(find.widgetWithText(OutlinedButton, 'Clear'));
    expect(clearButton.onPressed, isNotNull);
  });

  testWidgets('saving a key persists it, clears the field, and updates the status', (
    tester,
  ) async {
    final storage = FakeApiKeyStorage();
    await pumpSettingsPage(tester, storage);

    await tester.enterText(find.byType(TextField), 'my-new-key');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pump();

    expect(await storage.read(), 'my-new-key');
    expect(find.text('An API key is configured'), findsOneWidget);
    expect(find.text('API key saved'), findsOneWidget);

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.controller!.text, isEmpty);
  });

  testWidgets('clearing an existing key removes it and updates the status', (tester) async {
    final storage = FakeApiKeyStorage('existing-key');
    await pumpSettingsPage(tester, storage);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Clear'));
    await tester.pump();

    expect(await storage.read(), isNull);
    expect(find.text('No API key configured'), findsOneWidget);
    expect(find.text('API key cleared'), findsOneWidget);
  });
}
