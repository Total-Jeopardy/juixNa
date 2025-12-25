# JuixNa Mobile App - Implementation Plan

## Overview
This plan outlines the implementation of all missing pieces to align the Flutter mobile app with the MVVM + Riverpod architecture and connect it to the backend API.

**Backend API Base URL:** `https://juixna-api.onrender.com`

---

## Phase 1: Foundation & Core Infrastructure ✅ → 🔄

### 1.1 Update Configuration
- [x] Update `bootstrap.dart` base URL from `http://127.0.0.1:8000` to `https://juixna-api.onrender.com`
- [x] Add environment configuration (dev/staging/prod URLs)
- [x] Verify API client token injection works correctly

### 1.2 Standardize State Management
- [x] Remove `provider` package dependency (keep only Riverpod)
- [x] Migrate `ThemeController` from `ChangeNotifierProvider` to Riverpod `Notifier`
- [x] Update `main.dart` to use Riverpod providers only
- [x] Update all screens to use Riverpod `Consumer` instead of Provider `Consumer`
- [x] Test theme switching still works

---

## Phase 2: Authentication Module 🔐

### 2.1 Auth Data Layer
- [x] Create `AuthApi` class with login endpoint
- [x] Create `AuthRepository` to wrap API calls
- [x] Create `AuthDTOs` (request/response models)
- [x] Create `UserModel` (domain model)
- [x] Add test accounts to config
- [x] Test login API integration ✅ (Fixed OAuth2 form data format with `username` field, handled null values in response)

### 2.2 Auth State Management
- [x] Create `AuthState` class (loading, authenticated, unauthenticated, error)
- [x] Create `AuthViewModel` using Riverpod `AsyncNotifier`
- [x] Create `authViewModelProvider` for ViewModel
- [x] Create `currentUserProvider` for user data
- [x] Create `isAuthenticatedProvider` for auth status
- [x] Create `userRolesProvider` and `userPermissionsProvider`

### 2.3 Auth UI Integration
- [x] Update `LoginScreen` to use `AuthViewModel`
- [x] Add loading states
- [x] Add error handling and display
- [x] Add success navigation after login
- [x] Add form validation (email format, password required)
- [x] Add test account quick-fill buttons (dev mode only)
- [x] Test full login flow ✅ (Login working with form-encoded OAuth2 format)

### 2.4 Auth Guards & Navigation
- [x] Create auth guard middleware (`AuthGuard` widget)
- [x] Set up initial route based on auth status (in `MainApp`)
- [x] Add logout functionality (logout button in InventoryOverviewScreen)
- [x] Create `AuthErrorHandler` for 401 error handling (auto-logout)
- [x] Add helper functions (`isUserAuthenticated`, `requireAuthentication`)
- [x] Handle token refresh (deferred for v1 - requires re-login on 401)

---

## Phase 3: Inventory Module - Data Layer 📦

### 3.1 Inventory Models & DTOs ✅
- [x] Create `InventoryDTOs`:
  - [x] `LocationDTO` (from locations list endpoint)
  - [x] `ItemLocationDTO` (location breakdown in items)
  - [x] `InventoryItemDTO` (from API with locations array)
  - [x] `PaginationDTO` (skip/limit or page/page_size format)
  - [x] `InventoryItemsResponseDTO` (items + pagination)
  - [x] `LocationItemsResponseDTO` (location + items + pagination)
  - [x] `StockMovementDTO` (transaction history)
  - [x] `StockMovementsResponseDTO` (movements + pagination)
  - [x] `StockTransferRequestDTO` (POST request)
  - [x] `StockTransferResponseDTO` (POST response)
  - [x] `StockAdjustmentRequestDTO` (POST request)
  - [x] `StockAdjustmentResponseDTO` (POST response)
  - [x] `InventoryOverviewKPIsDTO` (KPIs from overview endpoint)
  - [x] `InventoryOverviewResponseDTO` (KPIs + items + pagination)
