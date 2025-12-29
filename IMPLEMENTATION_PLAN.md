# JuixNa Mobile App - Implementation Plan

## Overview
This plan outlines the implementation of remaining enhancements and new modules for the Flutter mobile app using MVVM + Riverpod architecture.

**Backend API Base URL:** `https://juixna-api.onrender.com`

---

## ✅ Completed Modules

### Phase 1: Foundation & Core Infrastructure ✅
- All foundation work complete

### Phase 2: Authentication Module ✅
- Complete authentication system with login, state management, and guards

### Inventory Module ✅
- All 6 inventory screens implemented and tested
- Complete data layer with API integration
- Full state management with Riverpod
- Comprehensive UI with role-based access
- 99 automated tests (all passing)
- Navigation integrated with go_router

### Dashboard Module ✅
- Complete dashboard with all KPIs, charts, alerts
- Role-based visibility for all components
- Loading/error/empty states
- Inventory Clerk dashboard
- All charts implemented (Sales Trend, Top Products, Expense, Channel, Inventory Value)
- Navigation and filters complete

---

## Remaining Dashboard Enhancements (Low Priority)

### Dashboard - Future Enhancements
- [ ] **Chart Tap Handlers**: Implement tap handlers for chart elements (bar chart taps, pie chart section taps) - requires complex gesture detection with coordinate calculations
- [ ] **KPI Detail Navigation**: Replace "coming soon" messages with actual navigation to detail screens (depends on Sales Report, Expense Report, Profit Analysis screens)
- [ ] **Automated Tests**: Add unit/widget tests for dashboard module (when time permits)
- [ ] **Performance Optimizations**: Debounce filter changes, lazy load charts, optimize chart rendering (if performance issues arise)

**Note:** Dashboard module is feature-complete. These are optional enhancements that can be added later.

---

## Next Modules to Implement

### Sales Module (Suggested Next)
**Priority:** High
**Dependencies:** Dashboard (completed), Authentication (completed)

**Potential Screens:**
- [ ] Sales Overview/Dashboard screen
- [ ] Sales List/History screen
- [ ] Sales Detail screen
- [ ] Create/Edit Sale screen
- [ ] Sales Report screen
- [ ] Product Sales Detail screen (from dashboard KPI taps)

**Data Layer:**
- [ ] Sales DTOs (SalesItem, SalesTransaction, SalesReport)
- [ ] Sales API class
- [ ] Sales Repository
- [ ] Sales Models

**State Management:**
- [ ] Sales State
- [ ] Sales ViewModel
- [ ] Sales Providers

**Features:**
- [ ] Sales list with filters (date range, location, product)
- [ ] Create new sale transaction
- [ ] View sale details
- [ ] Sales reports and analytics
- [ ] Integration with dashboard (sales KPIs, charts)
- [ ] Role-based access (Sales role, Manager, Admin)

---

### Production Module 📦 (Next to Implement)
**Priority:** Medium
**Dependencies:** Inventory (completed), Dashboard (completed)

---

## Phase 10: Production Module - Data Layer 📊

### 10.1 Production Models & DTOs ✅
- [x] Create `ProductionDTOs`:
  - [x] `PurchaseEntryRequestDTO` (supplier_id, date, ref_invoice, items[], mark_as_received)
  - [x] `PurchaseItemDTO` (item_id, item_name, quantity, unit, unit_cost, subtotal)
  - [x] `PurchaseReceiptDTO` (id, supplier, reference, date, created_by, status, items[], total_cost, timestamp)
  - [x] `ReceiptItemDTO` (item_id, item_name, quantity, unit, unit_cost, subtotal, receiving_quantity?)
  - [x] `ProductionBatchDTO` (id, product_id, product_name, production_date, location_id, planned_output, actual_output?, status, notes, batch_number)
  - [x] `BatchInputDTO` (input_id, input_name, lot_number?, expiry_date?, required_quantity, available_quantity, unit, status)
  - [x] `BatchPackagingDTO` (packaging_id, packaging_name, sku?, required_quantity, available_quantity, status)
  - [x] `BatchWastageDTO` (quantity, reason_code, reason_description?)
  - [x] `BatchInputsResponseDTO` (ingredients, packaging)
  - [x] `BatchStatusDTO` enum (DRAFT, PENDING, IN_PROGRESS, COMPLETED, CANCELLED)
  - [x] `ReceiptStatusDTO` enum (PENDING, APPROVED, REJECTED)
  - [x] `StockAdjustmentTypeDTO` enum (WASTAGE, CORRECTION, OTHER)
  - [x] `ActivityItemDTO` (for recent activity feed)
  - [x] `ReviewReceiptRequestDTO`, `CreateBatchRequestDTO`, `ConfirmBatchInputsRequestDTO`, `CompleteBatchRequestDTO`
