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
import 'package:juix_na/features/inventory/view/screens/inventory_overview_screen.dart';
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
          initialLocation: '/inventory',
          routes: [
            GoRoute(path: '/inventory', builder: (context, state) => child),
          ],
        ),
      ),
    );
  }

  group('InventoryOverviewScreen Widget Tests', () {
    testWidgets('renders inventory overview screen', (
      WidgetTester tester,
    ) async {
      // Setup: Mock successful response
      when(
        () => mockInventoryApi.getLocations(isActive: any(named: 'isActive')),
      ).thenAnswer((_) async => ApiSuccess<List<LocationDTO>>([]));

      when(
        () => mockInventoryApi.getInventoryOverview(
          locationId: any(named: 'locationId'),
          kind: any(named: 'kind'),
          search: any(named: 'search'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenAnswer(
        (_) async => ApiSuccess(
          InventoryOverviewResponseDTO(
            kpis: InventoryOverviewKPIsDTO(
              totalItems: 0,
              totalSkus: 0,
              totalQuantityAllLocations: '0.0',
              lowStockItems: 0,
              outOfStockItems: 0,
            ),
            items: [],
            page: PaginationDTO(skip: 0, limit: 10, total: 0),
          ),
        ),
      );

      await tester.pumpWidget(
        createTestWidget(const InventoryOverviewScreen()),
      );
      await tester.pumpAndSettle();

      // Verify screen renders
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('displays inventory items when loaded', (
      WidgetTester tester,
    ) async {
      // Setup: Mock successful response with items
      final locations = [
        LocationDTO(
          id: 1,
          name: 'Warehouse A',
          isActive: true,
          createdAt: '2024-01-01T00:00:00Z',
          updatedAt: '2024-01-01T00:00:00Z',
        ),
      ];

      final overviewDTO = InventoryOverviewResponseDTO(
        kpis: InventoryOverviewKPIsDTO(
          totalItems: 1,
          totalSkus: 1,
          totalQuantityAllLocations: '50.0',
          lowStockItems: 0,
          outOfStockItems: 0,
        ),
        items: [
          InventoryItemDTO(
            id: 1,
            name: 'Test Product',
            sku: 'SKU-001',
            unit: 'kg',
            kind: 'FINISHED_PRODUCT',
            totalQuantity: '50.0',
          ),
        ],
        page: PaginationDTO(skip: 0, limit: 10, total: 1),
      );

      when(
        () => mockInventoryApi.getLocations(isActive: any(named: 'isActive')),
      ).thenAnswer((_) async => ApiSuccess(locations));

      when(
        () => mockInventoryApi.getInventoryOverview(
          locationId: any(named: 'locationId'),
          kind: any(named: 'kind'),
          search: any(named: 'search'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenAnswer((_) async => ApiSuccess(overviewDTO));

      await tester.pumpWidget(
        createTestWidget(const InventoryOverviewScreen()),
      );

      // Wait for async operations
      await tester.pumpAndSettle();

      // Verify item is displayed
      expect(find.text('Test Product'), findsOneWidget);
      expect(find.text('SKU-001'), findsOneWidget);
    });

    testWidgets('has pull to refresh capability', (WidgetTester tester) async {
      // Setup: Mock successful response
      when(
        () => mockInventoryApi.getLocations(isActive: any(named: 'isActive')),
      ).thenAnswer((_) async => ApiSuccess<List<LocationDTO>>([]));

      when(
        () => mockInventoryApi.getInventoryOverview(
          locationId: any(named: 'locationId'),
          kind: any(named: 'kind'),
          search: any(named: 'search'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenAnswer(
        (_) async => ApiSuccess(
          InventoryOverviewResponseDTO(
            kpis: InventoryOverviewKPIsDTO(
              totalItems: 0,
              totalSkus: 0,
              totalQuantityAllLocations: '0.0',
              lowStockItems: 0,
              outOfStockItems: 0,
            ),
            items: [],
            page: PaginationDTO(skip: 0, limit: 10, total: 0),
          ),
        ),
      );

      await tester.pumpWidget(
        createTestWidget(const InventoryOverviewScreen()),
      );

      await tester.pumpAndSettle();

      // Verify RefreshIndicator exists
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });
  });
}
