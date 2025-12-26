import 'package:flutter_test/flutter_test.dart';
import 'package:juix_na/features/inventory/model/inventory_models.dart';
import 'package:juix_na/features/inventory/viewmodel/stock_transfer_state.dart';

void main() {
  group('StockTransferState', () {
    test('initial creates empty state', () {
      final state = StockTransferState.initial();

      expect(state.selectedItem, null);
      expect(state.fromLocationId, null);
      expect(state.toLocationId, null);
      expect(state.quantity, 0.0);
      expect(state.isSubmitting, false);
    });

    test('isValid returns false when item not selected', () {
      final state = StockTransferState(
        fromLocationId: 1,
        toLocationId: 2,
        quantity: 10.0,
      );

      expect(state.isValid, false);
    });

    test('isValid returns false when from location not selected', () {
      final state = StockTransferState(
        selectedItem: InventoryItem(
          id: 1,
          name: 'Test',
          sku: 'SKU-001',
          unit: 'kg',
          kind: ItemKind.finishedProduct,
        ),
        toLocationId: 2,
        quantity: 10.0,
      );

      expect(state.isValid, false);
    });

    test('isValid returns false when to location not selected', () {
      final state = StockTransferState(
        selectedItem: InventoryItem(
          id: 1,
          name: 'Test',
          sku: 'SKU-001',
          unit: 'kg',
          kind: ItemKind.finishedProduct,
        ),
        fromLocationId: 1,
        quantity: 10.0,
      );

      expect(state.isValid, false);
    });

    test('isValid returns false when same location selected', () {
      final state = StockTransferState(
        selectedItem: InventoryItem(
          id: 1,
          name: 'Test',
          sku: 'SKU-001',
          unit: 'kg',
          kind: ItemKind.finishedProduct,
        ),
        fromLocationId: 1,
        toLocationId: 1, // Same location
        quantity: 10.0,
      );

      expect(state.isValid, false);
    });

    test('isValid returns false when quantity is zero', () {
      final state = StockTransferState(
        selectedItem: InventoryItem(
          id: 1,
          name: 'Test',
          sku: 'SKU-001',
          unit: 'kg',
          kind: ItemKind.finishedProduct,
        ),
        fromLocationId: 1,
        toLocationId: 2,
        quantity: 0.0,
      );

      expect(state.isValid, false);
    });

    test('isValid returns false when quantity exceeds available', () {
      final state = StockTransferState(
        selectedItem: InventoryItem(
          id: 1,
          name: 'Test',
          sku: 'SKU-001',
          unit: 'kg',
          kind: ItemKind.finishedProduct,
        ),
        fromLocationId: 1,
        toLocationId: 2,
        quantity: 100.0,
        availableStock: 50.0,
      );

      expect(state.isValid, false);
    });

    test('isValid returns true when all conditions met', () {
      final state = StockTransferState(
        selectedItem: InventoryItem(
          id: 1,
          name: 'Test',
          sku: 'SKU-001',
          unit: 'kg',
          kind: ItemKind.finishedProduct,
        ),
        fromLocationId: 1,
        toLocationId: 2,
        quantity: 30.0,
        availableStock: 50.0,
      );

      expect(state.isValid, true);
    });

    test('hasSameLocations returns true when from and to are same', () {
      final state = StockTransferState(fromLocationId: 1, toLocationId: 1);

      expect(state.hasSameLocations, true);
    });

    test('hasSameLocations returns false when different', () {
      final state = StockTransferState(fromLocationId: 1, toLocationId: 2);

      expect(state.hasSameLocations, false);
    });

    test('locationError returns message when same locations', () {
      final state = StockTransferState(fromLocationId: 1, toLocationId: 1);

      expect(state.locationError, 'From and to locations must be different');
    });

    test('locationError returns null when different locations', () {
      final state = StockTransferState(fromLocationId: 1, toLocationId: 2);

      expect(state.locationError, null);
    });

    test('quantityError returns message when quantity is zero', () {
      final state = StockTransferState(quantity: 0.0);

      expect(state.quantityError, 'Quantity must be greater than 0');
    });

    test('quantityError returns message when exceeds available', () {
      final state = StockTransferState(quantity: 100.0, availableStock: 50.0);

      expect(state.quantityError, contains('exceeds available stock'));
    });

    test('quantityError returns null when valid', () {
      final state = StockTransferState(quantity: 10.0, availableStock: 50.0);

      expect(state.quantityError, null);
    });
  });
}
