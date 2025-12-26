import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:juix_na/bootstrap.dart';
import 'package:juix_na/core/auth/token_store.dart';
import 'package:juix_na/core/network/api_client.dart';
import 'package:juix_na/core/network/api_result.dart';
import 'package:juix_na/features/auth/model/auth_dtos.dart';
import 'package:juix_na/features/auth/viewmodel/auth_state.dart';
import 'package:juix_na/features/auth/viewmodel/auth_vm.dart';
import 'package:juix_na/features/inventory/data/inventory_api.dart';
import 'package:juix_na/features/inventory/model/inventory_dtos.dart';
import 'package:juix_na/features/inventory/viewmodel/inventory_overview_vm.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockTokenStore extends Mock implements TokenStore {}

class MockInventoryApi extends Mock implements InventoryApi {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Integration Tests', () {
    late MockApiClient mockApiClient;
    late MockTokenStore mockTokenStore;
    late MockInventoryApi mockInventoryApi;
    late ProviderContainer container;

    setUp(() {
      mockApiClient = MockApiClient();
      mockTokenStore = MockTokenStore();
      mockInventoryApi = MockInventoryApi();

      // Setup token store mocks
      when(() => mockTokenStore.getAccessToken()).thenAnswer((_) async => null);
      when(
        () => mockTokenStore.saveAccessToken(any()),
      ).thenAnswer((_) async => {});
      when(() => mockTokenStore.clear()).thenAnswer((_) async => {});

      container = ProviderContainer(
        overrides: [
          // Override core providers
          tokenStoreProvider.overrideWithValue(mockTokenStore),
          apiClientProvider.overrideWithValue(mockApiClient),
          // Override inventory API provider
          inventoryApiProvider.overrideWithValue(mockInventoryApi),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Login Flow', () {
      testWidgets('full login flow - success path', (
        WidgetTester tester,
      ) async {
        // Setup: Mock successful login response
        final userDTO = UserDTO(
          id: 1,
          email: 'test@example.com',
          name: 'Test User',
          roles: [],
          permissions: [],
        );

        final loginResponse = LoginResponseDTO(
          accessToken: 'test_token_123',
          tokenType: 'bearer',
          user: userDTO,
        );

        when(
          () => mockApiClient.post<LoginResponseDTO>(
            any(),
            body: any(named: 'body'),
            useFormData: any(named: 'useFormData'),
            parse: any(named: 'parse'),
          ),
        ).thenAnswer((_) async => ApiSuccess(loginResponse));

        // Execute: Login
        final authViewModel = container.read(authViewModelProvider.notifier);
        await authViewModel.login(
          email: 'test@example.com',
          password: 'password123',
        );

        // Verify: State is authenticated
        final authState = container.read(authViewModelProvider);
        expect(authState.value, isA<AuthStateAuthenticated>());

        final authenticatedState = authState.value as AuthStateAuthenticated;
        expect(authenticatedState.user.email, 'test@example.com');
        expect(authenticatedState.user.name, 'Test User');

        // Verify: Token was saved
        verify(
          () => mockTokenStore.saveAccessToken('test_token_123'),
        ).called(1);
      });

      testWidgets('full login flow - failure path', (
        WidgetTester tester,
      ) async {
        // Setup: Mock failed login
        when(
          () => mockApiClient.post<LoginResponseDTO>(
            any(),
            body: any(named: 'body'),
            useFormData: any(named: 'useFormData'),
            parse: any(named: 'parse'),
          ),
        ).thenAnswer(
          (_) async => ApiFailure<LoginResponseDTO>(
            ApiError(
              type: ApiErrorType.unauthorized,
              message: 'Invalid credentials',
            ),
          ),
        );

        // Execute: Login with wrong credentials
        final authViewModel = container.read(authViewModelProvider.notifier);
        await authViewModel.login(email: 'test@example.com', password: 'wrong');

        // Verify: State is error
        final authState = container.read(authViewModelProvider);
        expect(authState.value, isA<AuthStateError>());

        final errorState = authState.value as AuthStateError;
        expect(errorState.message, 'Invalid credentials');

        // Verify: Token was NOT saved
        verifyNever(() => mockTokenStore.saveAccessToken(any()));
      });
    });

    group('Inventory Loading Flow', () {
      testWidgets('full inventory loading flow', (WidgetTester tester) async {
        // Setup: Mock successful inventory data
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

        // Execute: Load inventory
        final inventoryViewModel = container.read(
          inventoryOverviewProvider.notifier,
        );
        final state = await inventoryViewModel.future;

        // Verify: Data loaded correctly
        expect(state.locations, hasLength(1));
        expect(state.locations[0].name, 'Warehouse A');
        expect(state.items, hasLength(1));
        expect(state.items[0].name, 'Test Product');
        expect(state.kpis?.totalItems, 10);
        expect(state.kpis?.lowStockItems, 2);
      });
    });
  });
}