- [x] Create `InventoryModels` (domain models):
  - [x] `ItemKind` enum (INGREDIENT, FINISHED_PRODUCT, PACKAGING)
  - [x] `MovementType` enum (IN, OUT, ADJUST, TRANSFER)
  - [x] `Location` (convert from DTO, with DateTime parsing)
  - [x] `ItemLocation` (stock at specific location, double parsed)
  - [x] `InventoryItem` (convert from DTO, with helper methods)
  - [x] `PaginationInfo` (with hasMore/currentPage helpers)
  - [x] `StockMovement` (convert from DTO, with isStockIn/isStockOut)
  - [x] `InventoryOverviewKPIs` (convert from DTO, double parsed)
  - [x] `InventoryOverview` (KPIs + items + pagination)
- [x] Add JSON serialization/deserialization (fromJson/toJson in DTOs)

### 3.2 Inventory API ✅
- [x] Create `InventoryApi` class with endpoints:
  - [x] `getLocations(isActive?)` → GET `/api/inventory/locations/`
  - [x] `getInventoryItems(kind?, search?, skip?, limit?)` → GET `/api/inventory/items/`
  - [x] `getLocationItems(locationId, kind?, search?, skip?, limit?)` → GET `/api/inventory/locations/{id}/items/`
  - [x] `getStockMovements(itemId?, locationId?, type?, fromDate?, toDate?, skip?, limit?)` → GET `/api/inventory/stock/movements/`
  - [x] `transferStock(itemId, fromLocationId, toLocationId, quantity, reference?, note?)` → POST `/api/inventory/stock/transfer/`
  - [x] `adjustStock(itemId, locationId, quantity, reason, reference?, note?)` → POST `/api/inventory/stock/adjust/`
  - [x] `getInventoryOverview(locationId?, kind?, search?, page?, pageSize?)` → GET `/api/inventory/overview/` (planned endpoint)
- [x] Add error handling for each endpoint (via ApiResult pattern)
- [x] All endpoints return ApiResult<T> with proper DTO parsing
- [x] Query parameters properly formatted and optional

### 3.3 Inventory Repository ✅
- [x] Create `InventoryRepository` class
- [x] Wrap all API calls with repository methods:
  - [x] `getLocations()` → returns `ApiResult<List<Location>>`
  - [x] `getInventoryItems()` → returns `ApiResult<InventoryItemsResponse>`
  - [x] `getLocationItems()` → returns `ApiResult<LocationItemsResponse>`
  - [x] `getStockMovements()` → returns `ApiResult<StockMovementsResponse>`
  - [x] `transferStock()` → returns `ApiResult<StockTransfer>`
  - [x] `adjustStock()` → returns `ApiResult<StockAdjustment>`
  - [x] `getInventoryOverview()` → returns `ApiResult<InventoryOverview>`
- [x] Add data transformation (DTO → Model) using factory methods
- [x] Create response wrapper classes (InventoryItemsResponse, LocationItemsResponse, StockMovementsResponse)
- [x] Create domain models for StockTransfer and StockAdjustment
- [x] All methods return ApiResult<T> with domain models

---

## Phase 4: Inventory Module - State Management 🧠

### 4.1 Inventory Overview State ✅
- [x] Create `InventoryOverviewState` class:
  - [x] `items: List<InventoryItem>`
  - [x] `kpis: InventoryOverviewKPIs?`
  - [x] `locations: List<Location>`
  - [x] `selectedLocationId: int?`
  - [x] `filters: InventoryFilters`
  - [x] `isLoading: bool`
  - [x] `error: String?`
  - [x] Helper methods: `copyWith()`, `hasData`, `hasError`, `selectedLocation`
  - [x] Factory methods: `loading()`, `error()`, `initial()`
- [x] Create `InventoryFilters` class:
  - [x] `kind: ItemKind?` (INGREDIENT, FINISHED_PRODUCT, PACKAGING)
  - [x] `locationId: int?`
  - [x] `search: String?`
  - [x] `category: String?` (for future use)
  - [x] `brand: String?` (for future use)
  - [x] Helper methods: `copyWith()`, `hasActiveFilters`, `clearAll()`, `toQueryParams()`