- [x] Create `ProductionModels` (domain models):
  - [x] `PurchaseEntry` (supplierId, date, refInvoice, items, markAsReceived) with `calculateTotal()`, `calculateTotalQuantity()`, `getTotalItemsCount()`, `isValid()`
  - [x] `PurchaseItem` (itemId, itemName, quantity, unit, unitCost, subtotal) with `calculateSubtotal()`, `copyWith()`
  - [x] `PurchaseReceipt` (id, supplier, reference, date, createdBy, status, items, totalCost, timestamp) with `getSummary()`, `canApprove()`, `canReject()`
  - [x] `ReceiptItem` (itemId, itemName, quantity, unit, unitCost, subtotal, receivingQuantity?) with `hasQuantityDifference()`
  - [x] `ProductionBatch` (id, productId, productName, productionDate, locationId, plannedOutput, actualOutput?, status, notes, batchNumber) with `calculateVariance()`, `getFormattedVariance()`, `canStart()`, `canComplete()`, `isInProgress()`, `isCompleted()`
  - [x] `BatchInput` (inputId, inputName, lotNumber?, expiryDate?, requiredQuantity, availableQuantity, unit, status: OK/LOW/SHORT) with `hasShortage()`, `isLow()`, `getLotInfo()`
  - [x] `BatchPackaging` (packagingId, packagingName, sku?, requiredQuantity, availableQuantity, status: OK/LOW/SHORT) with `hasShortage()`, `isLow()`
  - [x] `BatchWastage` (quantity, reasonCode, reasonDescription?) with `getReasonDisplay()`
  - [x] `BatchInputsData` (ingredients, packaging) with `hasShortages()`, `getIngredientsWithShortage()`, `getPackagingWithShortage()`
  - [x] `ActivityItem` (id, type, itemName, activityType, quantityChange, timestamp, reference) with `getFormattedQuantityChange()`
  - [x] `BatchStatus` enum (draft, pending, inProgress, completed, cancelled) with `fromString()`, `fromDTO()`
  - [x] `ReceiptStatus` enum (pending, approved, rejected) with `fromString()`, `fromDTO()`, `getStatusColor()`
  - [x] `StockAdjustmentType` enum (wastage, correction, other) with `fromString()`, `fromDTO()`
  - [x] `BatchInputStatus` enum (ok, low, short) with `fromString()`, `getStatusColor()`
  - [x] `ActivityType` enum (purchase, production, stockAdjustment) with `fromString()`
- [x] Add JSON serialization/deserialization (fromJson/toJson in DTOs)
- [x] Add factory methods for DTO → Model conversion

### 10.2 Production API ✅
- [x] Create `ProductionApi` class with endpoints:
  - [x] `createPurchaseEntry(request)` → POST `/api/production/purchases/`
  - [x] `getPurchaseReceipts(status?, locationId?)` → GET `/api/production/purchases/receipts/`
  - [x] `getPurchaseReceipt(id)` → GET `/api/production/purchases/receipts/{id}/`
  - [x] `reviewReceipt(id, request)` → POST `/api/production/purchases/receipts/{id}/review/` (action: approve/reject)
  - [x] `createBatch(request)` → POST `/api/production/batches/`
  - [x] `getBatch(id)` → GET `/api/production/batches/{id}/`
  - [x] `getBatches(status?, locationId?, dateFrom?, dateTo?)` → GET `/api/production/batches/`
  - [x] `confirmBatchInputs(id, request)` → POST `/api/production/batches/{id}/confirm-inputs/`
  - [x] `getBatchInputs(id)` → GET `/api/production/batches/{id}/inputs/` (check stock availability)
  - [x] `startBatch(id)` → POST `/api/production/batches/{id}/start/`
  - [x] `completeBatch(id, request)` → POST `/api/production/batches/{id}/complete/`
  - [x] `getRecentActivity(limit?)` → GET `/api/production/activity/`
- [x] Add error handling for each endpoint (via ApiResult pattern)
- [x] All endpoints return ApiResult<T> with proper DTO parsing
- [x] Query parameters properly formatted and optional
- [ ] **Future Enhancements (if backend supports):**
  - [ ] Add pagination support (page/limit) to `getPurchaseReceipts()`, `getBatches()`, and `getRecentActivity()` if backend exposes pagination
  - [ ] Add filtering support to `getRecentActivity()` (type, date range, location) if backend provides these filters
  - [ ] Verify endpoint naming alignment: confirm if backend has separate "check" vs "confirm" endpoints for batch inputs and align naming accordingly

