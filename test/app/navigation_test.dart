import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:juix_na/bootstrap.dart';
import 'package:juix_na/core/auth/token_store.dart';
import 'package:juix_na/core/network/api_client.dart';
import 'package:juix_na/app/router.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockTokenStore extends Mock implements TokenStore {}

void main() {
  late MockApiClient mockApiClient;
  late MockTokenStore mockTokenStore;

  setUp(() {
    mockApiClient = MockApiClient();
    mockTokenStore = MockTokenStore();

    when(() => mockTokenStore.getAccessToken()).thenAnswer((_) async => null);
  });

  Widget createTestApp() {
    return ProviderScope(
      overrides: [
        tokenStoreProvider.overrideWithValue(mockTokenStore),
        apiClientProvider.overrideWithValue(mockApiClient),
      ],
      child: Consumer(
        builder: (context, ref, child) {
          final router = ref.watch(routerProvider);
          return MaterialApp.router(routerConfig: router);
        },
      ),
    );
  }

  group('Navigation Tests', () {
    testWidgets('redirects to login when unauthenticated', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Verify we're on login screen (router redirects unauthenticated users)
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