### 4.2 Inventory Overview ViewModel ✅
- [x] Create `InventoryOverviewViewModel` using Riverpod `AsyncNotifier`
- [x] Implement `loadInventoryItems()` - loads items with current filters
- [x] Implement `loadKPIs()` - loads overview (KPIs + items) with filters
- [x] Implement `loadLocations()` - loads all locations
- [x] Implement `refreshInventory()` - reloads overview data
- [x] Implement `applyFilters(filters)` - applies filters and reloads data
- [x] Implement `selectLocation(locationId)` - selects location and reloads data
- [x] Implement `clearError()` - clears error state
- [x] Add error handling (via ApiResult pattern)
- [x] Create `inventoryOverviewProvider` (AsyncNotifierProvider)
- [x] Create `inventoryApiProvider` and `inventoryRepositoryProvider`
- [x] Create derived providers: `inventoryItemsProvider`, `inventoryKPIsProvider`, `inventoryLocationsProvider`

### 4.3 Stock Movement State & ViewModel ✅
- [x] Create `StockMovementState` class:
  - [x] Form fields (movementType, date, item, location, quantity, reason, reference, note)
  - [x] Available options (items, locations)
  - [x] Available stock for validation
  - [x] Granular loading flags (isLoadingItems, isLoadingLocations, isLoadingAvailableStock, isSubmitting)
  - [x] Validation helpers (isValid, quantityExceedsAvailable, quantityError)
- [x] Create `StockMovementViewModel` using Riverpod `AsyncNotifier`
- [x] Implement `loadProducts(locationId?)` - loads items for product picker
- [x] Implement `loadAvailableStock(itemId, locationId)` - loads stock for validation
- [x] Implement `createStockMovement()` - creates stock adjustment (positive=IN, negative=OUT)
- [x] Implement form field setters (setMovementType, selectItem, selectLocation, setQuantity, etc.)
- [x] Add validation logic (form validation, quantity checks, field errors)
- [x] Preserve existing state on errors
- [x] Create `stockMovementProvider` (AsyncNotifierProvider)
- [x] Note: Batches not required for v1 (per API spec)

### 4.4 Cycle Count State & ViewModel ✅
- [x] Create `CycleCountState` class:
  - [x] Form fields (date, item, location, systemQuantity, countedQuantity, note)
  - [x] Available options (items, locations)
  - [x] Granular loading flags (isLoadingItems, isLoadingLocations, isLoadingSystemQuantity, isSubmitting)
  - [x] Variance calculation helpers (variance, hasVariance, isPositiveVariance, isNegativeVariance, absoluteVariance)
  - [x] Validation helpers (isValid)
- [x] Create `CycleCountViewModel` using Riverpod `AsyncNotifier`
- [x] Implement `loadProducts(locationId?)` - loads items for product picker
- [x] Implement `getSystemQuantity(itemId, locationId)` - loads system quantity for selected item/location
- [x] Implement `createCycleCount()` - validates and records cycle count (local operation)
- [x] Implement `adjustStockFromCount()` - applies stock adjustment based on variance
- [x] Implement form field setters (selectItem, selectLocation, setDate, setCountedQuantity, setNote)
- [x] Auto-load system quantity when item+location selected
- [x] Preserve existing state on errors
- [x] Create `cycleCountProvider` (AsyncNotifierProvider)
- [x] Note: Batches not required for v1 (per API spec); cycle count uses adjustStock endpoint with CYCLE_COUNT reason

### 4.5 Reorder Alerts State & ViewModel ✅
- [x] Create `ReorderAlertsState` class:
  - [x] `ReorderAlert` model (item, currentStock, severity, locationName, etc.)
  - [x] `ReorderAlertSeverity` enum (critical, low)
  - [x] Alert list with filtering helpers (criticalAlerts, lowStockAlerts, outOfStockAlerts)
  - [x] Count helpers (totalCount, criticalCount, outOfStockCount)
  - [x] Location filtering support