### 10.3 Production Repository ✅
- [x] Create `ProductionRepository` class
- [x] Wrap all API calls with repository methods:
  - [x] `createPurchaseEntry(entry)` → returns `ApiResult<PurchaseReceipt>`
  - [x] `getPurchaseReceipts(status?, locationId?)` → returns `ApiResult<List<PurchaseReceipt>>`
  - [x] `getPurchaseReceipt(id)` → returns `ApiResult<PurchaseReceipt>`
  - [x] `reviewReceipt(id, action, receivingQuantities?)` → returns `ApiResult<PurchaseReceipt>`
  - [x] `createBatch(productId, productionDate, locationId, plannedOutput, notes?)` → returns `ApiResult<ProductionBatch>`
  - [x] `getBatch(id)` → returns `ApiResult<ProductionBatch>`
  - [x] `getBatches(status?, locationId?, dateFrom?, dateTo?)` → returns `ApiResult<List<ProductionBatch>>`
  - [x] `confirmBatchInputs(batchId, adjustedInputs?)` → returns `ApiResult<BatchInputsData>` (returns inputs data with availability, not batch)
  - [x] `getBatchInputs(batchId)` → returns `ApiResult<BatchInputsData>` (includes ingredients and packaging with availability)
  - [x] `startBatch(batchId)` → returns `ApiResult<ProductionBatch>`
  - [x] `completeBatch(batchId, actualOutput, wastage?)` → returns `ApiResult<ProductionBatch>`
  - [x] `getRecentActivity(limit?)` → returns `ApiResult<List<ActivityItem>>`
- [x] Add data transformation (DTO → Model) using factory methods
- [x] All methods return ApiResult<T> with domain models
- [x] Proper date formatting (YYYY-MM-DD) for API requests
- [x] Enum value conversion (domain enums → API string values)

---

## Phase 11: Production Module - State Management 🧠

### 11.1 Production State Classes ✅
- [x] Create `StockingHubState` class:
  - [x] `recentActivity: List<ActivityItem>`
  - [x] `isLoading: bool`
  - [x] `error: String?`
  - [x] Helper methods: `copyWith()`, `hasData`, `hasError`, `initial()`
- [x] Create `PurchaseEntryState` class:
  - [x] `supplierId: int?`
  - [x] `date: DateTime`
  - [x] `refInvoice: String?`
  - [x] `items: List<PurchaseItem>`
  - [x] `markAsReceived: bool`
  - [x] `isLoading: bool`
  - [x] `error: String?`
  - [x] Helper methods: `calculateTotal()`, `calculateTotalQuantity()`, `getTotalItemsCount()`, `addItem()`, `removeItem()`, `updateItem()`, `isValid()`, `toPurchaseEntry()`, `copyWith()`, `reset()`
- [x] Create `PurchaseReceiptsState` class:
  - [x] `receipts: List<PurchaseReceipt>`
  - [x] `selectedStatus: ReceiptStatus?` (filter)
  - [x] `isLoading: bool`
  - [x] `error: String?`
  - [x] Helper methods: `filteredReceipts`, `hasData`, `hasError`, `copyWith()`, `initial()`
- [x] Create `ReceiptReviewState` class:
  - [x] `receipt: PurchaseReceipt?`
  - [x] `receivingQuantities: Map<int, double>` (itemId → receiving quantity)
  - [x] `isLoading: bool`
  - [x] `isSubmitting: bool`
  - [x] `error: String?`
  - [x] Helper methods: `canApprove()`, `updateReceivingQuantity()`, `initializeReceivingQuantities()`, `hasData`, `hasError`, `copyWith()`, `initial()`
- [x] Create `BatchCreationState` class:
  - [x] `productId: int?`
  - [x] `productionDate: DateTime`
  - [x] `locationId: int?`
  - [x] `plannedOutput: double`
  - [x] `notes: String?`
  - [x] `isLoading: bool`
  - [x] `error: String?`
  - [x] Helper methods: `isValid()`, `hasError`, `copyWith()`, `reset()`, `initial()`
- [x] Create `BatchConfirmationState` class:
  - [x] `batch: ProductionBatch?`
  - [x] `ingredients: List<BatchInput>`
  - [x] `packaging: List<BatchPackaging>`
  - [x] `adjustedInputs: Map<int, double>?` (if user adjusts quantities)
  - [x] `isLoading: bool`
  - [x] `error: String?`
  - [x] Helper methods: `hasShortages()`, `canStartProduction()`, `updateAdjustedInput()`, `toggleAdjustInputs()`, `hasData`, `hasError`, `copyWith()`, `initial()`
- [x] Create `BatchCompletionState` class:
  - [x] `batch: ProductionBatch?`
  - [x] `actualOutput: double?`
  - [x] `wastage: BatchWastage?`
  - [x] `isLoading: bool`
  - [x] `isSubmitting: bool`
  - [x] `error: String?`
  - [x] Helper methods: `calculateVariance()`, `getFormattedVariance()`, `isValid()`, `hasData`, `hasError`, `copyWith()`, `initial()`

