import 'package:flutter_test/flutter_test.dart';
import 'package:juix_na/features/inventory/model/inventory_models.dart';
import 'package:juix_na/features/inventory/viewmodel/inventory_overview_state.dart';

void main() {
  group('InventoryOverviewState', () {
    test('initial creates empty state', () {
      final state = InventoryOverviewState.initial();

      expect(state.items, isEmpty);
      expect(state.kpis, null);
      expect(state.locations, isEmpty);
      expect(state.selectedLocationId, null);
      expect(state.isLoading, false);
      expect(state.error, null);
    });

    test('loading creates loading state', () {
      final state = InventoryOverviewState.loading();

      expect(state.isLoading, true);
    });

    test('error creates error state', () {
      final state = InventoryOverviewState.error('Test error');

      expect(state.error, 'Test error');
      expect(state.isLoading, false);
    });

    test('copyWith updates fields correctly', () {
      final initialState = InventoryOverviewState.initial();
      final items = [
        InventoryItem(
          id: 1,
          name: 'Test Item',
          sku: 'SKU-001',
          unit: 'kg',
          kind: ItemKind.finishedProduct,
        ),
      ];

      final updated = initialState.copyWith(items: items, isLoading: true);

      expect(updated.items, items);
      expect(updated.isLoading, true);
      expect(updated.kpis, null); // Preserved from initial
    });

    test('copyWith clears kpis when clearKpis is true', () {
      final kpis = InventoryOverviewKPIs(
        totalItems: 10,
        totalSkus: 5,
        totalQuantityAllLocations: 1000.0,
        lowStockItems: 2,
        outOfStockItems: 1,
      );
      final state = InventoryOverviewState(kpis: kpis);

      final updated = state.copyWith(clearKpis: true);

      expect(updated.kpis, null);
    });

    test('copyWith clears error when clearError is true', () {
      final state = InventoryOverviewState.error('Test error');

      final updated = state.copyWith(clearError: true);

      expect(updated.error, null);
    });

    test(
      'copyWith clears selectedLocationId when clearSelectedLocation is true',
      () {
        final state = InventoryOverviewState(selectedLocationId: 1);

        final updated = state.copyWith(clearSelectedLocation: true);

        expect(updated.selectedLocationId, null);
      },
    );

    test('hasData returns true when items exist', () {
      final state = InventoryOverviewState(
        items: [
          InventoryItem(
            id: 1,
            name: 'Test',
            sku: 'SKU-001',
            unit: 'kg',
            kind: ItemKind.finishedProduct,
          ),
        ],
      );

      expect(state.hasData, true);
    });

    test('hasData returns true when kpis exist', () {
      final state = InventoryOverviewState(
        kpis: InventoryOverviewKPIs(
          totalItems: 10,
          totalSkus: 5,
          totalQuantityAllLocations: 1000.0,
          lowStockItems: 2,
          outOfStockItems: 1,
        ),
      );

      expect(state.hasData, true);
    });

    test('hasData returns false when empty', () {
      final state = InventoryOverviewState.initial();

      expect(state.hasData, false);
    });

    test('hasError returns true when error exists', () {
      final state = InventoryOverviewState.error('Test error');

      expect(state.hasError, true);
    });

    test('hasError returns false when no error', () {
      final state = InventoryOverviewState.initial();

      expect(state.hasError, false);
    });

    test('isAnyLoading returns true when any loading flag is true', () {
      expect(InventoryOverviewState(isLoading: true).isAnyLoading, true);
      expect(InventoryOverviewState(isLoadingItems: true).isAnyLoading, true);
      expect(InventoryOverviewState(isLoadingKPIs: true).isAnyLoading, true);
      expect(
        InventoryOverviewState(isLoadingLocations: true).isAnyLoading,
        true,
      );
    });

    test('isAnyLoading returns false when all loading flags are false', () {
      final state = InventoryOverviewState.initial();

      expect(state.isAnyLoading, false);
    });

    test('selectedLocation returns correct location', () {
      final location = Location(
        id: 1,
        name: 'Warehouse A',
        isActive: true,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );
      final state = InventoryOverviewState(
        locations: [location],
        selectedLocationId: 1,
      );

      expect(state.selectedLocation?.id, 1);
      expect(state.selectedLocation?.name, 'Warehouse A');
    });

    test('selectedLocation returns null when no location selected', () {
      final state = InventoryOverviewState.initial();

      expect(state.selectedLocation, null);
    });

    test('copyWith preserves existing data when setting loading flag', () {
      final existingItems = [
        InventoryItem(
          id: 1,
          name: 'Existing Item',
          sku: 'SKU-001',
          unit: 'kg',
          kind: ItemKind.finishedProduct,
        ),
      ];
      final existingKpis = InventoryOverviewKPIs(
        totalItems: 10,
        totalSkus: 5,
        totalQuantityAllLocations: 1000.0,
        lowStockItems: 2,
        outOfStockItems: 1,
      );
      final existingLocations = [
        Location(
          id: 1,
          name: 'Warehouse A',
          isActive: true,
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        ),
      ];

      final state = InventoryOverviewState(
        items: existingItems,
        kpis: existingKpis,
        locations: existingLocations,
      );

      // Setting loading flag should preserve all existing data
      final loadingState = state.copyWith(isLoading: true);

      expect(loadingState.items, existingItems);
      expect(loadingState.kpis, existingKpis);
      expect(loadingState.locations, existingLocations);
      expect(loadingState.isLoading, true);
    });

    test('copyWith preserves existing data when setting error', () {
      final existingItems = [
        InventoryItem(
          id: 1,
          name: 'Existing Item',
          sku: 'SKU-001',
          unit: 'kg',
          kind: ItemKind.finishedProduct,
        ),
      ];
      final existingKpis = InventoryOverviewKPIs(
        totalItems: 10,
        totalSkus: 5,
        totalQuantityAllLocations: 1000.0,
        lowStockItems: 2,
        outOfStockItems: 1,
      );

      final state = InventoryOverviewState(
        items: existingItems,
        kpis: existingKpis,
      );

      // Setting error should preserve all existing data
      final errorState = state.copyWith(error: 'New error');

      expect(errorState.items, existingItems);
      expect(errorState.kpis, existingKpis);
      expect(errorState.error, 'New error');
    });

    test('copyWith preserves existing data when setting loadingItems flag', () {
      final existingItems = [
        InventoryItem(
          id: 1,
          name: 'Existing Item',
          sku: 'SKU-001',
          unit: 'kg',
          kind: ItemKind.finishedProduct,
        ),
      ];

      final state = InventoryOverviewState(items: existingItems);

      // Setting isLoadingItems should preserve existing items
      final loadingState = state.copyWith(isLoadingItems: true);

      expect(loadingState.items, existingItems);
      expect(loadingState.isLoadingItems, true);
    });
  });
}
