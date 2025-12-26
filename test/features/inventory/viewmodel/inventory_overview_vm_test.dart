import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:juix_na/core/network/api_result.dart';
import 'package:juix_na/features/inventory/data/inventory_repository.dart';
import 'package:juix_na/features/inventory/model/inventory_dtos.dart';
import 'package:juix_na/features/inventory/model/inventory_models.dart';
import 'package:juix_na/features/inventory/viewmodel/inventory_overview_vm.dart';
import 'package:mocktail/mocktail.dart';

class MockInventoryRepository extends Mock implements InventoryRepository {}

void main() {
  late MockInventoryRepository mockRepository;
  late ProviderContainer container;

  setUpAll(() {
    // Register fallback values for complex types used in mocktail any() matchers
    // Note: InventoryFilters doesn't need fallback as we use any(named: '...') for specific params
    // ItemKind enum values are used directly in tests, not in any() matchers
  });

  setUp(() {
    mockRepository = MockInventoryRepository();
    container = ProviderContainer(
      overrides: [
        inventoryRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('InventoryOverviewViewModel', () {
    test('build loads initial data successfully', () async {
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
          totalItems: 10,
          totalSkus: 5,
          totalQuantityAllLocations: '1000.0',
          lowStockItems: 2,
          outOfStockItems: 1,
        ),
        items: [],
        page: PaginationDTO(skip: 0, limit: 10, total: 0),
      );

      when(
        () => mockRepository.getLocations(isActive: any(named: 'isActive')),
      ).thenAnswer(
        (_) async =>
            ApiSuccess(locations.map((dto) => Location.fromDTO(dto)).toList()),
      );

      when(
        () => mockRepository.getInventoryOverview(
          locationId: any(named: 'locationId'),
        ),
      ).thenAnswer(
        (_) async => ApiSuccess(InventoryOverview.fromDTO(overviewDTO)),
      );

      final viewModel = container.read(inventoryOverviewProvider.notifier);
      final state = await viewModel.future;

      expect(state.locations, hasLength(1));
      expect(state.locations[0].name, 'Warehouse A');
      expect(state.kpis?.totalItems, 10);
    });

    test('build handles partial failure gracefully - overview fails', () async {
      final locations = [
        LocationDTO(
          id: 1,
          name: 'Warehouse A',
          isActive: true,
          createdAt: '2024-01-01T00:00:00Z',
          updatedAt: '2024-01-01T00:00:00Z',
        ),
      ];

      when(
        () => mockRepository.getLocations(isActive: any(named: 'isActive')),
      ).thenAnswer(
        (_) async =>
            ApiSuccess(locations.map((dto) => Location.fromDTO(dto)).toList()),
      );

      when(
        () => mockRepository.getInventoryOverview(
          locationId: any(named: 'locationId'),
        ),
      ).thenAnswer(
        (_) async => ApiFailure<InventoryOverview>(
          ApiError(type: ApiErrorType.network, message: 'Network error'),
        ),
      );

      final viewModel = container.read(inventoryOverviewProvider.notifier);
      final state = await viewModel.future;

      // Should still have locations even if overview fails
      expect(state.locations, hasLength(1));
      expect(state.locations[0].name, 'Warehouse A');
      expect(state.error, isNotNull);
      expect(state.error, 'Network error');
      // Items and KPIs should be empty (no existing data to preserve on initial load)
      expect(state.items, isEmpty);
      expect(state.kpis, null);
    });

    test(
      'build handles partial failure gracefully - locations fails',
      () async {
        final overviewDTO = InventoryOverviewResponseDTO(
          kpis: InventoryOverviewKPIsDTO(
            totalItems: 10,
            totalSkus: 5,
            totalQuantityAllLocations: '1000.0',
            lowStockItems: 2,
            outOfStockItems: 1,
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
          () => mockRepository.getLocations(isActive: any(named: 'isActive')),
        ).thenAnswer(
          (_) async => ApiFailure<List<Location>>(
            ApiError(type: ApiErrorType.server, message: 'Server error'),
          ),
        );

        when(
          () => mockRepository.getInventoryOverview(
            locationId: any(named: 'locationId'),
          ),
        ).thenAnswer(
          (_) async => ApiSuccess(InventoryOverview.fromDTO(overviewDTO)),
        );

        final viewModel = container.read(inventoryOverviewProvider.notifier);
        final state = await viewModel.future;

        // Should still have overview data even if locations fails
        expect(state.locations, isEmpty); // Empty array on failure
        expect(state.items, hasLength(1));
        expect(state.kpis?.totalItems, 10);
        expect(
          state.error,
          null,
        ); // No error set when locations fails (empty array used)
      },
    );

    test('build handles complete failure gracefully', () async {
      when(
        () => mockRepository.getLocations(isActive: any(named: 'isActive')),
      ).thenAnswer(
        (_) async => ApiFailure<List<Location>>(
          ApiError(type: ApiErrorType.network, message: 'Network error'),
        ),
      );

      when(
        () => mockRepository.getInventoryOverview(
          locationId: any(named: 'locationId'),
        ),
      ).thenAnswer(
        (_) async => ApiFailure<InventoryOverview>(
          ApiError(type: ApiErrorType.server, message: 'Server error'),
        ),
      );

      final viewModel = container.read(inventoryOverviewProvider.notifier);
      final state = await viewModel.future;

      // Both calls failed - should have empty data
      expect(state.locations, isEmpty);
      expect(state.items, isEmpty);
      expect(state.kpis, null);
      expect(state.error, isNotNull);
      expect(state.error, 'Server error'); // Overview error takes precedence
    });

    test('build preserves existing data when error occurs', () async {
      // First, set up initial state with data
      final initialLocations = [
        LocationDTO(
          id: 1,
          name: 'Warehouse A',
          isActive: true,
          createdAt: '2024-01-01T00:00:00Z',
          updatedAt: '2024-01-01T00:00:00Z',
        ),
      ];

      final initialOverviewDTO = InventoryOverviewResponseDTO(
        kpis: InventoryOverviewKPIsDTO(
          totalItems: 10,
          totalSkus: 5,
          totalQuantityAllLocations: '1000.0',
          lowStockItems: 2,
          outOfStockItems: 1,
        ),
        items: [
          InventoryItemDTO(
            id: 1,
            name: 'Initial Product',
            sku: 'SKU-001',
            unit: 'kg',
            kind: 'FINISHED_PRODUCT',
            totalQuantity: '50.0',
          ),
        ],
        page: PaginationDTO(skip: 0, limit: 10, total: 1),
      );

      when(
        () => mockRepository.getLocations(isActive: any(named: 'isActive')),
      ).thenAnswer(
        (_) async => ApiSuccess(
          initialLocations.map((dto) => Location.fromDTO(dto)).toList(),
        ),
      );

      when(
        () => mockRepository.getInventoryOverview(
          locationId: any(named: 'locationId'),
        ),
      ).thenAnswer(
        (_) async => ApiSuccess(InventoryOverview.fromDTO(initialOverviewDTO)),
      );

      final viewModel = container.read(inventoryOverviewProvider.notifier);
      await viewModel.future;

      // Now simulate a refresh that fails - should preserve existing data
      when(
        () => mockRepository.getLocations(isActive: any(named: 'isActive')),
      ).thenAnswer(
        (_) async => ApiSuccess(
          initialLocations.map((dto) => Location.fromDTO(dto)).toList(),
        ),
      );

      when(
        () => mockRepository.getInventoryOverview(
          locationId: any(named: 'locationId'),
        ),
      ).thenAnswer(
        (_) async => ApiFailure<InventoryOverview>(
          ApiError(
            type: ApiErrorType.network,
            message: 'Network error on refresh',
          ),
        ),
      );

      // Trigger refresh by calling build again (simulating a refresh)
      await viewModel.refreshInventory();

      final state = container.read(inventoryOverviewProvider);
      final refreshedState = state.value!;

      // Should preserve existing items and KPIs when overview fails
      expect(refreshedState.items, hasLength(1));
      expect(refreshedState.items[0].name, 'Initial Product');
      expect(refreshedState.kpis?.totalItems, 10);
      expect(refreshedState.error, isNotNull);
      expect(refreshedState.error, 'Network error on refresh');
    });

    test('loadInventoryItems preserves existing data on error', () async {
      // Initialize with some data
      final initialItems = [
        InventoryItem(
          id: 1,
          name: 'Initial Item',
          sku: 'SKU-001',
          unit: 'kg',
          kind: ItemKind.finishedProduct,
        ),
      ];

      when(
        () => mockRepository.getLocations(isActive: any(named: 'isActive')),
      ).thenAnswer((_) async => ApiSuccess([]));
      when(
        () => mockRepository.getInventoryOverview(
          locationId: any(named: 'locationId'),
        ),
      ).thenAnswer(
        (_) async => ApiFailure<InventoryOverview>(
          ApiError(type: ApiErrorType.network, message: 'Network error'),
        ),
      );

      final viewModel = container.read(inventoryOverviewProvider.notifier);
      await viewModel.future;

      // Set initial items manually to simulate existing data
      final currentState = container.read(inventoryOverviewProvider).value!;
      container.read(inventoryOverviewProvider.notifier).state =
          AsyncValue.data(currentState.copyWith(items: initialItems));

      // Now simulate loadInventoryItems failure
      when(
        () => mockRepository.getInventoryItems(
          kind: any(named: 'kind'),
          search: any(named: 'search'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => ApiFailure<InventoryItemsResponse>(
          ApiError(type: ApiErrorType.server, message: 'Server error'),
        ),
      );

      await viewModel.loadInventoryItems();

      final state = container.read(inventoryOverviewProvider);
      // Should preserve existing items on error
      expect(state.value?.items, hasLength(1));
      expect(state.value?.items[0].name, 'Initial Item');
      expect(state.value?.isLoadingItems, false);
    });

    test('loadInventoryItems updates items state', () async {
      final itemsDTO = InventoryItemsResponseDTO(
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
        pagination: PaginationDTO(skip: 0, limit: 10, total: 1),
      );

      when(
        () => mockRepository.getInventoryItems(
          kind: any(named: 'kind'),
          search: any(named: 'search'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => ApiSuccess(
          InventoryItemsResponse(
            items: itemsDTO.items
                .map((dto) => InventoryItem.fromDTO(dto))
                .toList(),
            pagination: PaginationInfo.fromDTO(itemsDTO.pagination),
          ),
        ),
      );

      // Initialize state first
      when(
        () => mockRepository.getLocations(isActive: any(named: 'isActive')),
      ).thenAnswer((_) async => ApiSuccess([]));
      when(
        () => mockRepository.getInventoryOverview(
          locationId: any(named: 'locationId'),
        ),
      ).thenAnswer(
        (_) async => ApiFailure<InventoryOverview>(
          ApiError(type: ApiErrorType.network, message: 'Network error'),
        ),
      );

      final viewModel = container.read(inventoryOverviewProvider.notifier);
      await viewModel.future;

      // Now test loadInventoryItems
      await viewModel.loadInventoryItems();

      final state = container.read(inventoryOverviewProvider);
      expect(state.value?.items, hasLength(1));
      expect(state.value?.items[0].name, 'Test Product');
    });
  });
}