### 11.2 Production ViewModels ✅
- [x] Create `StockingHubViewModel` using Riverpod `AsyncNotifier`
  - [x] `loadRecentActivity()` - loads recent production/inventory activity
  - [x] `refreshActivity()` - refreshes activity feed
  - [x] `clearError()` - clears error state
- [x] Create `PurchaseEntryViewModel` using Riverpod `Notifier`
  - [x] `setSupplier(int?)` - sets selected supplier
  - [x] `setDate(DateTime)` - sets purchase date
  - [x] `setRefInvoice(String?)` - sets reference/invoice
  - [x] `addItem(PurchaseItem)` - adds item to purchase
  - [x] `removeItem(int)` - removes item by index
  - [x] `updateItem(int, PurchaseItem)` - updates item at index
  - [x] `toggleMarkAsReceived()` - toggles mark as received
  - [x] `savePurchase()` - creates purchase entry
  - [x] `reset()` - resets form to initial state
  - [x] `validate()` - validates form data
  - [x] `clearError()` - clears error state
- [x] Create `PurchaseReceiptsViewModel` using Riverpod `AsyncNotifier`
  - [x] `loadReceipts(status?, locationId?)` - loads purchase receipts
  - [x] `setStatusFilter(ReceiptStatus?)` - sets status filter
  - [x] `refreshReceipts()` - refreshes receipts list
  - [x] `clearError()` - clears error state
- [x] Create `ReceiptReviewViewModel` using Riverpod `AsyncNotifier`
  - [x] `loadReceipt(id)` - loads receipt details
  - [x] `setReceivingQuantity(int itemId, double quantity)` - sets receiving quantity for item
  - [x] `approveReceipt()` - approves and receives receipt
  - [x] `rejectReceipt()` - rejects receipt
  - [x] `clearError()` - clears error state
- [x] Create `BatchCreationViewModel` using Riverpod `Notifier`
  - [x] `setProduct(int?)` - sets selected product
  - [x] `setProductionDate(DateTime)` - sets production date
  - [x] `setLocation(int?)` - sets location
  - [x] `setPlannedOutput(double)` - sets planned output
  - [x] `setNotes(String?)` - sets batch notes
  - [x] `saveDraft()` - saves batch as draft
  - [x] `continueToConfirmation()` - validates and creates batch, returns batch ID
  - [x] `reset()` - resets form
  - [x] `validate()` - validates form data
  - [x] `clearError()` - clears error state
- [x] Create `BatchConfirmationViewModel` using Riverpod `AsyncNotifier`
  - [x] `loadBatchInputs(batchId)` - loads batch inputs and checks stock availability
  - [x] `toggleAdjustInputs()` - toggles adjust inputs mode
  - [x] `setAdjustedInput(int inputId, double quantity)` - sets adjusted input quantity
  - [x] `startProduction()` - starts production batch
  - [x] `saveDraft()` - saves batch as draft (with adjusted inputs if any)
  - [x] `clearError()` - clears error state
- [x] Create `BatchCompletionViewModel` using Riverpod `AsyncNotifier`
  - [x] `loadBatch(id)` - loads batch details
  - [x] `setActualOutput(double)` - sets actual output quantity
  - [x] `setWastage(BatchWastage)` - sets wastage details
  - [x] `removeWastage()` - removes wastage
  - [x] `calculateVariance()` - calculates variance percentage (delegates to state)
  - [x] `completeBatch()` - completes batch and updates inventory
  - [x] `saveProgress()` - saves batch progress (placeholder - validates form)
  - [x] `clearError()` - clears error state
- [x] Add error handling (via ApiResult pattern and AuthErrorHandler)
- [x] Create providers for all ViewModels (in production_providers.dart and individual ViewModel files)
- [x] All ViewModels follow existing patterns (AsyncNotifier/Notifier, repository injection, state preservation on errors)

---

## Phase 12: Production Module - UI Integration 🎨

### 12.1 Stocking Hub Screen
- [ ] Create `StockingHubScreen` (ConsumerStatefulWidget)
- [ ] Connect to `stockingHubProvider`
- [ ] Implement Header:
  - [ ] Back button
  - [ ] Title "Stocking Hub"
  - [ ] Help/question mark icon
