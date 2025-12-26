import 'package:flutter_test/flutter_test.dart';
import 'package:juix_na/core/network/api_result.dart';
import 'package:juix_na/features/inventory/data/inventory_api.dart';
import 'package:juix_na/features/inventory/data/inventory_repository.dart';
import 'package:juix_na/features/inventory/model/inventory_dtos.dart';
import 'package:juix_na/features/inventory/model/inventory_models.dart';
import 'package:mocktail/mocktail.dart';

class MockInventoryApi extends Mock implements InventoryApi {}

void main() {
  late MockInventoryApi mockApi;
  late InventoryRepository repository;

  setUp(() {
    mockApi = MockInventoryApi();
    repository = InventoryRepository(inventoryApi: mockApi);
  });

  group('InventoryRepository', () {
    group('getLocations', () {
      test('transforms DTOs to domain models on success', () async {
        final dtos = [
          LocationDTO(
            id: 1,
            name: 'Warehouse A',
            description: 'Main warehouse',
            isActive: true,
            createdAt: '2024-01-01T00:00:00Z',
            updatedAt: '2024-01-01T00:00:00Z',
          ),
          LocationDTO(
            id: 2,
            name: 'Warehouse B',
            description: null,
            isActive: true,
            createdAt: '2024-01-01T00:00:00Z',
            updatedAt: '2024-01-01T00:00:00Z',
          ),
        ];

        when(
          () => mockApi.getLocations(isActive: any(named: 'isActive')),
        ).thenAnswer((_) async => ApiSuccess(dtos));

        final result = await repository.getLocations();

        expect(result.isSuccess, true);
        final success = result as ApiSuccess<List<Location>>;
        expect(success.data, hasLength(2));
        expect(success.data[0].id, 1);
        expect(success.data[0].name, 'Warehouse A');
        expect(success.data[1].id, 2);
        expect(success.data[1].name, 'Warehouse B');
      });

      test('passes through error on failure', () async {
        final error = ApiError(
          type: ApiErrorType.network,
          message: 'Network error',
        );

        when(
          () => mockApi.getLocations(isActive: any(named: 'isActive')),
        ).thenAnswer((_) async => ApiFailure<List<LocationDTO>>(error));

        final result = await repository.getLocations();

        expect(result.isFailure, true);
        final failure = result as ApiFailure<List<Location>>;
        expect(failure.error.message, 'Network error');
        expect(failure.error.type, ApiErrorType.network);
      });
    });

    group('getInventoryItems', () {
      test('transforms DTOs to domain models on success', () async {
        final dto = InventoryItemsResponseDTO(
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
          pagination: PaginationDTO(
            skip: 0,
            limit: 10,
            total: 1,
            page: null,
            pageSize: null,
            totalPages: null,
          ),
        );

        when(
          () => mockApi.getInventoryItems(
            kind: any(named: 'kind'),
            search: any(named: 'search'),
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => ApiSuccess(dto));

        final result = await repository.getInventoryItems();

        expect(result.isSuccess, true);
        final success = result as ApiSuccess<InventoryItemsResponse>;
        expect(success.data.items, hasLength(1));
        expect(success.data.items[0].id, 1);
        expect(success.data.items[0].name, 'Test Product');
        expect(success.data.items[0].totalQuantity, 50.0);
        expect(success.data.pagination.total, 1);
      });

      test('passes through error on failure', () async {
        final error = ApiError(
          type: ApiErrorType.server,
          message: 'Server error',
        );

        when(
          () => mockApi.getInventoryItems(
            kind: any(named: 'kind'),
            search: any(named: 'search'),
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => ApiFailure<InventoryItemsResponseDTO>(error));

        final result = await repository.getInventoryItems();

        expect(result.isFailure, true);
        final failure = result as ApiFailure<InventoryItemsResponse>;
        expect(failure.error.message, 'Server error');
      });
    });
  });
}
