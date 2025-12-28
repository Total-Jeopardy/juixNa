# JuixNa Mobile App - Implementation Plan

## Overview
This plan outlines the implementation of all missing pieces to align the Flutter mobile app with the MVVM + Riverpod architecture and connect it to the backend API.

**Backend API Base URL:** `https://juixna-api.onrender.com`

---

## Phase 1: Foundation & Core Infrastructure ✅

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

## Phase 2: Authentication Module 🔐 ✅

### 2.1 Auth Data Layer
- [x] Create `AuthApi` class with login endpoint
- [x] Create `AuthRepository` to wrap API calls
- [x] Create `AuthDTOs` (request/response models)
- [x] Create `UserModel` (domain model)
- [x] Add test accounts to config
- [x] Test login API integration ✅

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
- [x] Test full login flow ✅

### 2.4 Auth Guards & Navigation
- [x] Create auth guard middleware (`AuthGuard` widget)
- [x] Set up initial route based on auth status (in `MainApp`)
- [x] Add logout functionality (logout button in InventoryOverviewScreen)
- [x] Create `AuthErrorHandler` for 401 error handling (auto-logout)
- [x] Add helper functions (`isUserAuthenticated`, `requireAuthentication`)
- [x] Handle token refresh (deferred for v1 - requires re-login on 401)

---

## ✅ Completed Modules Summary

### Inventory Module ✅
**Status:** Complete - All phases finished, tested, and documented

**Screens Implemented:**
- ✅ Inventory Overview Screen (KPIs, filters, search, location selector)
- ✅ Stock Movement Screen (Stock-In/Out with validation)
- ✅ Stock Transfer Screen (Location-to-location transfers)
- ✅ Cycle Count Screen (Inventory counting with variance calculation)
- ✅ Reorder Alerts Screen (Low stock monitoring with alerts)
- ✅ Transfer History Screen (Complete transfer history with filtering)

**Key Achievements:**
- ✅ Complete data layer (API, Repository, DTOs, Models)
- ✅ Full state management (6 ViewModels with Riverpod)
- ✅ Comprehensive UI with role-based access
- ✅ 99 automated tests (all passing)
- ✅ Complete documentation and code cleanup
- ✅ Navigation integrated with go_router

**Reference:** See Inventory implementation in `lib/features/inventory/` directory

---

## Phase 3: Dashboard Module - Data Layer 📊 ✅
### 3.1 Dashboard Models & DTOs ✅
- [x] Create `DashboardDTOs`:
  - [x] `KPIDTO` (Total Sales, Total Expenses, Total Profit, trends)
  - [x] `InventoryClerkKPIDTO` (low_stock_count, out_of_stock_count) - for Inventory Clerk view
  - [x] `ProductSalesDTO` (product_id, product_name, total_sales, quantity_sold, percentage) - for Top Products chart
  - [x] `SalesTrendPointDTO` (date, sales_amount, quantity, day_label) - for 7-day trend chart
  - [x] `ExpenseCategoryDTO` (category, amount, percentage) - **GAP: Add later for Expense Pie Chart**
  - [x] `ChannelSalesDTO` (channel_name, revenue, percentage) - **GAP: Add later**
  - [x] `InventoryValuePointDTO` (date, total_value) - **GAP: Add later (currently placeholder)**
  - [x] `DashboardAlertDTO` (type, title, message, item_id, severity, action_url, timestamp)
  - [x] `DashboardResponseDTO` (kpis, charts_data, alerts, period)
  - [x] `PeriodFilterDTO` enum (TODAY, WEEK, MONTH, CUSTOM)
  - [x] `AlertTypeDTO` and `AlertSeverityDTO` enums
