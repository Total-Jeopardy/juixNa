# JuixNa Mobile App - API Specification & Design Decisions

**Last Updated:** Based on Inventory API v1 + Web Dashboard Spec

**Base URL:** `https://juixna-api.onrender.com/`

---

## 🔐 Authentication

### Login Endpoint
- **Method:** `POST`
- **URL:** `/api/auth/login`
- **Request Body:**
  ```json
  {
    "email": "user@example.com",
    "password": "password123"
  }
  ```
- **Response:** Returns JWT access token
- **Expected Response Format:** (To be verified during implementation)
  ```json
  {
    "access_token": "jwt_token_here",
    "token_type": "bearer",
    "user": {
      "id": 1,
      "email": "user@example.com",
      "name": "User Name",
      "roles": ["manager", "staff"],
      "permissions": ["inventory.view", "sales.create", ...]
    }
  }
  ```

### Auth Header
All endpoints require:
```
Authorization: Bearer <token>
```

### Test Accounts
- **Admin:** `admin@example.com` / `secret123`
- **Manager:** `manager@example.com` / `secret123`
- **Staff:** `staff@example.com` / `secret123`

---

## 📦 Inventory API Endpoints

### 1. Locations List ✅
- **Method:** `GET`
- **URL:** `/api/inventory/locations/`
- **Query Params (optional):**
  - `is_active`: `true|false` (default: `true`)
- **Response:**
  ```json
  [
    {
      "id": 1,
      "name": "Main Outlet",
      "description": "Primary sales location",
      "is_active": true,
      "created_at": "2025-12-01T10:15:00",
      "updated_at": "2025-12-01T10:15:00"
    }
  ]
  ```

### 2. Inventory Items (All Locations) ✅
- **Method:** `GET`
- **URL:** `/api/inventory/items/`
- **Query Params (optional):**
  - `kind`: `INGREDIENT | FINISHED_PRODUCT | PACKAGING`
  - `search`: free text (matches name or sku)
  - `skip`: integer offset (default: 0)
  - `limit`: page size (default: 50)
- **Response:**
  ```json
  {
    "items": [
      {
        "id": 3,
        "name": "Orange Juice 500ml",
        "sku": "ORJ-500-01",
        "unit": "ML",
        "kind": "FINISHED_PRODUCT",
        "total_quantity": "1240.000",
        "locations": [
          {
            "location_id": 1,
            "location_name": "Main Outlet",
            "current_stock": "240.000"
          }
        ]
      }
    ],
    "pagination": {
      "skip": 0,
      "limit": 50,
      "total": 1
    }
  }
  ```

### 3. Items at Specific Location ✅
- **Method:** `GET`
- **URL:** `/api/inventory/locations/{location_id}/items/`
- **Query Params (optional):**
  - `kind`: `INGREDIENT | FINISHED_PRODUCT | PACKAGING`
  - `search`: free text
  - `skip`, `limit`
- **Response:**
  ```json
  {
    "location": {
      "id": 1,
      "name": "Main Outlet"
    },
    "items": [
      {
        "id": 3,
        "name": "Orange Juice 500ml",
        "sku": "ORJ-500-01",
        "unit": "ML",
        "kind": "FINISHED_PRODUCT",
        "current_stock": "240.000"
      }
    ],
    "pagination": {
      "skip": 0,
      "limit": 50,
      "total": 1
    }
  }
  ```

### 4. Stock Movement History ✅
- **Method:** `GET`
- **URL:** `/api/inventory/stock/movements/`
- **Query Params (optional):**
  - `item_id`: int
  - `location_id`: int
  - `type`: `IN | OUT | ADJUST | TRANSFER`
  - `from_date`: ISO date or datetime
  - `to_date`: ISO date or datetime
  - `skip`, `limit`
- **Response:**
  ```json
  {
    "transactions": [
      {
        "id": 101,
        "item_id": 3,
        "item_name": "Orange Juice 500ml",
        "location_id": 1,
        "location_name": "Main Outlet",
        "quantity": "12.000",
        "type": "OUT",
        "reason": "SALE",
        "reference": "SALE-2025-000123",
        "created_at": "2025-12-07T09:30:00",
        "created_by": "admin@example.com"
      }
    ],
    "pagination": {
      "skip": 0,
      "limit": 50,
      "total": 1
    }
  }
  ```

### 5. Stock Transfer ✅
- **Method:** `POST`
- **URL:** `/api/inventory/stock/transfer/`
- **Request Body:**
  ```json
  {
    "item_id": 3,
    "from_location_id": 2,
    "to_location_id": 1,
    "quantity": "120.000",
    "reference": "TR-2025-0005",
    "note": "Replenish main outlet"
  }
  ```