- [ ] Implement Main Section:
  - [ ] "Stocking" title and description
  - [ ] Instructional text with icon
  - [ ] "Buy / Receive Supplies" card:
    - [ ] Orange left border
    - [ ] Truck icon
    - [ ] Title and description
    - [ ] "Start Receiving" button (orange gradient) → navigates to Purchase Entry
  - [ ] "Produce Drinks" card:
    - [ ] Green left border
    - [ ] Blender icon
    - [ ] Title and description
    - [ ] "Start Production" button (green) → navigates to New Batch
  - [ ] "Quick Stock Adjustment" card:
    - [ ] Gray icon
    - [ ] Title and description
    - [ ] Navigate to stock adjustment (reuse from Inventory module)
- [ ] Implement Recent Activity Section:
  - [ ] Section header "Recent Activity" with "View All" link
  - [ ] Activity items list:
    - [ ] Item image/icon
    - [ ] Item name
    - [ ] Activity type/status
    - [ ] Quantity change (+/- with color coding)
    - [ ] Timestamp
  - [ ] Empty state when no activity
- [ ] Implement Loading State (CircularProgressIndicator)
- [ ] Implement Error State (error message with retry)
- [ ] Implement pull-to-refresh

### 12.2 Purchase Entry Screen
- [ ] Create `PurchaseEntryScreen` (ConsumerStatefulWidget)
- [ ] Connect to `purchaseEntryProvider`
- [ ] Implement Header:
  - [ ] Back button
  - [ ] Title "Purchase Entry"
  - [ ] Subtitle "Record bought supplies"
  - [ ] Help icon
- [ ] Implement Purchase Details Section:
  - [ ] Section title
  - [ ] Supplier dropdown:
    - [ ] "Select supplier" placeholder
    - [ ] "+ Add new" button (orange)
    - [ ] Supplier selection from list
  - [ ] Date picker:
    - [ ] Calendar icon
    - [ ] Date display and selection
  - [ ] Ref/Invoice input:
    - [ ] Optional text field
- [ ] Implement Items Purchased Section:
  - [ ] Section title
  - [ ] Dynamic items list:
    - [ ] Item card with:
      - [ ] Item name (with icon)
      - [ ] Remove item button (red X)
      - [ ] Quantity input (with unit)
      - [ ] Unit cost input
      - [ ] Subtotal display (calculated)
  - [ ] "Add another item" button (orange with plus icon)
  - [ ] Item search/selection modal (reuse inventory items)
- [ ] Implement Mark as Received Toggle:
  - [ ] Toggle switch
  - [ ] Description text
- [ ] Implement Summary Section:
  - [ ] Total items count
  - [ ] Total quantity
  - [ ] Total cost (bold, large)
- [ ] Implement Action Buttons:
  - [ ] "Save Purchase" button (orange gradient)
  - [ ] "Cancel" link
- [ ] Implement form validation
- [ ] Implement loading state (during save)
- [ ] Implement error handling
- [ ] Navigate to Pending Receipts on successful save

### 12.3 Pending Receipts Screen
- [ ] Create `PendingReceiptsScreen` (ConsumerStatefulWidget)
- [ ] Connect to `purchaseReceiptsProvider`
- [ ] Implement Header:
  - [ ] Back button
  - [ ] Title "Pending Receipts"
  - [ ] Subtitle "Purchases awaiting inventory receipt"
  - [ ] Filter icon
- [ ] Implement Filter Tabs:
  - [ ] "All" tab
  - [ ] "Pending" tab (highlighted when active)
  - [ ] "Approved" tab
  - [ ] "Rejected" tab
- [ ] Implement Receipts List:
  - [ ] Receipt cards:
    - [ ] Supplier avatar/initial
    - [ ] Supplier name
    - [ ] Reference number
    - [ ] Status badge (color-coded: orange/pending, green/approved, gray/rejected)
    - [ ] Date
    - [ ] Summary (items count, units)
    - [ ] Total cost (bold, large)
    - [ ] Timestamp ("Created X ago")
    - [ ] Action button:
      - [ ] "Review" for pending (orange)
      - [ ] "View" for approved (gray)
      - [ ] "Details" for rejected (gray)
  - [ ] Empty state ("That's all for now" with icon)
  - [ ] End of list indicator
- [ ] Implement Loading State
- [ ] Implement Error State
- [ ] Implement pull-to-refresh
- [ ] Navigate to Receipt Review on receipt tap

### 12.4 Receipt Review Screen
- [ ] Create `ReceiptReviewScreen` (ConsumerStatefulWidget)
- [ ] Connect to `receiptReviewProvider`
- [ ] Implement Header:
  - [ ] Back button
  - [ ] Title "Receipt Review"
  - [ ] Subtitle "Review purchase before receiving stock"
  - [ ] Status badge (Pending/Approved/Rejected)
- [ ] Implement Supplier Details Card:
  - [ ] Supplier name with icon
  - [ ] Reference number
  - [ ] Date
  - [ ] Created by
  - [ ] Total cost
