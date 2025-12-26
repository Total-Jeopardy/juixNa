import 'package:flutter_test/flutter_test.dart';
import 'package:juix_na/features/inventory/model/inventory_models.dart';
import 'package:juix_na/features/inventory/viewmodel/cycle_count_state.dart';

void main() {
  group('CycleCountState', () {
    test('initial creates empty state', () {
      final state = CycleCountState.initial();

      expect(state.selectedItem, null);
      expect(state.selectedLocationId, null);
      expect(state.systemQuantity, null);
      expect(state.countedQuantity, null);
      expect(state.isSubmitting, false);
    });

    test('isValid returns false when item not selected', () {
      final state = CycleCountState(
        selectedLocationId: 1,
        systemQuantity: 10.0,
        countedQuantity: 10.0,
      );

      expect(state.isValid, false);
    });

    test('isValid returns false when location not selected', () {
      final state = CycleCountState(
        selectedItem: InventoryItem(
          id: 1,
          name: 'Test',
          sku: 'SKU-001',
          unit: 'kg',
          kind: ItemKind.finishedProduct,
        ),
        systemQuantity: 10.0,
        countedQuantity: 10.0,
      );

      expect(state.isValid, false);
    });

    test('isValid returns false when system quantity not set', () {
      final state = CycleCountState(
        selectedItem: InventoryItem(
          id: 1,
          name: 'Test',
          sku: 'SKU-001',
          unit: 'kg',
          kind: ItemKind.finishedProduct,
        ),
        selectedLocationId: 1,
        countedQuantity: 10.0,
      );

      expect(state.isValid, false);
    });

    test('isValid returns false when counted quantity not set', () {
      final state = CycleCountState(
        selectedItem: InventoryItem(
          id: 1,
          name: 'Test',
          sku: 'SKU-001',
          unit: 'kg',
          kind: ItemKind.finishedProduct,
        ),
        selectedLocationId: 1,
        systemQuantity: 10.0,
      );

      expect(state.isValid, false);
    });

    test('isValid returns true when all required fields set', () {
      final state = CycleCountState(
        selectedItem: InventoryItem(
          id: 1,
          name: 'Test',
          sku: 'SKU-001',
          unit: 'kg',
          kind: ItemKind.finishedProduct,
        ),
        selectedLocationId: 1,
        systemQuantity: 10.0,
        countedQuantity: 10.0,
      );

      expect(state.isValid, true);
    });

    test('variance calculates correctly', () {
      final state = CycleCountState(
        systemQuantity: 10.0,
        countedQuantity: 12.0,
      );

      expect(state.variance, 2.0);
    });

    test('variance returns null when quantities not set', () {
      final state = CycleCountState.initial();

      expect(state.variance, null);
    });

    test('hasVariance returns true when variance exists', () {
      final state = CycleCountState(
        systemQuantity: 10.0,
        countedQuantity: 12.0,
      );

      expect(state.hasVariance, true);
    });

    test('hasVariance returns false when no variance', () {
      final state = CycleCountState(
        systemQuantity: 10.0,
        countedQuantity: 10.0,
      );

      expect(state.hasVariance, false);
    });

    test('isPositiveVariance returns true when counted > system', () {
      final state = CycleCountState(
        systemQuantity: 10.0,
        countedQuantity: 12.0,
      );

      expect(state.isPositiveVariance, true);
    });

    test('isNegativeVariance returns true when counted < system', () {
      final state = CycleCountState(systemQuantity: 10.0, countedQuantity: 8.0);

      expect(state.isNegativeVariance, true);
    });

    test('absoluteVariance returns absolute value', () {
      final state = CycleCountState(systemQuantity: 10.0, countedQuantity: 8.0);

      expect(state.absoluteVariance, 2.0);
    });
  });
}