- [x] Create `DashboardModels` (domain models):
  - [x] `DashboardKPIs` (totalSales, totalExpenses, totalProfit, trends with formatted helpers)
  - [x] `InventoryClerkKPIs` (lowStockCount, outOfStockCount) - for role-specific view
  - [x] `ProductSales` (productId, productName, totalSales, quantitySold, percentage) - for Top Products donut chart
  - [x] `SalesTrendPoint` (date, salesAmount, quantity, dayLabel) - for 7-day bar chart (Mon-Sun)
  - [x] `ExpenseCategory` (category, amount, percentage) - **GAP: Add later, reuse for Expense Pie Chart**
  - [x] `ChannelSales` (channelName, revenue, percentage) - **GAP: Add later**
  - [x] `InventoryValuePoint` (date, totalValue) - **GAP: Add later**
  - [x] `DashboardAlert` (type: LOW_STOCK, PAYMENT_DUE, UPCOMING_BATCH, PROMOTION_EXPIRY, title, message, itemId, severity, actionUrl, timestamp)
  - [x] `DashboardData` (kpis, salesTrendChart, topProductsChart, expenseChart?, channelChart?, inventoryValueChart?, alerts)
  - [x] `PeriodFilter` enum (TODAY, WEEK, MONTH, CUSTOM) - default WEEK per design
  - [x] `AlertType` and `AlertSeverity` enums with safe fallbacks
- [x] Add JSON serialization/deserialization (fromJson/toJson in DTOs)
- [x] **Note:** Models marked as "GAP: Add later" can be implemented when those features are added
- [x] **Fixed:** Trend parsing preserves negative signs
- [x] **Fixed:** Safe fallback for unknown alert types/severities

### 3.2 Dashboard API ✅
- [x] Create `DashboardApi` class with endpoints:
  - [x] `getDashboardData(period?, startDate?, endDate?, locationId?)` → GET `/api/dashboard/`
  - [x] `getKPIs(period?, startDate?, endDate?, locationId?)` → GET `/api/dashboard/kpis/`
  - [x] `getProductSalesChart(period?, startDate?, endDate?, locationId?, limit?)` → GET `/api/dashboard/charts/top-products/`
  - [x] `getSalesTrendChart(period?, startDate?, endDate?, locationId?, groupBy?)` → GET `/api/dashboard/charts/sales-trend/`
  - [x] `getExpenseChart(period?, startDate?, endDate?, locationId?)` → GET `/api/dashboard/charts/expenses/`
  - [x] `getChannelSalesChart(period?, startDate?, endDate?)` → GET `/api/dashboard/charts/channels/`
  - [x] `getInventoryValueChart(period?, startDate?, endDate?, locationId?)` → GET `/api/dashboard/charts/inventory-value/`
  - [x] `getAlerts(locationId?)` → GET `/api/dashboard/alerts/`
- [x] Add error handling for each endpoint (via ApiResult pattern)
- [x] All endpoints return ApiResult<T> with proper DTO parsing
- [x] Query parameters properly formatted and optional

### 3.3 Dashboard Repository ✅
- [x] Create `DashboardRepository` class
- [x] Wrap all API calls with repository methods:
  - [x] `getDashboardData(period, startDate?, endDate?, locationId?)` → returns `ApiResult<DashboardData>`
  - [x] `getKPIs(period, startDate?, endDate?, locationId?)` → returns `ApiResult<DashboardKPIs>`
  - [x] `getProductSalesChart(...)` → returns `ApiResult<List<ProductSales>>`
  - [x] `getSalesTrendChart(...)` → returns `ApiResult<List<SalesTrendPoint>>`
  - [x] `getExpenseChart(...)` → returns `ApiResult<List<ExpenseCategory>>`
  - [x] `getChannelSalesChart(...)` → returns `ApiResult<List<ChannelSales>>`
  - [x] `getInventoryValueChart(...)` → returns `ApiResult<List<InventoryValuePoint>>`
  - [x] `getAlerts(locationId?)` → returns `ApiResult<List<DashboardAlert>>`
- [x] Add data transformation (DTO → Model) using factory methods
- [x] All methods return ApiResult<T> with domain models

---

## Phase 4: Dashboard Module - State Management 🧠 ✅