- [ ] Implement Items to Receive Section:
  - [ ] Section title "Items to Receive"
  - [ ] Items count badge
  - [ ] Description text
  - [ ] Items list:
    - [ ] Item card:
      - [ ] Item icon/image
      - [ ] Item name
      - [ ] Unit cost
      - [ ] Subtotal
      - [ ] Receiving quantity input (can differ from purchased quantity)
- [ ] Implement Action Buttons:
  - [ ] "Mark as Received" button (orange gradient with checkmark)
  - [ ] "Cancel" link (with disclaimer)
  - [ ] "Reject Receipt" link (red)
- [ ] Implement Loading State
- [ ] Implement Error State
- [ ] Handle approval action (navigate back to list)
- [ ] Handle rejection action (navigate back to list)

### 12.5 New Batch Screen
- [ ] Create `NewBatchScreen` (ConsumerStatefulWidget)
- [ ] Connect to `batchCreationProvider`
- [ ] Implement Header:
  - [ ] Back button
  - [ ] Title "New Batch"
  - [ ] Subtitle "Record drink production"
  - [ ] Help icon
- [ ] Implement Batch Details Section:
  - [ ] Section title with icon
  - [ ] Product dropdown:
    - [ ] "Select drink" placeholder
    - [ ] Product selection (from inventory finished goods)
  - [ ] Production Date picker:
    - [ ] Calendar icon
    - [ ] Date display and selection
  - [ ] Location dropdown:
    - [ ] Location selection (reuse location selector from Inventory)
  - [ ] Planned Output input:
    - [ ] Number input
    - [ ] Unit display (from product definition)
    - [ ] Helper text about output unit
  - [ ] Batch Notes input:
    - [ ] Multi-line text field
    - [ ] Optional placeholder text
- [ ] Implement Action Buttons:
  - [ ] "Save Draft" button (gray)
  - [ ] "Continue →" button (orange gradient)
  - [ ] Helper text "Next: confirm inputs & start production"
- [ ] Implement form validation
- [ ] Implement loading state
- [ ] Implement error handling
- [ ] Navigate to Confirm Inputs on continue

### 12.6 Confirm Inputs Screen
- [ ] Create `ConfirmInputsScreen` (ConsumerStatefulWidget)
- [ ] Connect to `batchConfirmationProvider`
- [ ] Implement Header:
  - [ ] Back button
  - [ ] Title "Confirm Inputs"
  - [ ] Subtitle "Review before starting production"
  - [ ] Help icon
- [ ] Implement Batch Summary Card:
  - [ ] Batch number
  - [ ] Planned output (large, bold)
  - [ ] Product name
  - [ ] Location
  - [ ] Date & time
  - [ ] Product image/illustration (background)
- [ ] Implement Insufficient Stock Alert:
  - [ ] Warning icon (orange triangle)
  - [ ] "Insufficient Stock" title
  - [ ] Description text
  - [ ] "Go to Inventory" button (orange)
  - [ ] "Receive Supplies" button (orange)
- [ ] Implement Adjust Input Quantities Toggle:
  - [ ] Toggle switch
  - [ ] Description text
- [ ] Implement Ingredients Section:
  - [ ] Section title "INGREDIENTS (count)"
  - [ ] Ingredients list:
    - [ ] Ingredient card:
      - [ ] Ingredient name
      - [ ] Lot number and expiry (if applicable)
      - [ ] Required quantity (dark green)
      - [ ] Available quantity (color-coded: green/OK, orange/LOW, red/SHORT)
      - [ ] Status badge (OK/LOW/SHORT)
      - [ ] Adjustable quantity input (if toggle enabled)
- [ ] Implement Packaging Section:
  - [ ] Section title "PACKAGING (count)"
  - [ ] Packaging list:
    - [ ] Packaging card:
      - [ ] Packaging name
      - [ ] SKU (if applicable)
      - [ ] Required quantity
      - [ ] Available quantity
      - [ ] Status badge
      - [ ] Adjustable quantity input (if toggle enabled)
- [ ] Implement Action Buttons:
  - [ ] "Save Draft" button (gray)
  - [ ] "Start Production" button (disabled if shortages, green when enabled)
  - [ ] Error message if cannot start
  - [ ] "Cancel" link
- [ ] Implement Loading State
- [ ] Implement Error State
- [ ] Navigate to Complete Batch on start production

### 12.7 Complete Batch Screen
- [ ] Create `CompleteBatchScreen` (ConsumerStatefulWidget)
- [ ] Connect to `batchCompletionProvider`
- [ ] Implement Header:
  - [ ] Back button
  - [ ] Title "Complete Batch"
  - [ ] Subtitle "Record final output and wastage"
  - [ ] Status badge ("IN PROGRESS" - green/orange)