- [x] Create `ReorderAlertsViewModel` using Riverpod `AsyncNotifier`
- [x] Implement `loadReorderAlerts(locationId?)` - loads alerts from inventory overview
- [x] Implement `filterByLocation(locationId)` - filters alerts by location
- [x] Implement `dismissAlert(alert)` - removes alert from list (local operation)
- [x] Implement `dismissAlerts(alerts)` - dismisses multiple alerts
- [x] Implement `refresh()` - reloads alerts from API
- [x] Implement `clearError()` - clears error state
- [x] Preserve existing state on errors
- [x] Create `reorderAlertsProvider` (AsyncNotifierProvider)
- [x] Create derived providers: `criticalAlertsProvider`, `outOfStockAlertsProvider`, `reorderAlertsCountProvider`
- [x] Note: Uses inventory overview endpoint with `is_low_stock` flag; no dedicated reorder alerts endpoint in API spec
- [x] Note: `createReorderRequest` deferred - would require procurement/purchase order endpoint (not in current API spec)

### 4.6 Stock Transfer State & ViewModel ✅
- [x] Create `StockTransferState` class:
  - [x] Form fields (date, item, fromLocationId, toLocationId, quantity, reference, note)
  - [x] Available options (items, locations)
  - [x] Available stock for validation
  - [x] Granular loading flags (isLoadingItems, isLoadingLocations, isLoadingAvailableStock, isSubmitting)
  - [x] Validation helpers (isValid, quantityExceedsAvailable, hasSameLocations, quantityError, locationError)
  - [x] Location helpers (fromLocation, toLocation)
- [x] Create `StockTransferViewModel` using Riverpod `AsyncNotifier`
- [x] Implement `loadProducts(locationId?)` - loads items for product picker
- [x] Implement `getAvailableStock(itemId, locationId)` - loads stock at from-location for validation
- [x] Implement `createStockTransfer()` - creates stock transfer between locations
- [x] Implement form field setters (selectItem, setFromLocation, setToLocation, setQuantity, setDate, setReference, setNote)
- [x] Auto-load available stock when item+fromLocation selected
- [x] Preserve existing state on errors
- [x] Create `stockTransferProvider` (AsyncNotifierProvider)
- [x] Note: Batches not required for v1 (per API spec)
- [x] Note: `loadTransferHistory` deferred - would use stock movements endpoint with type=TRANSFER filter (can be added when needed)

---

## Phase 5: Inventory Module - UI Integration 🎨

### 5.1 Inventory Overview Screen
- [ ] Replace `StatefulWidget` with `ConsumerWidget`
- [ ] Connect to `inventoryOverviewProvider`
- [ ] Replace dummy data with ViewModel data
- [ ] Add loading state UI
- [ ] Add error state UI
- [ ] Add empty state UI
- [ ] Implement pull-to-refresh
- [ ] Wire up filter chips to ViewModel
- [ ] Wire up location selector to ViewModel
- [ ] Wire up search field to ViewModel
- [ ] Wire up FAB to navigate to Stock Movement
- [ ] Wire up stock card tap to show details (future)
- [ ] Test all interactions

### 5.2 Stock Movement Screen
- [ ] Replace `StatefulWidget` with `ConsumerWidget`
- [ ] Connect to `stockMovementProvider`
- [ ] Replace dummy data with ViewModel data
- [ ] Implement product picker (load from API)
- [ ] Implement batch picker (load from API, conditional)
- [ ] Implement location picker (load from API)
- [ ] Implement available stock validation (from API)
- [ ] Wire up form submission to ViewModel
- [ ] Add loading states during submission
- [ ] Add success/error feedback
- [ ] Navigate back on success
- [ ] Test full flow

