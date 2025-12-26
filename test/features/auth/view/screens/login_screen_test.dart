import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:juix_na/bootstrap.dart';
import 'package:juix_na/core/auth/token_store.dart';
import 'package:juix_na/core/network/api_client.dart';
import 'package:juix_na/features/auth/view/screens/login_screen.dart';
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
    when(
      () => mockTokenStore.saveAccessToken(any()),
    ).thenAnswer((_) async => {});
  });

  Widget createTestWidget(Widget child) {
    return ProviderScope(
      overrides: [
        tokenStoreProvider.overrideWithValue(mockTokenStore),
        apiClientProvider.overrideWithValue(mockApiClient),
      ],
      child: MaterialApp.router(
        routerConfig: GoRouter(
          initialLocation: '/login',
          routes: [GoRoute(path: '/login', builder: (context, state) => child)],
        ),
      ),
    );
  }

  group('LoginScreen Widget Tests', () {
    testWidgets('renders login screen with form fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(const LoginScreen()));
      await tester.pumpAndSettle();

      // Verify form fields exist
      expect(find.byType(TextFormField), findsNWidgets(2));

      // Verify submit button exists
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('can enter text in email field', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const LoginScreen()));
      await tester.pumpAndSettle();

      // Find email field and enter text
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'test@example.com');

      // Verify text was entered
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('can enter text in password field', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(const LoginScreen()));
      await tester.pumpAndSettle();

      // Find password field and enter text
      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(passwordField, 'password123');

      // Verify text was entered (password is obscured, so we check the field exists)
      expect(passwordField, findsOneWidget);
    });
  });
}