### 4.1 Dashboard State ✅
- [x] Create `DashboardState` class:
  - [x] `kpis: DashboardKPIs?`
  - [x] `productSalesChart: List<ProductSales>`
  - [x] `salesTrendChart: List<SalesTrendPoint>`
  - [x] `expenseChart: List<ExpenseCategory>?`
  - [x] `channelChart: List<ChannelSales>?`
  - [x] `inventoryValueChart: List<InventoryValuePoint>?`
  - [x] `alerts: List<DashboardAlert>`
  - [x] `selectedPeriod: PeriodFilter` (default: WEEK)
  - [x] `startDate: DateTime?` (for CUSTOM period)
  - [x] `endDate: DateTime?` (for CUSTOM period)
  - [x] `selectedLocationId: int?`
  - [x] `isLoading: bool`, `isLoadingKPIs: bool`, `isLoadingCharts: bool`, `isLoadingAlerts: bool`
  - [x] `error: String?`
  - [x] `lastSyncTime: DateTime?`
  - [x] `inventoryClerkKpis: InventoryClerkKPIs?` (for role-specific view)
  - [x] Helper methods: `copyWith()`, `hasData`, `hasError`, `isCustomPeriod`, `isAnyLoading`
  - [x] Factory methods: `loading()`, `error()`, `initial()`

### 4.2 Dashboard ViewModel ✅
- [x] Create `DashboardViewModel` using Riverpod `AsyncNotifier`
- [x] Implement `loadDashboardData()` - loads all dashboard data (KPIs + charts + alerts)
- [x] Implement `loadKPIs()` - loads only KPI cards
- [x] Implement `loadCharts()` - loads all chart data (product sales + sales trend; expense/channel/inventory value deferred)
- [x] Implement `loadAlerts()` - loads alerts/notifications
- [x] Implement `refreshDashboard()` - reloads all data
- [x] Implement `setPeriod(PeriodFilter)` - changes period and reloads data
- [x] Implement `setCustomDateRange(DateTime start, DateTime end)` - sets custom range with validation and reloads
- [x] Implement `setLocation(int? locationId)` - filters by location and reloads
- [x] Implement `dismissAlert(DashboardAlert)` - dismisses alert locally
- [x] Implement `dismissAllAlerts()` - dismisses all alerts locally
- [x] Implement `clearError()` - clears error state
- [x] Add error handling (via ApiResult pattern)
- [x] Create `dashboardProvider` (AsyncNotifierProvider)
- [x] Create `dashboardApiProvider` and `dashboardRepositoryProvider`
- [x] Create derived providers: `dashboardKPIsProvider`, `dashboardProductSalesChartProvider`, `dashboardSalesTrendChartProvider`, `dashboardAlertsProvider`
- [x] Create derived providers for GAP items: `dashboardExpenseChartProvider`, `dashboardChannelChartProvider`, `dashboardInventoryValueChartProvider`
- [x] **Fixed:** Request token pattern to prevent stale responses from overwriting newer filter selections
- [x] **Fixed:** Custom date range validation (end date cannot be before start date)
- [x] **Fixed:** `lastSyncTime` updated on all successful loads (KPIs, charts, alerts, full load)
- [x] **Fixed:** Charts coverage documented (expense/channel/inventory value deferred with TODO comments)

---

## Phase 5: Dashboard Module - UI Integration 🎨

### 5.1 Dashboard Screen
- [x] Create `DashboardScreen` (ConsumerStatefulWidget)
- [x] Connect to `dashboardProvider`
- [x] Implement Header:
  - [x] App name / logo (JuixNa logo)
  - [x] Refresh/sync icon button
  - [x] Notification bell icon (with badge indicator)
  - [x] User profile icon (tap → User Profile screen - shows "coming soon" info message)
  - [x] Online status indicator (green dot + "Online" text)
  - [x] Last updated timestamp ("Last updated Xm ago")
- [x] Implement Filters/Controls Row:
  - [x] Location filter dropdown ("All Locations", specific locations) - with caching and error handling
  - [x] Period selector buttons (Today, Week, Month, Custom Range)
  - [ ] Role badge/indicator (e.g., "STOCK ACCESS ONLY" for Inventory Clerk) - **DEFERRED**
