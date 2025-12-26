import 'package:flutter_test/flutter_test.dart';
import 'package:juix_na/features/inventory/model/inventory_dtos.dart';
import 'package:juix_na/features/inventory/model/inventory_models.dart';

void main() {
  group('ItemKind', () {
    test('fromString returns correct enum for valid values', () {
      expect(ItemKind.fromString('INGREDIENT'), ItemKind.ingredient);
      expect(ItemKind.fromString('FINISHED_PRODUCT'), ItemKind.finishedProduct);
      expect(ItemKind.fromString('PACKAGING'), ItemKind.packaging);
    });

    test('fromString is case insensitive', () {
      expect(ItemKind.fromString('ingredient'), ItemKind.ingredient);
      expect(ItemKind.fromString('finished_product'), ItemKind.finishedProduct);
    });

    test('fromString returns null for invalid values', () {
      expect(ItemKind.fromString('INVALID'), null);
      expect(ItemKind.fromString(null), null);
    });

    test('value returns correct string', () {
      expect(ItemKind.ingredient.value, 'INGREDIENT');
      expect(ItemKind.finishedProduct.value, 'FINISHED_PRODUCT');
      expect(ItemKind.packaging.value, 'PACKAGING');
    });
  });

  group('MovementType', () {
    test('fromString returns correct enum for valid values', () {
      expect(MovementType.fromString('IN'), MovementType.in_);
      expect(MovementType.fromString('OUT'), MovementType.out);
      expect(MovementType.fromString('ADJUST'), MovementType.adjust);
      expect(MovementType.fromString('TRANSFER'), MovementType.transfer);
    });

    test('fromString is case insensitive', () {
      expect(MovementType.fromString('in'), MovementType.in_);
      expect(MovementType.fromString('out'), MovementType.out);
    });

    test('fromString returns null for invalid values', () {
      expect(MovementType.fromString('INVALID'), null);
      expect(MovementType.fromString(null), null);
    });

    test('value returns correct string', () {
      expect(MovementType.in_.value, 'IN');
      expect(MovementType.out.value, 'OUT');
      expect(MovementType.adjust.value, 'ADJUST');
      expect(MovementType.transfer.value, 'TRANSFER');
    });
  });

  group('Location', () {
    test('fromDTO converts DTO to domain model correctly', () {
      final dto = LocationDTO(
        id: 1,
        name: 'Warehouse A',
        description: 'Main warehouse',
        isActive: true,
        createdAt: '2024-01-01T00:00:00Z',
        updatedAt: '2024-01-02T00:00:00Z',
      );

      final location = Location.fromDTO(dto);

      expect(location.id, 1);
      expect(location.name, 'Warehouse A');
      expect(location.description, 'Main warehouse');
      expect(location.isActive, true);
      expect(location.createdAt, DateTime.parse('2024-01-01T00:00:00Z'));
      expect(location.updatedAt, DateTime.parse('2024-01-02T00:00:00Z'));
    });

    test('fromDTO handles null description', () {
      final dto = LocationDTO(
        id: 2,
        name: 'Warehouse B',
        description: null,
        isActive: true,
        createdAt: '2024-01-01T00:00:00Z',
        updatedAt: '2024-01-01T00:00:00Z',
      );

      final location = Location.fromDTO(dto);

      expect(location.description, null);
    });
  });

  group('ItemLocation', () {
    test('fromDTO converts DTO to domain model correctly', () {
      final dto = ItemLocationDTO(
        locationId: 1,
        locationName: 'Warehouse A',
        currentStock: '100.5',
      );

      final itemLocation = ItemLocation.fromDTO(dto);

      expect(itemLocation.locationId, 1);
      expect(itemLocation.locationName, 'Warehouse A');
      expect(itemLocation.currentStock, 100.5);
    });

    test('fromDTO handles invalid stock string', () {
      final dto = ItemLocationDTO(
        locationId: 1,
        locationName: 'Warehouse A',
        currentStock: 'invalid',
      );

      final itemLocation = ItemLocation.fromDTO(dto);

      expect(itemLocation.currentStock, 0.0);
    });
  });

  group('InventoryItem', () {
    test('fromDTO converts DTO to domain model correctly', () {
      final dto = InventoryItemDTO(
        id: 1,
        name: 'Test Product',
        sku: 'SKU-001',
        unit: 'kg',
        kind: 'FINISHED_PRODUCT',
        totalQuantity: '50.0',
        isLowStock: false,
      );

      final item = InventoryItem.fromDTO(dto);

      expect(item.id, 1);
      expect(item.name, 'Test Product');
      expect(item.sku, 'SKU-001');
      expect(item.unit, 'kg');
      expect(item.kind, ItemKind.finishedProduct);
      expect(item.totalQuantity, 50.0);
      expect(item.isLowStock, false);
    });

    test('fromDTO handles null quantities', () {
      final dto = InventoryItemDTO(
        id: 1,
        name: 'Test Product',
        sku: 'SKU-001',
        unit: 'kg',
        kind: 'FINISHED_PRODUCT',
        totalQuantity: null,
        isLowStock: null,
      );

      final item = InventoryItem.fromDTO(dto);

      expect(item.totalQuantity, null);
      expect(item.isLowStock, null);
    });

    test('fromDTO converts locations array', () {
      final dto = InventoryItemDTO(
        id: 1,
        name: 'Test Product',
        sku: 'SKU-001',
        unit: 'kg',
        kind: 'FINISHED_PRODUCT',
        locations: [
          ItemLocationDTO(
            locationId: 1,
            locationName: 'Warehouse A',
            currentStock: '25.0',
          ),
          ItemLocationDTO(
            locationId: 2,
            locationName: 'Warehouse B',
            currentStock: '30.0',
          ),
        ],
      );

      final item = InventoryItem.fromDTO(dto);

      expect(item.locations, hasLength(2));
      expect(item.locations![0].locationId, 1);
      expect(item.locations![0].currentStock, 25.0);
      expect(item.locations![1].locationId, 2);
      expect(item.locations![1].currentStock, 30.0);
    });
  });
}
