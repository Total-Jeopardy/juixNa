import 'package:flutter_test/flutter_test.dart';
import 'package:juix_na/features/inventory/model/inventory_models.dart';
import 'package:juix_na/features/inventory/viewmodel/stock_movement_state.dart';

void main() {
  group('StockMovementState', () {
    test('initial creates empty state', () {
      final state = StockMovementState.initial();

      expect(state.selectedItem, null);
      expect(state.selectedLocationId, null);
      expect(state.quantity, 0.0);
      expect(state.reason, '');
      expect(state.movementType, StockMovementType.stockOut);
      expect(state.isSubmitting, false);
    });

    test('isValid returns false when item not selected', () {
      final state = StockMovementState(
        selectedLocationId: 1,
        quantity: 10.0,
        reason: 'Test',
      );

      expect(state.isValid, false);
    });

    test('isValid returns false when location not selected', () {
      final state = StockMovementState(
        selectedItem: InventoryItem(
          id: 1,
          name: 'Test',
          sku: 'SKU-001',
          unit: 'kg',
          kind: ItemKind.finishedProduct,
        ),
        quantity: 10.0,
        reason: 'Test',
      );

      expect(state.isValid, false);
    });

    test('isValid returns false when quantity is zero', () {
      final state = StockMovementState(
        selectedItem: InventoryItem(
          id: 1,
          name: 'Test',
          sku: 'SKU-001',
          unit: 'kg',
          kind: ItemKind.finishedProduct,
        ),
        selectedLocationId: 1,
        quantity: 0.0,
        reason: 'Test',
      );

      expect(state.isValid, false);
    });

    test('isValid returns false when reason is empty', () {
      final state = StockMovementState(
        selectedItem: InventoryItem(
          id: 1,
          name: 'Test',
          sku: 'SKU-001',
          unit: 'kg',
          kind: ItemKind.finishedProduct,
        ),
        selectedLocationId: 1,
        quantity: 10.0,
        reason: '',
      );

      expect(state.isValid, false);
    });

    test('isValid returns true for valid stock-in', () {
      final state = StockMovementState(
        movementType: StockMovementType.stockIn,
        selectedItem: InventoryItem(
          id: 1,
          name: 'Test',
          sku: 'SKU-001',
          unit: 'kg',
          kind: ItemKind.finishedProduct,
        ),
        selectedLocationId: 1,
        quantity: 10.0,
        reason: 'Test reason',
      );

      expect(state.isValid, true);
    });

    test('isValid returns false when stock-out exceeds available', () {
      final state = StockMovementState(
        movementType: StockMovementType.stockOut,
        selectedItem: InventoryItem(
          id: 1,
          name: 'Test',
          sku: 'SKU-001',
          unit: 'kg',
          kind: ItemKind.finishedProduct,
        ),
        selectedLocationId: 1,
        quantity: 100.0, // Exceeds available
        availableStock: 50.0,
        reason: 'Test reason',
      );

      expect(state.isValid, false);
    });

    test('isValid returns true when stock-out within available', () {
      final state = StockMovementState(
        movementType: StockMovementType.stockOut,
        selectedItem: InventoryItem(
          id: 1,
          name: 'Test',
          sku: 'SKU-001',
          unit: 'kg',
          kind: ItemKind.finishedProduct,
        ),
        selectedLocationId: 1,
        quantity: 30.0,
        availableStock: 50.0,
        reason: 'Test reason',
      );

      expect(state.isValid, true);
    });

    test('quantityExceedsAvailable returns true when exceeds', () {
      final state = StockMovementState(
        movementType: StockMovementType.stockOut,
        quantity: 100.0,
        availableStock: 50.0,
      );

      expect(state.quantityExceedsAvailable, true);
    });

    test('quantityExceedsAvailable returns false for stock-in', () {
      final state = StockMovementState(
        movementType: StockMovementType.stockIn,
        quantity: 100.0,
        availableStock: 50.0,
      );

      expect(state.quantityExceedsAvailable, false);
    });

    test('quantityError returns message when quantity is zero', () {
      final state = StockMovementState(quantity: 0.0);

      expect(state.quantityError, 'Quantity must be greater than 0');
    });

    test('quantityError returns message when exceeds available', () {
      final state = StockMovementState(
        movementType: StockMovementType.stockOut,
        quantity: 100.0,
        availableStock: 50.0,
      );

      expect(state.quantityError, contains('exceeds available stock'));
    });

    test('quantityError returns null when valid', () {
      final state = StockMovementState(quantity: 10.0, availableStock: 50.0);

      expect(state.quantityError, null);
    });

    test('copyWith updates fields correctly', () {
      final initialState = StockMovementState.initial();
      final item = InventoryItem(
        id: 1,
        name: 'Test',
        sku: 'SKU-001',
        unit: 'kg',
        kind: ItemKind.finishedProduct,
      );

      final updated = initialState.copyWith(
        selectedItem: item,
        quantity: 10.0,
        reason: 'Test reason',
      );

      expect(updated.selectedItem?.id, 1);
      expect(updated.quantity, 10.0);
      expect(updated.reason, 'Test reason');
    });

    test('copyWith clears selectedItem when clearSelectedItem is true', () {
      final state = StockMovementState(
        selectedItem: InventoryItem(
          id: 1,
          name: 'Test',
          sku: 'SKU-001',
          unit: 'kg',
          kind: ItemKind.finishedProduct,
        ),
      );

      final updated = state.copyWith(clearSelectedItem: true);

      expect(updated.selectedItem, null);
    });
  });
}