- [ ] Implement Batch Summary Card:
  - [ ] Product name
  - [ ] Batch ID
  - [ ] Location
  - [ ] Date & time
  - [ ] Planned output
  - [ ] Delete/cancel icon (if allowed)
- [ ] Implement Actual Output Section:
  - [ ] Section title
  - [ ] Output input field (large number input)
  - [ ] Unit display
  - [ ] Helper text
  - [ ] Variance indicator:
    - [ ] Calculate variance percentage
    - [ ] Display with icon (▲/▼) and color (green/within range, orange/variance)
- [ ] Implement Wastage Section (Optional):
  - [ ] Section title with "Optional" label
  - [ ] Quantity input
  - [ ] Reason code dropdown:
    - [ ] Spillage
    - [ ] Expired
    - [ ] Quality issue
    - [ ] Other
  - [ ] Reason description input (if Other)
  - [ ] Helper text
- [ ] Implement Inventory Update Preview:
  - [ ] Section title
  - [ ] Addition preview:
    - [ ] Green plus icon
    - [ ] "+ X L Product Name"
    - [ ] "Added to Finished Goods"
  - [ ] Loss preview (if wastage):
    - [ ] Red minus icon
    - [ ] "- X L lost (Reason)"
    - [ ] "Recorded as production loss"
- [ ] Implement Action Buttons:
  - [ ] "Complete Batch" button (orange gradient)
  - [ ] "Save Progress" button (gray)
  - [ ] "Cancel" link
  - [ ] Disclaimer text "This action cannot be undone. Inventory will update immediately."
- [ ] Implement Loading State
- [ ] Implement Error State
- [ ] Handle batch completion (update inventory, navigate to batch list or hub)

### 12.8 Production Widgets
- [ ] Create `ActivityItemCard` widget (for recent activity)
- [ ] Create `PurchaseItemCard` widget (for purchase entry items)
- [ ] Create `ReceiptCard` widget (for receipts list)
- [ ] Create `ReceiptItemCard` widget (for receipt review items)
- [ ] Create `BatchInputCard` widget (for ingredients/packaging with status badges)
- [ ] Create `BatchSummaryCard` widget (reusable batch summary display)
- [ ] Create `StatusBadge` widget (pending/approved/rejected/OK/LOW/SHORT)
- [ ] Create `VarianceIndicator` widget (for actual vs planned output)
- [ ] Create `InventoryUpdatePreview` widget (for batch completion preview)

### 12.9 Navigation & Integration
- [ ] Add routes to router:
  - [ ] `/production` or `/stocking-hub` → StockingHubScreen
  - [ ] `/production/purchase-entry` → PurchaseEntryScreen
  - [ ] `/production/receipts` → PendingReceiptsScreen
  - [ ] `/production/receipts/{id}/review` → ReceiptReviewScreen
  - [ ] `/production/batches/new` → NewBatchScreen
  - [ ] `/production/batches/{id}/confirm` → ConfirmInputsScreen
  - [ ] `/production/batches/{id}/complete` → CompleteBatchScreen
- [ ] Update Quick Actions in Dashboard to navigate to Stocking Hub
- [ ] Integrate with Inventory module (reuse location selector, item selector)
- [ ] Update Inventory Overview to show recent production activity (optional)
- [ ] Add navigation from Dashboard Production quick action

### 12.10 Loading & Error States
- [ ] Implement loading indicators for all screens
- [ ] Implement error states with retry functionality
- [ ] Implement empty states (no receipts, no batches, no activity)
- [ ] Add pull-to-refresh where appropriate
- [ ] Add form validation error messages

### 12.11 Role-Based Access
- [ ] Production role: Full access to all screens
- [ ] Manager/Admin: Full access to all screens
- [ ] Inventory Clerk: Limited access (view only, or no access)
- [ ] Show appropriate access restrictions
- [ ] Handle unauthorized actions gracefully

---

### Expenses/Financial Module (Suggested Next)
**Priority:** Medium
**Dependencies:** Dashboard (completed), Authentication (completed)

**Potential Screens:**
- [ ] Expenses Overview/Dashboard screen
- [ ] Expense List screen
- [ ] Expense Detail screen
- [ ] Create/Edit Expense screen
- [ ] Expense Report screen
- [ ] Payment Due alerts screen (from dashboard)

**Data Layer:**
- [ ] Expense DTOs (Expense, ExpenseCategory, Payment)
- [ ] Expense API class
- [ ] Expense Repository
- [ ] Expense Models

**State Management:**
- [ ] Expense State
- [ ] Expense ViewModel
- [ ] Expense Providers