- [x] Implement KPI Cards Row (Top - based on design):
  - [x] Total Sales card (with trend indicator: +15% vs last week)
  - [x] Total Expenses card (with trend indicator: +2%)
  - [x] Total Profit card (calculated from Sales - Expenses, with trend)
  - [x] Loading state for KPIs (CircularProgressIndicator)
  - [x] Error state for KPIs (handled via error snackbars)
- [x] Implement Quick Actions Section (Design addition - not in blueprint, but good UX):
  - [x] Inventory card (with notification badge, tap → Inventory Overview)
  - [x] Sales card (with "Coming Soon" tag if not available)
  - [x] Production card (with "Soon" tag if not available)
  - [x] Reports card (with "Soon" tag if not available)
  - [ ] Role-based visibility (show "NO ACCESS" for restricted roles) - **DEFERRED**
- [x] Implement Charts Section (Middle, scrollable - based on design):
  - [x] Sales Trend Bar Chart (last 7 days, bars for Mon-Sun)
  - [x] Top Products Donut Chart (with percentages, top 3 products)
  - [x] Loading states for charts (CircularProgressIndicator)
  - [x] Empty states for charts ("No sales trend data available" / dummy data for preview)
  - [ ] **GAP:** Expense Pie Chart (not in design - reuse donut chart component, add for Manager/Admin/Accountant roles) - **DEFERRED**
  - [ ] **GAP:** Top Channels Chart (not in design - can reuse bar chart component, add later) - **DEFERRED**
  - [ ] **GAP:** Inventory Value Line Chart (placeholder in Inventory Clerk view - can reuse line chart component) - **DEFERRED**
- [x] Implement Alerts/Notifications Panel (Bottom):
  - [x] Low Stock alerts (red border, tap → Inventory Item/Reorder Alerts)
  - [x] Payment Due alerts (orange border, tap → Expense Details - shows "coming soon")
  - [x] Upcoming Batch alerts (blue border, tap → Batch Details - shows "coming soon")
  - [x] Promotion Expiry alerts (handled in model, shows with appropriate styling)
  - [x] Swipe to dismiss functionality (with hint text "SWIPE ON ALERT TO MARK READ")
  - [x] "See all" link (top right of alerts section - navigates to reorder alerts)
  - [x] Empty state when no alerts ("You're all caught up" with checkmark icon)
  - [x] Location filter indicator ("Location filtered" when location is selected)
- [x] Implement Loading State:
  - [x] Basic loading screen (CircularProgressIndicator)
  - [ ] Complete loading skeleton screen (with placeholders for all sections) - **BASIC VERSION DONE**
- [x] Implement Error State:
  - [x] Error handling via snackbars (with retry button)
  - [x] AsyncValue error handling (provider-level errors)
  - [x] State-level error handling (ViewModel errors)
  - [x] Error messages surface to user
  - [ ] Error modal overlay (white card with icon) - **USING SNACKBARS INSTEAD**
- [x] Implement pull-to-refresh
- [x] Wire up navigation from KPI cards to detail screens (shows "coming soon" info messages)
- [ ] Wire up navigation from chart elements to filtered detail screens - **DEFERRED**
- [x] Wire up navigation from alerts to relevant screens
- [x] Wire up Quick Actions navigation

### 5.2 Dashboard Widgets
- [x] Create `KPICard` widget (reusable, tappable, supports trend indicator) - **Implemented as `_KPICard` in dashboard_screen.dart**
- [x] Create `SalesTrendBarChart` widget (bar chart for 7 days, reusable for other bar charts) - **Implemented as `_SalesTrendBarChart`**
- [x] Create `TopProductsDonutChart` widget (donut chart, **REUSE for Expense Pie Chart**) - **Implemented as `_TopProductsDonutChart`**
- [x] Create `DashboardAlertCard` widget (swipeable, dismissible, supports border colors by type) - **Implemented as `_AlertCard` with Dismissible**
- [x] Create `QuickActionCard` widget (reusable for Inventory, Sales, Production, Reports) - **Implemented as `_QuickActionCard`**
- [x] Create `PeriodSelector` widget (Today/Week/Month/Custom buttons with active state) - **Implemented as `_PeriodButton`**
- [x] Create `LocationFilterDropdown` widget - **Implemented with bottom sheet in `_FilterChipsRow`**