### 5.3 Cycle Counts Screen
- [ ] Implement full UI (currently empty file)
- [ ] Connect to `cycleCountProvider`
- [ ] Implement product picker
- [ ] Implement batch picker (conditional)
- [ ] Implement location picker
- [ ] Load system quantity from API
- [ ] Implement count input
- [ ] Calculate variance
- [ ] Wire up "Adjust Stock" button
- [ ] Wire up "Save Count" button
- [ ] Add validation
- [ ] Add loading/error states
- [ ] Test full flow

### 5.4 Reorder Alerts Screen
- [ ] Create new screen file
- [ ] Design UI (list of alerts with badges)
- [ ] Connect to `reorderAlertsProvider`
- [ ] Display alerts with severity badges (CRITICAL/LOW)
- [ ] Show current stock, reorder target, suggested amount
- [ ] Implement "Create Request" action
- [ ] Implement "View Product" action
- [ ] Implement "Dismiss" action
- [ ] Add loading/error/empty states
- [ ] Test all interactions

### 5.5 Stock Transfer Screen
- [ ] Create new screen file
- [ ] Design UI (from/to location, product, batch, quantity)
- [ ] Connect to `stockTransferProvider`
- [ ] Implement product picker
- [ ] Implement batch picker (conditional)
- [ ] Implement from-location picker
- [ ] Implement to-location picker
- [ ] Validate from != to
- [ ] Load available stock from source location
- [ ] Validate quantity doesn't exceed available
- [ ] Wire up form submission
- [ ] Add loading/error/success states
- [ ] Navigate back on success
- [ ] Test full flow

### 5.6 Transfer History Screen
- [ ] Create new screen file
- [ ] Design UI (list of transfers with status badges)
- [ ] Connect to `stockTransferProvider`
- [ ] Display transfers with:
  - [ ] Status (SYNCED/PENDING/FAILED)
  - [ ] Product, batch, quantity
  - [ ] From/to locations
  - [ ] Date/time
- [ ] Add filters (date range, status, location)
- [ ] Add loading/error/empty states
- [ ] Implement retry for failed transfers (if needed)
- [ ] Test all interactions

---

## Phase 6: Navigation & Routing 🧭

### 6.1 Add Routing Package
- [ ] Add `go_router` package to `pubspec.yaml`
- [ ] Run `flutter pub get`
- [ ] Create `app/router.dart` with route definitions:
  - [ ] `/login` → LoginScreen
  - [ ] `/dashboard` → DashboardScreen (future)
  - [ ] `/inventory` → InventoryOverviewScreen
  - [ ] `/inventory/movement` → StockMovementScreen
  - [ ] `/inventory/cycle-count` → CycleCountsScreen
  - [ ] `/inventory/reorder-alerts` → ReorderAlertsScreen
  - [ ] `/inventory/transfer` → StockTransferScreen
  - [ ] `/inventory/transfer/history` → TransferHistoryScreen
- [ ] Add route guards (auth required)
- [ ] Add route parameters (e.g., productId, locationId)

### 6.2 Update Main App
- [ ] Replace `MaterialApp` with `MaterialApp.router`
- [ ] Connect to router configuration
- [ ] Update all `Navigator.push` to use `context.go` or `context.push`
- [ ] Test all navigation flows

### 6.3 Navigation Integration
- [ ] Wire up FAB in Inventory Overview → Stock Movement
- [ ] Wire up "View Recent Movements" → Transfer History
- [ ] Wire up filter actions → appropriate screens
- [ ] Wire up reorder alert actions → appropriate screens
- [ ] Add back navigation handling
- [ ] Test all navigation paths

---

## Phase 7: Additional Features & Polish ✨

### 7.1 Error Handling & User Feedback
- [ ] Create global error handler
- [ ] Add snackbar/toast for success messages
- [ ] Add error dialogs for critical errors
- [ ] Add retry mechanisms for failed requests
- [ ] Handle network connectivity issues
- [ ] Add offline detection (informational only, no offline mode)

### 7.2 Loading States
- [ ] Ensure all screens show loading indicators
- [ ] Add skeleton loaders (optional enhancement)
- [ ] Prevent duplicate requests
- [ ] Add request cancellation on screen dispose