**Features:**
- [ ] Expense list with filters (category, date, location)
- [ ] Create/edit expenses
- [ ] Expense categorization
- [ ] Payment due tracking and alerts
- [ ] Expense reports and analytics
- [ ] Integration with dashboard (expense KPIs, expense chart)
- [ ] Role-based access (Accountant role, Manager, Admin)

---

### Reports Module (Suggested Next)
**Priority:** Low
**Dependencies:** Sales, Expenses, Production modules

**Potential Screens:**
- [ ] Reports Dashboard screen
- [ ] Sales Reports screen
- [ ] Expense Reports screen
- [ ] Inventory Reports screen
- [ ] Profit & Loss Report screen
- [ ] Custom Report Builder screen

**Data Layer:**
- [ ] Report DTOs (Report, ReportData, ReportFilter)
- [ ] Report API class
- [ ] Report Repository
- [ ] Report Models

**State Management:**
- [ ] Report State
- [ ] Report ViewModel
- [ ] Report Providers

**Features:**
- [ ] Pre-built report templates
- [ ] Custom report generation
- [ ] Export reports (PDF, CSV, Excel)
- [ ] Scheduled reports
- [ ] Report sharing
- [ ] Role-based access (Manager, Admin, Accountant)

---

### Other Potential Modules

**Notifications/Alerts Module:**
- [ ] Notification center screen
- [ ] Alert management
- [ ] Push notifications setup

**Settings/Profile Module:**
- [ ] User profile screen
- [ ] Settings screen
- [ ] Account management
- [ ] Preferences

**Transfers Module (Enhanced):**
- [ ] Enhanced transfer management (if not fully covered in Inventory)
- [ ] Transfer history
- [ ] Transfer approvals

**Cycle Counts Module:**
- [ ] Cycle count management (if not fully covered in Inventory)
- [ ] Count scheduling
- [ ] Count history

---

## Backend Endpoints Reference

**Completed Modules:**
- `POST /api/auth/login` ✅
- `GET /api/inventory/locations/` ✅
- `GET /api/inventory/items/` ✅
- `GET /api/inventory/overview/` ✅
- `POST /api/inventory/stock/adjust/` ✅
- `POST /api/inventory/stock/transfer/` ✅
- `GET /api/inventory/stock/movements/` ✅
- `GET /api/dashboard/` ✅
- `GET /api/dashboard/kpis/` ✅
- `GET /api/dashboard/charts/*` ✅
- `GET /api/dashboard/alerts/` ✅

**Next Modules (To be implemented):**
- Sales endpoints (to be documented)
- Production endpoints (to be documented)
- Expense endpoints (to be documented)
- Report endpoints (to be documented)

*Verify actual endpoints with backend team/API docs*

---

## Progress Summary

**Completed Modules:**
- ✅ Foundation & Core Infrastructure (100%)
- ✅ Authentication Module (100%)
- ✅ Inventory Module (100%)
- ✅ Dashboard Module (100%)

**Next Priority:** Choose and implement Sales, Production, or Expenses module

**Overall Progress:** ~40-50% of planned features complete

---

## Notes

### Implementation Strategy
- Build one module at a time
- Follow MVVM + Riverpod pattern established in Inventory/Dashboard modules
- Reuse UI patterns and components from completed modules
- Implement role-based access control from the start
- Add loading/error/empty states consistently
- Write tests alongside implementation (if time permits)
- Document API endpoints as they're implemented
- Keep code style consistent with existing modules

### Code Quality Standards
- Use `dart format` on all files
- Fix all linter warnings
- Add doc comments to public APIs
- Follow existing architectural patterns
- Implement proper error handling
- Add loading and empty states
- Ensure responsive design

---

## Recent Updates

### 2024 - Dashboard Module Complete ✅
- ✅ All dashboard features implemented
- ✅ Role-based visibility complete
- ✅ All charts implemented (including Expense, Channel, Inventory Value)
- ✅ Loading/error/empty states complete
- ✅ Inventory Clerk dashboard complete
- ✅ Navigation and filters working
- Ready to move on to next module

### 2024 - Inventory Module Complete ✅
- ✅ All 6 inventory screens implemented and tested
- ✅ Complete data layer with API integration
- ✅ Full state management with Riverpod
- ✅ Comprehensive UI with role-based access
- ✅ 99 automated tests (all passing)
- ✅ Complete documentation and code cleanup
- ✅ Navigation integrated with go_router

### 2024 - Authentication Module Complete ✅
- ✅ Login with email/password
- ✅ Token-based authentication
- ✅ Auth guards and route protection
- ✅ Auto-logout on 401 errors

### 2024 - Foundation Complete ✅
- ✅ MVVM + Riverpod architecture established
- ✅ API client with error handling
- ✅ Theme system with dark mode
- ✅ Navigation with go_router