- **Response (201):**
  ```json
  {
    "id": 205,
    "item_id": 3,
    "from_location_id": 2,
    "to_location_id": 1,
    "quantity": "120.000",
    "reference": "TR-2025-0005",
    "note": "Replenish main outlet",
    "created_at": "2025-12-07T10:12:00",
    "created_by_id": 1
  }
  ```

### 6. Stock Adjustment (Manual IN/OUT) ✅
- **Method:** `POST`
- **URL:** `/api/inventory/stock/adjust/`
- **Request Body:**
  ```json
  {
    "item_id": 3,
    "location_id": 1,
    "quantity": "-3.000",
    "reason": "BREAKAGE",
    "reference": "ADJ-2025-0003",
    "note": "3 bottles broken"
  }
  ```
- **Note:** Positive quantity = adjustment in, negative = adjustment out
- **Response (201):**
  ```json
  {
    "id": 310,
    "item_id": 3,
    "location_id": 1,
    "quantity": "-3.000",
    "type": "ADJUST",
    "reason": "BREAKAGE",
    "reference": "ADJ-2025-0003",
    "note": "3 bottles broken",
    "created_at": "2025-12-07T10:20:00",
    "created_by_id": 1
  }
  ```

### 7. Inventory Overview (KPIs + Items) ⏳ **PLANNED**
- **Method:** `GET`
- **URL:** `/api/inventory/overview/`
- **Query Params:**
  - `location_id` (optional): If provided → KPIs and items for this location only
  - `kind` (optional): `INGREDIENT | FINISHED_PRODUCT | PACKAGING`
  - `search` (optional): text search
  - `page` (optional, default: 1)
  - `page_size` (optional, default: 25)
- **Response (200):**
  ```json
  {
    "kpis": {
      "total_items": 32,
      "total_skus": 32,
      "total_quantity_all_locations": "4820.000",
      "low_stock_items": 5,
      "out_of_stock_items": 2
    },
    "page": {
      "page": 1,
      "page_size": 25,
      "total_items": 32,
      "total_pages": 2
    },
    "items": [
      {
        "id": 3,
        "name": "Orange Juice 500ml",
        "sku": "ORJ-500-01",
        "unit": "ML",
        "kind": "FINISHED_PRODUCT",
        "total_quantity": "1240.000",
        "is_low_stock": false,
        "locations": [
          {
            "location_id": 1,
            "location_name": "Main Outlet",
            "current_stock": "240.000"
          }
        ]
      }
    ]
  }
  ```
- **Status:** Backend will implement; mobile should code against this contract

---

## 🎯 Design Decisions (Important for Mobile App)

### Categories
- **No full category hierarchy yet**
- Use `kind` + `name`/`sku` for grouping:
  - `kind`: `INGREDIENT`, `FINISHED_PRODUCT`, `PACKAGING`
  - `unit`: `ML`, `L`, `KG`, `PCS`, etc.
- **Decision:** v1 mobile uses `kind` + name/sku for grouping