- [ ] Create `ExpensePieChart` widget (**REUSE donut chart component** - gap item, add later) - **DEFERRED**
- [ ] Create `ChannelSalesChart` widget (**REUSE bar chart component** - gap item, add later) - **DEFERRED**
- [ ] Create `InventoryValueLineChart` widget (**REUSE line chart component** - gap item, add later) - **DEFERRED**
- [ ] Create `LoadingSkeleton` widget (for KPIs and chart sections) - **BASIC VERSION DONE (CircularProgressIndicator)**
- [ ] Create `EmptyStateWidget` widget (reusable with illustration, message, CTA button) - **PARTIAL (empty states implemented inline)**
- [ ] Create `ErrorStateModal` widget (reusable error modal with retry action) - **USING SNACKBARS INSTEAD**

### 5.3 Role-Based Visibility
- [ ] Implement role-based KPI visibility (based on design):
  - [ ] Admin: Total Sales, Total Expenses, Total Profit (all KPIs)
  - [ ] Manager: Total Sales, Total Expenses, Total Profit (all KPIs)
  - [ ] Sales: Total Sales, Best Seller (from chart data)
  - [ ] Inventory Clerk: Low Stock count, Out of Stock count (as shown in design)
  - [ ] Production: Minimal KPIs or none
  - [ ] Accountant: Total Expenses, Total Profit
- [ ] Implement role-based chart visibility:
  - [ ] Admin/Manager: Sales Trend, Top Products, Expense Pie (when added), Channels (when added)
  - [ ] Sales: Sales Trend, Top Products only
  - [ ] Inventory Clerk: Stock Trend placeholder (as shown in design)
  - [ ] Accountant: Expense Pie (when added), Sales Trend
- [ ] Implement role-based alert visibility:
  - [ ] Admin/Manager: All alerts (Low Stock, Payment Due, Upcoming Batch, Promotion Expiry)
  - [ ] Inventory Clerk: Low Stock, Upcoming Batch (location-specific) - "Alerts shown are limited to inventory operations"
  - [ ] Sales: Promotion Expiry alerts
  - [ ] Accountant: Payment Due alerts
- [ ] Implement role-based Quick Actions:
  - [ ] Show "NO ACCESS" for restricted actions (e.g., Sales/Reports for Inventory Clerk)
  - [ ] Show "Coming Soon" / "Soon" tags for unavailable features
- [ ] Show "Access Denied" message for unauthorized taps
- [ ] Display role indicator badge (e.g., "STOCK ACCESS ONLY" button)
- [ ] Show role-specific dashboard title (e.g., "Inventory Clerk Dashboard")

---

## Phase 6: Dashboard Navigation & Integration 🧭

### 6.1 Update Router
- [ ] Add `/dashboard` route → DashboardScreen
- [ ] Update initial route logic (authenticated users → dashboard instead of inventory)
- [ ] Add navigation from Login → Dashboard (on successful login)
- [ ] Update bottom navigation (if exists) to include Dashboard

### 6.2 Navigation Links
- [ ] KPI Cards → Detail screens:
  - [ ] Total Sales → Sales Report screen (future)
  - [ ] Total Expenses → Expense Report screen (future)
  - [ ] Total Profit → Profit Analysis screen (future)
  - [ ] Best Seller → Product Sales Details screen (future)
  - [ ] Top Category → Category Report screen (future)
- [ ] Chart Elements → Filtered detail screens:
  - [ ] Product Sales bar → Product detail / Sales history filtered by product
  - [ ] Sales Trend point → Sales history filtered by date
  - [ ] Expense slice → Expense list filtered by category
  - [ ] Channel → Sales history filtered by channel
  - [ ] Inventory Value point → Inventory report filtered by date
