import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:juix_na/bootstrap.dart';
import 'package:juix_na/core/auth/token_store.dart';
import 'package:juix_na/core/network/api_client.dart';
import 'package:juix_na/core/network/api_result.dart';
import 'package:juix_na/features/inventory/data/inventory_api.dart';
import 'package:juix_na/features/inventory/model/inventory_dtos.dart';
import 'package:juix_na/features/inventory/view/screens/stock_movement_screen.dart';
import 'package:juix_na/features/inventory/viewmodel/inventory_overview_vm.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockTokenStore extends Mock implements TokenStore {}

class MockInventoryApi extends Mock implements InventoryApi {}

void main() {
  late MockApiClient mockApiClient;
  late MockTokenStore mockTokenStore;
  late MockInventoryApi mockInventoryApi;

  setUp(() {
    mockApiClient = MockApiClient();
    mockTokenStore = MockTokenStore();
    mockInventoryApi = MockInventoryApi();

    when(() => mockTokenStore.getAccessToken()).thenAnswer((_) async => null);
  });

  Widget createTestWidget(Widget child) {
    return ProviderScope(
      overrides: [
        tokenStoreProvider.overrideWithValue(mockTokenStore),
        apiClientProvider.overrideWithValue(mockApiClient),
        inventoryApiProvider.overrideWithValue(mockInventoryApi),
      ],
      child: MaterialApp.router(
        routerConfig: GoRouter(
          initialLocation: '/inventory/movement',
          routes: [
            GoRoute(
              path: '/inventory/movement',
              builder: (context, state) => child,
            ),
          ],
        ),
      ),
    );
  }

  group('StockMovementScreen Widget Tests', () {
    testWidgets('renders stock movement screen', (WidgetTester tester) async {
      // Setup: Mock locations
      when(
        () => mockInventoryApi.getLocations(isActive: any(named: 'isActive')),
      ).thenAnswer(
        (_) async => ApiSuccess<List<LocationDTO>>([
          LocationDTO(
            id: 1,
            name: 'Warehouse A',
            isActive: true,
            createdAt: '2024-01-01T00:00:00Z',
            updatedAt: '2024-01-01T00:00:00Z',
          ),
        ]),
      );

      await tester.pumpWidget(createTestWidget(const StockMovementScreen()));

      await tester.pumpAndSettle();

      // Verify screen renders
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