### 7.3 Form Validation
- [ ] Add comprehensive validation to all forms
- [ ] Show inline validation errors
- [ ] Disable submit buttons when invalid
- [ ] Add field-level error messages

### 7.4 Search & Filtering
- [ ] Implement real-time search in Inventory Overview
- [ ] Implement filter persistence (optional)
- [ ] Add filter reset functionality
- [ ] Test all filter combinations

### 7.5 Data Refresh
- [ ] Add pull-to-refresh to all list screens
- [ ] Add manual refresh buttons
- [ ] Add auto-refresh on screen focus (optional)
- [ ] Handle stale data scenarios

---

## Phase 8: Testing & Quality Assurance 🧪

### 8.1 Unit Tests
- [ ] Test ViewModels (state changes, error handling)
- [ ] Test Repositories (data transformation)
- [ ] Test API clients (request building, response parsing)
- [ ] Test models (serialization/deserialization)

### 8.2 Integration Tests
- [ ] Test full login flow
- [ ] Test inventory loading flow
- [ ] Test stock movement creation flow
- [ ] Test cycle count flow
- [ ] Test stock transfer flow

### 8.3 UI Tests (Optional)
- [ ] Test critical user flows
- [ ] Test navigation flows
- [ ] Test form submissions

### 8.4 Manual Testing
- [ ] Test on Android device
- [ ] Test on iOS device (if available)
- [ ] Test dark mode on all screens
- [ ] Test error scenarios (network errors, API errors)
- [ ] Test edge cases (empty lists, large data sets)
- [ ] Test with different user roles/permissions

---

## Phase 9: Documentation & Cleanup 📚

### 9.1 Code Documentation
- [ ] Add doc comments to all public APIs
- [ ] Document ViewModel methods
- [ ] Document Repository methods
- [ ] Add README for each feature module

### 9.2 Code Cleanup
- [ ] Remove unused imports
- [ ] Remove commented-out code
- [ ] Remove dummy/hardcoded data
- [ ] Ensure consistent code style
- [ ] Run `dart format` on all files
- [ ] Fix all linter warnings

### 9.3 Project Documentation
- [ ] Update main README.md with:
  - [ ] Architecture overview
  - [ ] Setup instructions
  - [ ] API configuration
  - [ ] Build instructions
- [ ] Document environment variables
- [ ] Document deployment process

---

## Phase 10: Future Enhancements 🚀

### 10.1 Additional Modules (Post-MVP)
- [ ] Sales module (POS, Sales history)
- [ ] Production module (batch planning, execution)
- [ ] Reports module (analytics, charts)
- [ ] Settings module (user profile, preferences)

### 10.2 Performance Optimizations
- [ ] Add pagination for large lists
- [ ] Implement image caching (if needed)
- [ ] Optimize API calls (batch requests, debouncing)
- [ ] Add request caching (optional)

### 10.3 UX Enhancements
- [ ] Add animations/transitions
- [ ] Add haptic feedback
- [ ] Improve accessibility
- [ ] Add keyboard shortcuts (web/desktop)

---

## Progress Tracking

**Current Phase:** Phase 1 - Foundation & Core Infrastructure

**Completed:** 0/150+ tasks

**Next Milestone:** Complete Phase 1 & 2 (Auth Module)

---

## Notes

- Each phase should be completed before moving to the next
- Some tasks can be done in parallel (e.g., API + Repository)
- Test after each major feature implementation
- Keep backend API documentation handy for endpoint details
- Update this plan as we discover new requirements

---

## Quick Reference: Backend Endpoints

Based on the plan, expected endpoints:
- `POST /api/auth/login`
- `GET /api/inventory/items`
- `GET /api/inventory/kpis`
- `GET /api/inventory/locations`
- `POST /api/inventory/movements`
- `GET /api/inventory/movements`
- `GET /api/inventory/reorder-alerts`
- `POST /api/inventory/cycle-counts`
- `POST /api/inventory/transfers`
- `GET /api/inventory/transfers`

*Verify actual endpoints with backend team/API docs*