- [ ] Alerts → Relevant screens:
  - [ ] Low Stock → Inventory Item detail / Reorder Alerts screen
  - [ ] Upcoming Batch → Batch Details screen (future)
  - [ ] Payment Due → Expense Details screen (future)
  - [ ] Promotion Expiry → Promotion List screen (future)

---

## Phase 7: Dashboard Additional Features & Polish ✨

### 7.1 Error Handling & User Feedback
- [ ] Use ErrorDisplay utility for error messages
- [ ] Add retry mechanisms for failed requests
- [ ] Show offline indicator when no network
- [ ] Cache dashboard data for offline viewing
- [ ] Show last sync timestamp

### 7.2 Loading States
- [ ] Skeleton loaders for KPI cards
- [ ] Shimmer effect for charts
- [ ] Loading spinners for individual sections
- [ ] Prevent duplicate requests during loading

### 7.3 Data Refresh
- [ ] Pull-to-refresh on dashboard screen
- [ ] Manual refresh button
- [ ] Auto-refresh on screen focus (optional)
- [ ] Background sync indicator

### 7.4 Validations & Edge Cases
- [ ] Handle empty data states (no sales, no expenses, etc.)
- [ ] Handle invalid date ranges (end < start)
- [ ] Handle zero values in charts (prevent division by zero)
- [ ] Handle missing chart data gracefully
- [ ] Validate period filters
- [ ] Show appropriate messages for role restrictions

### 7.5 Performance Optimizations
- [ ] Debounce period/location filter changes
- [ ] Cache chart data to prevent unnecessary re-renders
- [ ] Lazy load charts (load on scroll into view)
- [ ] Optimize chart rendering (limit data points for large ranges)

---

## Phase 8: Dashboard Testing & Quality Assurance 🧪

### 8.1 Unit Tests
- [ ] Test DashboardDTOs (serialization/deserialization)
- [ ] Test DashboardModels (factory methods, helpers)
- [ ] Test DashboardState (validation logic, helpers)
- [ ] Test DashboardViewModel (state changes, error handling)
- [ ] Test DashboardRepository (data transformation)

### 8.2 Integration Tests
- [ ] Test dashboard data loading flow (ViewModel → Repository → API)
- [ ] Test period filter changes
- [ ] Test location filter changes
- [ ] Test alert dismissal

### 8.3 UI Tests
- [ ] Test dashboard screen rendering
- [ ] Test KPI card taps
- [ ] Test chart interactions
- [ ] Test alert dismissal
- [ ] Test filter interactions
- [ ] Test pull-to-refresh

### 8.4 Manual Testing
- [ ] Test on Android device
- [ ] Test on iOS device
- [ ] Test dark mode
- [ ] Test with different user roles
- [ ] Test offline mode
- [ ] Test error scenarios

---

## Phase 9: Dashboard Documentation & Cleanup 📚

### 9.1 Code Documentation
- [ ] Add doc comments to all public APIs
- [ ] Document ViewModel methods
- [ ] Document Repository methods
- [ ] Document widget components

### 9.2 Code Cleanup
- [ ] Remove unused imports
- [ ] Remove commented-out code
- [ ] Ensure consistent code style
- [ ] Run `dart format` on all files
- [ ] Fix all linter warnings

### 9.3 Project Documentation
- [ ] Update main README.md with Dashboard module info
- [ ] Document dashboard API endpoints
- [ ] Document role-based access rules

---

## Progress Tracking

**Current Phase:** Phase 5 - Dashboard Module - UI Integration

**Completed:** 
- ✅ Phase 1: Foundation & Core Infrastructure (100%)
- ✅ Phase 2: Authentication Module (100%)
- ✅ Inventory Module (100% - All 6 screens complete, tested, and documented)
- ✅ Phase 3: Dashboard Module - Data Layer (100% - All DTOs, Models, API, Repository complete)
- ✅ Phase 4: Dashboard Module - State Management (100% - DashboardState and DashboardViewModel complete with request tokens, validation, and error handling)

