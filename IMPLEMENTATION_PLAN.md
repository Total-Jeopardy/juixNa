# JuixNa Mobile App - Implementation Plan

## Overview
This plan outlines the implementation status and next steps for the Flutter mobile app with MVVM + Riverpod architecture connected to the backend API.

**Backend API Base URL:** `https://juixna-api.onrender.com`

**Current Status:** ✅ Inventory Module Complete - All core phases (1-9) completed

---

## ✅ Completed Phases

### Phase 1-9: Foundation, Auth & Inventory Module ✅
- Foundation & Core Infrastructure
- Authentication Module (login, auth guards, token management)
- Inventory Module - Data Layer (DTOs, API, Repository)
- Inventory Module - State Management (ViewModels for all features)
- Inventory Module - UI Integration (6 screens: Overview, Movement, Transfer, Cycle Count, Reorder Alerts, History)
- Navigation & Routing (go_router integration)
- Error Handling & UX Polish
- Testing & Quality Assurance (99 tests passing)
- Documentation & Cleanup

**Result:** Fully functional inventory management system with comprehensive test coverage and documentation.

---

## 📋 Remaining Tasks

### Manual Testing (Recommended)
- [ ] Test on Android device
- [ ] Test on iOS device (if available)
- [ ] Test dark mode on all screens
- [ ] Test error scenarios (network errors, API errors)
- [ ] Test edge cases (empty lists, large data sets)
- [ ] Test with different user roles/permissions
- [ ] Test all form submissions end-to-end
- [ ] Test all navigation flows manually

---

## Phase 10: Dashboard Module 🎯

### Overview
Build a comprehensive dashboard that provides an overview of key metrics, quick actions, and role-based views for different user types (Admin, Manager, Staff).

**Approach:** UI-first development - Build complete UI for each screen before implementing backend functionality. One screen at a time.

---

### 10.1 Dashboard Overview Screen (Main Dashboard)