### Location Type
- All locations treated uniformly (no `location_type` column yet)
- **Decision:**
  - API gives all locations
  - Default POS location id will be provided separately
  - Future `location_type` will be additive (won't break current contract)

### Batch Tracking
- Batches tracked in production module
- Inventory endpoints return **aggregated stock** per item/location
- **Decision:**
  - Sales & inventory screens work with aggregated stock only
  - Batch numbers **not required** in mobile requests for now

### Low-Stock Rules
- Per-item numeric threshold (`reorder_level`)
- Low-stock flag = `total_quantity <= reorder_level` (and `reorder_level > 0`)
- **Decision:**
  - Backend computes low-stock counts/flags
  - Exposed in KPI/overview endpoint
  - **App should NOT implement its own low-stock rules client-side**

### Cost Visibility
- Costs tracked server-side (purchase cost, average cost, etc.)
- **Decision:**
  - Operational inventory endpoints **do NOT expose cost fields** for normal staff
  - Cost info only in reporting/admin-only endpoints
  - Protected by role/permission (`finance.costs.view`, etc.)

---

## 👥 Roles & Permissions

### Roles (from Web Spec)
- Admin
- Manager
- Sales
- Inventory
- Production
- Accountant

### Permission Format
- Format: `module.action`
- Examples:
  - `sales.create`
  - `sales.read`
  - `sales.update`
  - `sales.delete`
  - `sales.approve_high_discount`
  - `inventory.stock_in`
  - `inventory.stock_out`
  - `inventory.transfer`
  - `inventory.adjust`
  - `inventory.view_valuation`
  - `production.batch_create`
  - `production.batch_update`
  - `production.view_costs`
  - `expenses.create`
  - `expenses.approve`
  - `expenses.view_sensitive_financials`
  - `reports.view_basic_reports`
  - `reports.view_financial_reports`
  - `admin.manage_users`
  - `admin.manage_roles`
  - `admin.manage_pricing`
  - `admin.manage_promotions`
  - `admin.system_settings`
  - `finance.costs.view`

### Permission Usage in Mobile
- Use for **UI conditional rendering** (show/hide features)
- Backend enforces permissions on API calls (returns 403 if unauthorized)
- Mobile should handle 403 errors gracefully

---

## 📊 Data Models

### User Model (Expected from Login)
```dart
class User {
  final int id;
  final String email;
  final String name;
  final List<String> roles;        // e.g., ["manager", "staff"]
  final List<String> permissions;  // e.g., ["inventory.view", "sales.create"]
}
```

### Inventory Item
```dart
class InventoryItem {
  final int id;
  final String name;
  final String sku;
  final String unit;              // "ML", "L", "KG", "PCS"
  final String kind;              // "INGREDIENT", "FINISHED_PRODUCT", "PACKAGING"
  final double totalQuantity;
  final bool isLowStock;
  final List<LocationStock> locations;
}

class LocationStock {
  final int locationId;
  final String locationName;
  final double currentStock;
}
```

### Location
```dart
class Location {
  final int id;
  final String name;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### Stock Movement
```dart
class StockMovement {
  final int id;
  final int itemId;
  final String itemName;
  final int locationId;
  final String locationName;
  final double quantity;
  final String type;              // "IN", "OUT", "ADJUST", "TRANSFER"
  final String reason;
  final String? reference;
  final DateTime createdAt;
  final String createdBy;
}
```

### Inventory KPIs
```dart
class InventoryKPIs {
  final int totalItems;
  final int totalSkus;
  final double totalQuantityAllLocations;
  final int lowStockItems;
  final int outOfStockItems;
}
```

---

## 🔄 Mobile vs Web Responsibilities

### Mobile App (Field Roles)
- ✅ Operational data entry: sales, inventory moves, production, expenses
- ✅ Day-to-day on-ground work
- ✅ View products (read-only catalog)
- ✅ Apply promotions (read-only of defined promos)
- ✅ Capture sales
- ✅ Stock-in, stock-out, transfers, cycle counts
- ✅ Capture batch data, yields, wastage
- ✅ Capture raw expenses
- ✅ Role-specific snapshots and simple reports
- ✅ Receive alerts & notifications

### Web Dashboard (Admin)
- ✅ User onboarding & roles
- ✅ Full product/pricing control
- ✅ Master data setup (categories, channels, locations)
- ✅ Approvals, corrections, bulk imports, exports
- ✅ Deep reports, financial views, strategic dashboards
- ✅ System configuration, integrations, automation rules
- ✅ Define promotions
- ✅ Analyze sales, correct entries
- ✅ Configure items, adjust inventory, analyze valuation
- ✅ Analyze batches, adjust costs, manage recipes

---

## 📝 Implementation Notes

### Pagination
- Most list endpoints support `skip`/`limit` or `page`/`page_size`
- Default page size: 25-50 items
- Always check `pagination.total` for total count

### Error Handling
- 401 Unauthorized → Token expired/invalid → Redirect to login
- 403 Forbidden → User lacks permission → Show error message
- 400/422 Validation → Show field-specific errors
- 500 Server Error → Show generic error, allow retry

### Date Formats
- Use ISO 8601 format: `"2025-12-07T09:30:00"` or `"2025-12-07"`

### Quantity Format
- Quantities are strings in API: `"1240.000"`
- Parse to `double` in mobile app
- Always use appropriate precision for the unit

### Reference Fields
- Optional but recommended for traceability
- Format examples: `"SALE-2025-000123"`, `"TR-2025-0005"`, `"ADJ-2025-0003"`

---

## 🚀 Next Steps

1. **Phase 2 (Auth):** Implement login with these test accounts
2. **Phase 3 (Inventory Data Layer):** Use endpoints 1-6 (already implemented)
3. **Phase 3 (Inventory Overview):** Code against endpoint 7 contract (backend will implement)
4. **Phase 4-5:** Build ViewModels and UI using these data models

---

**Note:** This spec will be updated as we discover more details during implementation.