**In Progress:**
- 🔄 Phase 5: Dashboard Module - UI Integration (~85%)
  - ✅ Phase 5.1: Dashboard Screen (Core functionality complete - header, filters, KPIs, charts, alerts, navigation)
  - ⏳ Phase 5.2: Dashboard Widgets (Core widgets implemented inline, some reusable widgets pending extraction)
  - ⏳ Phase 5.3: Role-Based Visibility (Deferred - basic structure in place)

**Next Milestone:** Phase 5.2 (Extract reusable widgets) & Phase 5.3 (Role-based visibility) - Polish and role-based features

---

## Notes

### Design vs Blueprint Alignment
- ✅ **Can build from current design:** Core dashboard structure, KPIs, charts, alerts, filters
- ✅ **Reusable components:** Donut chart → Expense Pie Chart, Bar chart → Channels Chart, Line chart → Inventory Value Chart
- ⚠️ **Gaps from blueprint (can add later):**
  - Total Profit KPI card (can calculate from Sales - Expenses, may show in chart or add card later)
  - Best Seller KPI card (shown in Top Products chart instead - acceptable)
  - Top Category KPI card (can add later if needed)
  - Expense Pie Chart (reuse donut chart component, add for Manager/Admin/Accountant roles)
  - Top Channels Chart (reuse bar chart component, add later)
  - Inventory Value Line Chart (reuse line chart component, currently placeholder)
  - Promotion Expiry alerts (may be role-filtered, add for Sales/Manager roles)

### Implementation Strategy
- **Phase 1 (MVP):** Build what's in the design screens
- **Phase 2 (Enhancements):** Add missing blueprint elements using reusable chart components
- **Component Reuse:** Create generic chart widgets that can be configured for different data types
- Dashboard module depends on Sales, Expenses, and Production modules for full functionality
- Some navigation targets (Sales Report, Expense Report, etc.) may not exist yet - use placeholder navigation or defer
- Chart library: Consider using `fl_chart` or `syncfusion_flutter_charts` for Flutter charts
- Period filter defaults to WEEK as per design (not TODAY as in some screens)
- Role-based visibility is critical - ensure proper permission checks
- Each phase should be completed before moving to the next
- Some tasks can be done in parallel (e.g., API + Repository)
- Test after each major feature implementation
- Keep backend API documentation handy for endpoint details
- Update this plan as we discover new requirements

---

## Quick Reference: Backend Endpoints

**Completed Modules:**
- `POST /api/auth/login` ✅
- `GET /api/inventory/locations/` ✅
- `GET /api/inventory/items/` ✅
- `GET /api/inventory/overview/` ✅
- `POST /api/inventory/stock/adjust/` ✅
- `POST /api/inventory/stock/transfer/` ✅
- `GET /api/inventory/stock/movements/` ✅

**Dashboard Module (To be implemented):**
- `GET /api/dashboard/` - Full dashboard data (MVP - based on design)
- `GET /api/dashboard/kpis/` - KPI data only (Total Sales, Total Expenses, role-specific KPIs)
- `GET /api/dashboard/charts/sales-trend/` - Sales trend chart data (7 days, Mon-Sun)
- `GET /api/dashboard/charts/top-products/` - Top products chart data (for donut chart)
- `GET /api/dashboard/charts/expenses/` - Expense breakdown chart data (**GAP: Add later**)
- `GET /api/dashboard/charts/channels/` - Channel sales chart data (**GAP: Add later**)
- `GET /api/dashboard/charts/inventory-value/` - Inventory value chart data (**GAP: Add later**)
- `GET /api/dashboard/alerts/` - Dashboard alerts/notifications (Low Stock, Payment Due, Upcoming Batch, Promotion Expiry)

**Note:** Endpoints marked as "GAP: Add later" correspond to missing charts from design but can reuse chart components when added.

*Verify actual endpoints with backend team/API docs*

---

## Recent Updates / Changelog

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