#### 10.1.1 UI Development (Admin View)
- [ ] Create `dashboard_screen.dart` file
- [ ] Design AppBar (title, user profile, notifications, theme toggle)
- [ ] Design header section:
  - [ ] Welcome message with user name
  - [ ] Role badge (Admin/Manager/Staff)
  - [ ] Date/time display
  - [ ] Quick stats cards (Total Items, Low Stock, Today's Movements, Pending Approvals)
- [ ] Design metrics section:
  - [ ] KPI cards in grid layout (Revenue, Orders, Inventory Value, etc.)
  - [ ] Charts/graphs area (placeholder for now)
  - [ ] Recent activity feed
- [ ] Design quick actions section:
  - [ ] Action buttons (Stock Movement, Transfer, Cycle Count, etc.)
  - [ ] Navigation to key screens
- [ ] Design bottom section:
  - [ ] Recent transactions list
  - [ ] Alerts/notifications summary
- [ ] Add proper spacing, colors, and styling
- [ ] Ensure responsive layout (different screen sizes)

#### 10.1.2 UI Development (Restricted Access View)
- [ ] Create restricted view variant (for Manager/Staff roles)
- [ ] Hide admin-only metrics and KPIs
- [ ] Show role-appropriate quick actions
- [ ] Adjust layout for limited permissions
- [ ] Add "Limited Access" indicators where needed

#### 10.1.3 UI Development (Empty State)
- [ ] Create empty state design (no data available)
- [ ] Add helpful message and illustration
- [ ] Add "Get Started" or "Refresh" button
- [ ] Handle case when user has no permissions

#### 10.1.4 UI Development (Loading State)
- [ ] Create loading state design
- [ ] Add skeleton loaders for metrics cards
- [ ] Add loading indicators for charts/data
- [ ] Ensure smooth transitions between states

#### 10.1.5 Functionality Implementation
- [ ] Create `DashboardState` class
- [ ] Create `DashboardViewModel` using Riverpod AsyncNotifier
- [ ] Create dashboard DTOs (if needed):
  - [ ] `DashboardKPIsDTO`
  - [ ] `DashboardMetricsDTO`
  - [ ] `RecentActivityDTO`
- [ ] Create `DashboardApi` class (or extend existing APIs):
  - [ ] `getDashboardOverview()` - GET `/api/dashboard/overview/`
  - [ ] `getDashboardMetrics()` - GET `/api/dashboard/metrics/`
  - [ ] `getRecentActivity()` - GET `/api/dashboard/activity/`
- [ ] Create `DashboardRepository`:
  - [ ] Wrap API calls
  - [ ] Transform DTOs to domain models
- [ ] Implement role-based data filtering:
  - [ ] Admin: All metrics and data
  - [ ] Manager: Department/team metrics
  - [ ] Staff: Personal/assigned metrics
- [ ] Connect ViewModel to UI:
  - [ ] Wire up data loading
  - [ ] Wire up refresh functionality
  - [ ] Wire up error handling
  - [ ] Wire up empty state display
- [ ] Add pull-to-refresh
- [ ] Add error handling and retry
- [ ] Test with different user roles

---

### 10.2 Analytics/Reports Screen (Optional - Admin Only)

#### 10.2.1 UI Development
- [ ] Create `analytics_screen.dart` file
- [ ] Design AppBar (back button, title, date range picker)
- [ ] Design filters section:
  - [ ] Date range selector
  - [ ] Location filter
  - [ ] Category/kind filter
- [ ] Design charts section:
  - [ ] Sales/Revenue chart (line or bar chart)
  - [ ] Inventory value chart
  - [ ] Stock movements chart
  - [ ] Top items chart
- [ ] Design summary tables:
  - [ ] Top performing items
  - [ ] Low stock items summary
  - [ ] Movement trends
- [ ] Add export functionality (UI only for now)
- [ ] Ensure responsive layout

#### 10.2.2 Functionality Implementation
- [ ] Create `AnalyticsState` class
- [ ] Create `AnalyticsViewModel`
- [ ] Create analytics DTOs:
  - [ ] `AnalyticsDataDTO`
  - [ ] `ChartDataDTO`
- [ ] Create `AnalyticsApi` class:
  - [ ] `getAnalyticsData(dateRange, filters)` - GET `/api/dashboard/analytics/`
- [ ] Create `AnalyticsRepository`
- [ ] Implement chart data processing
- [ ] Connect ViewModel to UI
- [ ] Add date range filtering
- [ ] Add export functionality (if backend supports)

---

### 10.3 Notifications/Alerts Screen

#### 10.3.1 UI Development
- [ ] Create `notifications_screen.dart` file
- [ ] Design AppBar (back button, "Notifications" title, mark all as read)
- [ ] Design notification list:
  - [ ] Notification card design
  - [ ] Unread indicator
  - [ ] Category/type badges
  - [ ] Timestamp display
  - [ ] Action buttons (if applicable)
- [ ] Design filter/tab bar:
  - [ ] All, Unread, Alerts, System, etc.
- [ ] Add empty state design
- [ ] Add loading state design

#### 10.3.2 Functionality Implementation
- [ ] Create `NotificationState` class
- [ ] Create `NotificationViewModel`
- [ ] Create notification DTOs:
  - [ ] `NotificationDTO`
  - [ ] `NotificationListDTO`
- [ ] Create `NotificationApi` class:
  - [ ] `getNotifications()` - GET `/api/notifications/`
  - [ ] `markAsRead(notificationId)` - POST `/api/notifications/{id}/read/`
  - [ ] `markAllAsRead()` - POST `/api/notifications/read-all/`
- [ ] Create `NotificationRepository`
- [ ] Connect ViewModel to UI
- [ ] Implement mark as read functionality
- [ ] Add real-time updates (if backend supports WebSocket/SSE)

---

### 10.4 Dashboard Navigation & Integration

#### 10.4.1 Router Updates
- [ ] Add dashboard route to `router.dart`:
  - [ ] `/dashboard` → DashboardScreen
  - [ ] `/dashboard/analytics` → AnalyticsScreen (if implemented)
  - [ ] `/dashboard/notifications` → NotificationsScreen (if implemented)
- [ ] Update auth redirect logic:
  - [ ] Redirect authenticated users to `/dashboard` instead of `/inventory`
  - [ ] Or redirect based on user role/preferences
- [ ] Add bottom navigation (if using tab-based navigation):
  - [ ] Dashboard tab
  - [ ] Inventory tab
  - [ ] Production tab (future)
  - [ ] Profile/Settings tab

#### 10.4.2 Navigation Integration
- [ ] Update Inventory Overview to navigate to Dashboard
- [ ] Add dashboard navigation from all major screens
- [ ] Wire up quick actions from Dashboard to target screens
- [ ] Add breadcrumbs or back navigation
- [ ] Test all navigation flows

---

## Phase 11: Production Module 🏭

### Overview
Build the Production module to manage production workflows, batch creation, and item manufacturing. This module will create items that flow into the Inventory module.

**Approach:** Same UI-first approach - Build complete UI, then implement functionality screen by screen.

---

### 11.1 Production Overview Screen

#### 11.1.1 UI Development
- [ ] Create `production_overview_screen.dart` file
- [ ] Design AppBar (title, filter button, refresh button, add button)
- [ ] Design header section:
  - [ ] Active batches summary
  - [ ] Today's production count
  - [ ] Pending items summary
- [ ] Design filter section:
  - [ ] Status filter (Active, Completed, Pending)
  - [ ] Date range filter
  - [ ] Product filter
- [ ] Design production list:
  - [ ] Production batch cards:
    - [ ] Batch ID/name
    - [ ] Product name and image
    - [ ] Status badge
    - [ ] Quantity produced
    - [ ] Start/completion date
    - [ ] Actions (View, Edit, Complete)
- [ ] Design empty state
- [ ] Design loading state
- [ ] Add pull-to-refresh

#### 11.1.2 Functionality Implementation
- [ ] Create `ProductionState` class
- [ ] Create `ProductionViewModel`
- [ ] Create production DTOs:
  - [ ] `ProductionBatchDTO`
  - [ ] `ProductionBatchListDTO`
- [ ] Create `ProductionApi` class:
  - [ ] `getProductionBatches(filters)` - GET `/api/production/batches/`
  - [ ] `getProductionBatch(id)` - GET `/api/production/batches/{id}/`
- [ ] Create `ProductionRepository`
- [ ] Connect ViewModel to UI
- [ ] Implement filtering
- [ ] Implement refresh
- [ ] Add error handling

---

### 11.2 Create Production Batch Screen

#### 11.2.1 UI Development
- [ ] Create `create_production_batch_screen.dart` file
- [ ] Design AppBar (back button, "New Production Batch" title)
- [ ] Design form:
  - [ ] Product selector (with product picker)
  - [ ] Batch name/number field
  - [ ] Planned quantity field
  - [ ] Start date/time picker
  - [ ] Expected completion date
  - [ ] Recipe/formula selector (if applicable)
  - [ ] Notes field
- [ ] Design validation error display areas
- [ ] Design footer buttons:
  - [ ] Cancel button
  - [ ] Save/Create button
- [ ] Add loading state
- [ ] Add success state

#### 11.2.2 Functionality Implementation
- [ ] Create `CreateProductionBatchState` class
- [ ] Create `CreateProductionBatchViewModel`
- [ ] Create production batch DTOs:
  - [ ] `CreateProductionBatchRequestDTO`
  - [ ] `ProductionBatchResponseDTO`
- [ ] Extend `ProductionApi`:
  - [ ] `createProductionBatch(data)` - POST `/api/production/batches/`
- [ ] Extend `ProductionRepository`
- [ ] Implement form validation
- [ ] Implement product selection
- [ ] Connect ViewModel to UI
- [ ] Add success navigation
- [ ] Add error handling

---

### 11.3 Production Batch Details Screen

#### 11.3.1 UI Development
- [ ] Create `production_batch_details_screen.dart` file
- [ ] Design AppBar (back button, batch name, edit button, menu)
- [ ] Design header section:
  - [ ] Batch information card
  - [ ] Status badge
  - [ ] Progress indicator
- [ ] Design details section:
  - [ ] Product information
  - [ ] Quantity information (planned, produced, remaining)
  - [ ] Date information (start, expected, actual completion)
  - [ ] Recipe/formula details (if applicable)
- [ ] Design actions section:
  - [ ] Update quantity button
  - [ ] Complete batch button
  - [ ] Cancel batch button
- [ ] Design history/activity section:
  - [ ] Timeline of batch activities
  - [ ] Quantity updates log
- [ ] Add loading state
- [ ] Add error state

#### 11.3.2 Functionality Implementation
- [ ] Create `ProductionBatchDetailsState` class
- [ ] Create `ProductionBatchDetailsViewModel`
- [ ] Extend `ProductionApi`:
  - [ ] `updateProductionBatch(id, data)` - PUT `/api/production/batches/{id}/`
  - [ ] `completeProductionBatch(id)` - POST `/api/production/batches/{id}/complete/`
  - [ ] `cancelProductionBatch(id)` - POST `/api/production/batches/{id}/cancel/`
  - [ ] `updateBatchQuantity(id, quantity)` - POST `/api/production/batches/{id}/quantity/`
- [ ] Extend `ProductionRepository`
- [ ] Connect ViewModel to UI
- [ ] Implement update quantity
- [ ] Implement complete batch (triggers inventory update)
- [ ] Implement cancel batch
- [ ] Add confirmation dialogs
- [ ] Add error handling

---

### 11.4 Production Integration with Inventory

#### 11.4.1 Complete Batch → Inventory Flow
- [ ] When batch is completed:
  - [ ] Create inventory items in Finished Goods
  - [ ] Update stock levels automatically
  - [ ] Create stock movement record
- [ ] Implement batch completion handler:
  - [ ] Call production API to complete batch
  - [ ] Call inventory API to add items
  - [ ] Create stock movement (IN type)
  - [ ] Show success message
  - [ ] Navigate to inventory overview
- [ ] Add error handling for failed inventory updates
- [ ] Add rollback mechanism (if batch completion fails after inventory update)

#### 11.4.2 Inventory Item Creation
- [ ] When creating production batch:
  - [ ] Verify product exists in inventory
  - [ ] If not, create inventory item first
  - [ ] Link production batch to inventory item
- [ ] Implement item creation flow:
  - [ ] Check if item exists
  - [ ] Create item if needed
  - [ ] Continue with batch creation
- [ ] Add validation and error handling

---

### 11.5 Production Navigation & Integration

#### 11.5.1 Router Updates
- [ ] Add production routes to `router.dart`:
  - [ ] `/production` → ProductionOverviewScreen
  - [ ] `/production/create` → CreateProductionBatchScreen
  - [ ] `/production/batch/:id` → ProductionBatchDetailsScreen
- [ ] Add navigation from Dashboard
- [ ] Add navigation from Inventory (if applicable)

#### 11.5.2 Module Integration
- [ ] Ensure production items appear in Inventory Overview
- [ ] Link production batches to inventory items
- [ ] Show production source in inventory item details
- [ ] Add "View Production Batch" action in inventory screens

---

## Phase 12: Testing & Documentation (Dashboard & Production)

### 12.1 Testing
- [ ] Unit tests for Dashboard ViewModels
- [ ] Unit tests for Production ViewModels
- [ ] Integration tests for Dashboard flows
- [ ] Integration tests for Production → Inventory flows
- [ ] UI tests for Dashboard screens
- [ ] UI tests for Production screens
- [ ] Role-based access testing
- [ ] End-to-end workflow testing (Production → Inventory)

### 12.2 Documentation
- [ ] Update README.md with Dashboard and Production modules
- [ ] Document Dashboard API endpoints
- [ ] Document Production API endpoints
- [ ] Create API documentation for backend team (Production module)
- [ ] Update architecture documentation
- [ ] Document role-based access patterns

---

## Implementation Guidelines

### UI-First Development Process
1. **Design Complete UI** - Build all UI components, states (loading, empty, error), and layouts
2. **No Functionality Yet** - Use dummy/placeholder data, mock navigation
3. **Review & Refine** - Ensure UI matches design requirements
4. **Implement Backend Integration** - Add ViewModels, APIs, Repositories
5. **Connect UI to Logic** - Wire up ViewModels to UI components
6. **Test & Iterate** - Test functionality, fix issues, refine UX

### Code Organization
- Follow existing MVVM + Riverpod pattern
- Use same directory structure: `features/{module}/{data,model,view,viewmodel}`
- Reuse existing utilities (ErrorDisplay, AuthErrorHandler, etc.)
- Follow existing code style and formatting

### Best Practices
- One screen at a time - complete fully before moving to next
- Test each screen independently
- Reuse components where possible
- Maintain consistency with Inventory module
- Document API contracts before implementation
- Handle all states (loading, empty, error, success)

---

## Quick Reference: Expected API Endpoints

### Dashboard Endpoints
- `GET /api/dashboard/overview/` - Dashboard overview data
- `GET /api/dashboard/metrics/` - Dashboard metrics/KPIs
- `GET /api/dashboard/analytics/` - Analytics data (if implemented)
- `GET /api/notifications/` - User notifications
- `POST /api/notifications/{id}/read/` - Mark notification as read
- `POST /api/notifications/read-all/` - Mark all as read

### Production Endpoints
- `GET /api/production/batches/` - List production batches
- `GET /api/production/batches/{id}/` - Get batch details
- `POST /api/production/batches/` - Create production batch
- `PUT /api/production/batches/{id}/` - Update production batch
- `POST /api/production/batches/{id}/complete/` - Complete batch
- `POST /api/production/batches/{id}/cancel/` - Cancel batch
- `POST /api/production/batches/{id}/quantity/` - Update quantity

*Verify actual endpoints with backend team/API docs*

---

## Notes

- Dashboard and Production modules follow the same architecture as Inventory module
- Role-based access control should be implemented throughout
- Production module feeds into Inventory module - ensure proper integration
- Test all workflows end-to-end (Production → Inventory → Dashboard)
- Keep backend team informed of API requirements
- Update this plan as requirements evolve

---

## Recent Milestones

### Phase 9 Complete: Documentation & Cleanup ✅
- Comprehensive README.md created
- API documentation for backend team created
- All code formatted with dart format
- All tests passing (99 tests)

### Phase 8 Complete: Testing & Quality Assurance ✅
- 88 unit tests (models, states, repositories, ViewModels)
- 3 integration tests (login flow, inventory loading)
- 8 UI tests (screens, navigation, forms)

### Phase 1-7 Complete: Foundation, Auth & Inventory ✅
- Complete inventory management system
- Authentication and authorization
- Navigation and routing
- Error handling and UX polish
