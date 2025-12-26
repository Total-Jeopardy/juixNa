# Inventory Module - Backend API Documentation

## Overview

This document describes the complete backend API requirements for the Inventory Module in the JuixNa mobile application. It details all endpoints, request/response formats, query parameters, and data structures required for the mobile app to function correctly.

**Last Updated:** Phase 9 Complete (Testing & Documentation)

---

## Table of Contents

1. [Authentication Requirements](#authentication-requirements)
2. [API Endpoints](#api-endpoints)
3. [Data Models](#data-models)
4. [Error Handling](#error-handling)
5. [Query Parameters](#query-parameters)
6. [Request/Response Examples](#requestresponse-examples)

---

## Authentication Requirements

All inventory endpoints require authentication via Bearer token in the Authorization header:

```
Authorization: Bearer <access_token>
```

**Token Source:** Obtained from `/auth/login` endpoint

**Token Expiry Handling:** 
- Mobile app expects 401 (Unauthorized) responses when token expires
- App will automatically logout user on 401 errors

---

## API Endpoints

### 1. Get Locations

**Endpoint:** `GET /inventory/locations`

**Description:** Retrieves all inventory locations (warehouses, stores, etc.)

**Query Parameters:**
- `is_active` (optional, boolean): Filter by active status
  - `true`: Only active locations
  - `false`: Only inactive locations
  - Omitted: All locations

**Response Format:**
```json
[
  {
    "id": 1,
    "name": "Warehouse A",
    "is_active": true,
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  }
]
```

**Response Fields:**
- `id` (integer, required): Unique location identifier
- `name` (string, required): Location name
- `is_active` (boolean, required): Whether location is active
- `created_at` (string, ISO 8601, required): Creation timestamp
- `updated_at` (string, ISO 8601, required): Last update timestamp

**Mobile App Usage:**
- Used in: Inventory Overview, Stock Movement, Stock Transfer, Cycle Count
- Displayed in: Location filters and dropdowns
- Filtered by: `is_active=true` by default

---

### 2. Get Inventory Overview

**Endpoint:** `GET /inventory/overview`

**Description:** Retrieves inventory overview with KPIs, items, and pagination

**Query Parameters:**
- `location_id` (optional, integer): Filter items by location
- `kind` (optional, string): Filter by item kind
  - Values: `"FINISHED_PRODUCT"`, `"RAW_MATERIAL"`, `"COMPONENT"`, `"PACKAGING"`
- `search` (optional, string): Search by item name or SKU
- `page` (optional, integer, default: 1): Page number for pagination
- `page_size` (optional, integer, default: 10): Items per page

**Response Format:**
```json
{
  "kpis": {
    "total_items": 150,
    "total_skus": 75,
    "total_quantity_all_locations": "5000.50",
    "low_stock_items": 5,
    "out_of_stock_items": 2
  },
  "items": [
    {
      "id": 1,
      "name": "Product A",
      "sku": "SKU-001",
      "unit": "kg",
      "kind": "FINISHED_PRODUCT",
      "total_quantity": "100.50"
    }
  ],
  "page": {
    "skip": 0,
    "limit": 10,
    "total": 150
  }
}
```

**Response Fields:**

**KPIs Object:**
- `total_items` (integer, required): Total number of inventory items
- `total_skus` (integer, required): Total number of unique SKUs
- `total_quantity_all_locations` (string, required): Total quantity across all locations (decimal as string)
- `low_stock_items` (integer, required): Count of items below reorder level
- `out_of_stock_items` (integer, required): Count of items with zero stock

**Items Array:**
- `id` (integer, required): Item identifier
- `name` (string, required): Item name
- `sku` (string, required): Stock Keeping Unit
- `unit` (string, required): Unit of measurement (e.g., "kg", "pcs", "liters")
- `kind` (string, required): Item type (enum: FINISHED_PRODUCT, RAW_MATERIAL, COMPONENT, PACKAGING)
- `total_quantity` (string, nullable): Total quantity across all locations (decimal as string, can be null)

**Pagination Object:**
- `skip` (integer, required): Number of items skipped
- `limit` (integer, required): Items per page
- `total` (integer, required): Total number of items matching query

**Mobile App Usage:**
- Primary screen: Inventory Overview Dashboard
- Displays: KPIs, item list with search and filters
- Supports: Pull-to-refresh, pagination, location/kind filtering

---

### 3. Get Inventory Items

**Endpoint:** `GET /inventory/items`

**Description:** Retrieves paginated list of inventory items (alternative to overview endpoint)

**Query Parameters:**
- `kind` (optional, string): Filter by item kind
- `search` (optional, string): Search by name or SKU
- `skip` (optional, integer, default: 0): Number of items to skip
- `limit` (optional, integer, default: 10): Maximum items to return

**Response Format:**
```json
{
  "items": [
    {
      "id": 1,
      "name": "Product A",
      "sku": "SKU-001",
      "unit": "kg",
      "kind": "FINISHED_PRODUCT",
      "total_quantity": "100.50"
    }
  ],
  "pagination": {
    "skip": 0,
    "limit": 10,
    "total": 150
  }
}
```

**Mobile App Usage:**
- Used for: Product pickers, search functionality
- Supports: Debounced search (500ms delay)

---

### 4. Get Location Items

**Endpoint:** `GET /inventory/locations/{location_id}/items`

**Description:** Retrieves items at a specific location with quantities

**Path Parameters:**
- `location_id` (integer, required): Location identifier

**Query Parameters:**
- `kind` (optional, string): Filter by item kind
- `search` (optional, string): Search by name or SKU
- `skip` (optional, integer, default: 0)
- `limit` (optional, integer, default: 10)

**Response Format:**
```json
{
  "location": {
    "id": 1,
    "name": "Warehouse A",
    "is_active": true,
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  },
  "items": [
    {
      "id": 1,
      "item_id": 1,
      "item_name": "Product A",
      "item_sku": "SKU-001",
      "location_id": 1,
      "location_name": "Warehouse A",
      "quantity": "50.25",
      "unit": "kg"
    }
  ],
  "pagination": {
    "skip": 0,
    "limit": 10,
    "total": 50
  }
}
```

**Response Fields:**

**Location Object:** Same as Get Locations response

**Items Array:**
- `id` (integer, required): Item-location relationship ID
- `item_id` (integer, required): Item identifier
- `item_name` (string, required): Item name
- `item_sku` (string, required): Item SKU
- `location_id` (integer, required): Location identifier
- `location_name` (string, required): Location name
- `quantity` (string, required): Quantity at this location (decimal as string)
- `unit` (string, required): Unit of measurement

**Mobile App Usage:**
- Used in: Location-specific inventory views
- Displays: Items with quantities per location

---

### 5. Get Available Stock

**Endpoint:** `GET /inventory/items/{item_id}/locations/{location_id}/stock`

**Description:** Gets available stock quantity for an item at a specific location

**Path Parameters:**
- `item_id` (integer, required): Item identifier
- `location_id` (integer, required): Location identifier

**Response Format:**
```json
{
  "item_id": 1,
  "location_id": 1,
  "available_quantity": "50.25",
  "unit": "kg"
}
```

**Response Fields:**
- `item_id` (integer, required): Item identifier
- `location_id` (integer, required): Location identifier
- `available_quantity` (string, required): Available quantity (decimal as string)
- `unit` (string, required): Unit of measurement

**Mobile App Usage:**
- Used in: Stock Movement (stock-out validation), Stock Transfer (quantity validation)
- Validates: Quantity doesn't exceed available stock for stock-out operations

---

### 6. Create Stock Movement (Adjust Stock)

**Endpoint:** `POST /inventory/adjust`

**Description:** Creates a stock adjustment (stock-in or stock-out)

**Request Body:**
```json
{
  "item_id": 1,
  "location_id": 1,
  "quantity": "10.50",
  "type": "ADJUST",
  "reason": "SALE",
  "reference": "REF-12345",
  "note": "Customer sale"
}
```

**Request Fields:**
- `item_id` (integer, required): Item identifier
- `location_id` (integer, required): Location identifier
- `quantity` (string, required): Quantity to adjust (decimal as string)
  - Positive value: Stock-in (add inventory)
  - Negative value: Stock-out (remove inventory)
- `type` (string, required): Movement type, must be `"ADJUST"`
- `reason` (string, required): Reason for adjustment
  - Common values: `"SALE"`, `"RETURN"`, `"DAMAGE"`, `"ADJUSTMENT"`, `"OTHER"`
- `reference` (string, optional): Reference number/document
- `note` (string, optional): Additional notes

**Response Format:**
```json
{
  "id": 1,
  "item_id": 1,
  "location_id": 1,
  "quantity": "10.50",
  "type": "ADJUST",
  "reason": "SALE",
  "reference": "REF-12345",
  "note": "Customer sale",
  "created_at": "2024-01-01T12:00:00Z",
  "created_by_id": 1
}
```

**Response Fields:**
- `id` (integer, required): Movement record ID
- `item_id` (integer, required): Item identifier
- `location_id` (integer, required): Location identifier
- `quantity` (string, required): Adjusted quantity (decimal as string)
- `type` (string, required): Movement type
- `reason` (string, required): Reason code
- `reference` (string, nullable): Reference number
- `note` (string, nullable): Additional notes
- `created_at` (string, ISO 8601, required): Creation timestamp
- `created_by_id` (integer, required): User who created the movement

**Mobile App Validation:**
- Validates: Quantity > 0 for stock-in, Quantity <= available stock for stock-out
- Required fields: item_id, location_id, quantity, reason
- Optional fields: reference, note

**Mobile App Usage:**
- Screen: Stock Movement
- Supports: Stock-in and stock-out operations
- Validates: Available stock before allowing stock-out

---

### 7. Create Stock Transfer

**Endpoint:** `POST /inventory/transfer`

**Description:** Transfers stock from one location to another

**Request Body:**
```json
{
  "item_id": 1,
  "from_location_id": 1,
  "to_location_id": 2,
  "quantity": "25.50",
  "note": "Transfer to store"
}
```

**Request Fields:**
- `item_id` (integer, required): Item identifier
- `from_location_id` (integer, required): Source location identifier
- `to_location_id` (integer, required): Destination location identifier
- `quantity` (string, required): Quantity to transfer (decimal as string, must be > 0)
- `note` (string, optional): Additional notes

**Response Format:**
```json
{
  "id": 1,
  "item_id": 1,
  "item_name": "Product A",
  "from_location_id": 1,
  "from_location_name": "Warehouse A",
  "to_location_id": 2,
  "to_location_name": "Store B",
  "quantity": "25.50",
  "created_at": "2024-01-01T12:00:00Z",
  "created_by_id": 1
}
```

**Response Fields:**
- `id` (integer, required): Transfer record ID
- `item_id` (integer, required): Item identifier
- `item_name` (string, required): Item name
- `from_location_id` (integer, required): Source location identifier
- `from_location_name` (string, required): Source location name
- `to_location_id` (integer, required): Destination location identifier
- `to_location_name` (string, required): Destination location name
- `quantity` (string, required): Transferred quantity (decimal as string)
- `created_at` (string, ISO 8601, required): Creation timestamp
- `created_by_id` (integer, required): User who created the transfer

**Mobile App Validation:**
- Validates: from_location_id != to_location_id (same location check)
- Validates: quantity > 0
- Validates: quantity <= available stock at source location
- Required fields: item_id, from_location_id, to_location_id, quantity
- Optional fields: note

**Mobile App Usage:**
- Screen: Stock Transfer
- Creates: Two movements (OUT from source, IN to destination)
- Displays: Transfer confirmation with details

---

### 8. Get Transfer History

**Endpoint:** `GET /inventory/transfers`

**Description:** Retrieves history of stock transfers

**Query Parameters:**
- `item_id` (optional, integer): Filter by item
- `from_location_id` (optional, integer): Filter by source location
- `to_location_id` (optional, integer): Filter by destination location
- `search` (optional, string): Search by item name or SKU
- `skip` (optional, integer, default: 0)
- `limit` (optional, integer, default: 10)

**Response Format:**
```json
{
  "transfers": [
    {
      "id": 1,
      "item_id": 1,
      "item_name": "Product A",
      "item_sku": "SKU-001",
      "from_location_id": 1,
      "from_location_name": "Warehouse A",
      "to_location_id": 2,
      "to_location_name": "Store B",
      "quantity": "25.50",
      "created_at": "2024-01-01T12:00:00Z",
      "created_by_id": 1
    }
  ],
  "page": {
    "skip": 0,
    "limit": 10,
    "total": 50
  }
}
```

**Response Fields:**

**Transfers Array:**
- `id` (integer, required): Transfer record ID
- `item_id` (integer, required): Item identifier
- `item_name` (string, required): Item name
- `item_sku` (string, required): Item SKU
- `from_location_id` (integer, required): Source location identifier
- `from_location_name` (string, required): Source location name
- `to_location_id` (integer, required): Destination location identifier
- `to_location_name` (string, required): Destination location name
- `quantity` (string, required): Transferred quantity (decimal as string)
- `created_at` (string, ISO 8601, required): Creation timestamp
- `created_by_id` (integer, required): User who created the transfer

**Pagination Object:** Same as Get Inventory Overview

**Mobile App Usage:**
- Screen: Transfer History
- Supports: Filtering by item, location, search
- Displays: Transfer list with item and location details

---

### 9. Get System Quantity (Cycle Count)

**Endpoint:** `GET /inventory/items/{item_id}/locations/{location_id}/system-quantity`

**Description:** Gets the system-recorded quantity for an item at a location (for cycle count)

**Path Parameters:**
- `item_id` (integer, required): Item identifier
- `location_id` (integer, required): Location identifier

**Response Format:**
```json
{
  "item_id": 1,
  "location_id": 1,
  "system_quantity": "50.25",
  "unit": "kg"
}
```

**Response Fields:**
- `item_id` (integer, required): Item identifier
- `location_id` (integer, required): Location identifier
- `system_quantity` (string, required): System-recorded quantity (decimal as string)
- `unit` (string, required): Unit of measurement

**Mobile App Usage:**
- Screen: Cycle Count
- Purpose: Display system quantity for comparison with counted quantity
- Calculates: Variance = counted_quantity - system_quantity

---

### 10. Adjust Stock from Cycle Count

**Endpoint:** `POST /inventory/cycle-count/adjust`

**Description:** Adjusts stock based on cycle count (physical count vs system count)

**Request Body:**
```json
{
  "item_id": 1,
  "location_id": 1,
  "system_quantity": "50.25",
  "counted_quantity": "48.00",
  "note": "Physical count discrepancy"
}
```

**Request Fields:**
- `item_id` (integer, required): Item identifier
- `location_id` (integer, required): Location identifier
- `system_quantity` (string, required): System-recorded quantity (decimal as string)
- `counted_quantity` (string, required): Physically counted quantity (decimal as string)
- `note` (string, optional): Notes about the adjustment

**Response Format:**
```json
{
  "id": 1,
  "item_id": 1,
  "location_id": 1,
  "system_quantity": "50.25",
  "counted_quantity": "48.00",
  "variance": "-2.25",
  "created_at": "2024-01-01T12:00:00Z",
  "created_by_id": 1
}
```

**Response Fields:**
- `id` (integer, required): Adjustment record ID
- `item_id` (integer, required): Item identifier
- `location_id` (integer, required): Location identifier
- `system_quantity` (string, required): System quantity (decimal as string)
- `counted_quantity` (string, required): Counted quantity (decimal as string)
- `variance` (string, required): Calculated variance (counted - system, decimal as string)
  - Positive: Counted more than system (gain)
  - Negative: Counted less than system (loss)
- `created_at` (string, ISO 8601, required): Creation timestamp
- `created_by_id` (integer, required): User who created the adjustment

**Mobile App Validation:**
- Required fields: item_id, location_id, system_quantity, counted_quantity
- Optional fields: note
- Calculates: Variance automatically in mobile app for display
- Validates: Both quantities are provided and valid numbers

**Mobile App Usage:**
- Screen: Cycle Count
- Displays: System quantity, counted quantity input, calculated variance
- Shows: Positive variance (green), negative variance (red)
- Creates: Stock adjustment based on variance

---

### 11. Get Reorder Alerts

**Endpoint:** `GET /inventory/reorder-alerts`

**Description:** Retrieves items that are low stock or out of stock

**Query Parameters:**
- `location_id` (optional, integer): Filter by location
- `is_read` (optional, boolean): Filter by read status
- `skip` (optional, integer, default: 0)
- `limit` (optional, integer, default: 10)

**Response Format:**
```json
{
  "alerts": [
    {
      "id": 1,
      "item_id": 1,
      "item_name": "Product A",
      "item_sku": "SKU-001",
      "location_id": 1,
      "location_name": "Warehouse A",
      "current_stock": "5.00",
      "reorder_level": "10.00",
      "unit": "kg",
      "is_read": false,
      "created_at": "2024-01-01T12:00:00Z"
    }
  ],
  "page": {
    "skip": 0,
    "limit": 10,
    "total": 15
  }
}
```

**Response Fields:**

**Alerts Array:**
- `id` (integer, required): Alert identifier
- `item_id` (integer, required): Item identifier
- `item_name` (string, required): Item name
- `item_sku` (string, required): Item SKU
- `location_id` (integer, required): Location identifier
- `location_name` (string, required): Location name
- `current_stock` (string, required): Current stock level (decimal as string)
- `reorder_level` (string, nullable): Reorder level threshold (decimal as string, can be null)
- `unit` (string, required): Unit of measurement
- `is_read` (boolean, required): Whether alert has been read
- `created_at` (string, ISO 8601, required): Alert creation timestamp

**Pagination Object:** Same as Get Inventory Overview

**Mobile App Usage:**
- Screen: Reorder Alerts
- Displays: Low stock and out of stock items
- Supports: Mark as read, filter by location, dismiss alerts
- Note: Mark as read/dismiss are local operations (not sent to backend in v1)

---

## Data Models

### Item Kind Enum

The mobile app expects these values for the `kind` field:

- `"FINISHED_PRODUCT"`: Finished goods ready for sale
- `"RAW_MATERIAL"`: Raw materials for production
- `"COMPONENT"`: Components used in assembly
- `"PACKAGING"`: Packaging materials

### Movement Type

Currently, the mobile app only uses:
- `"ADJUST"`: General stock adjustment (stock-in or stock-out based on quantity sign)

### Reason Codes

Common reason codes used in stock movements:
- `"SALE"`: Sale to customer
- `"RETURN"`: Return from customer
- `"DAMAGE"`: Damaged goods
- `"ADJUSTMENT"`: Manual adjustment
- `"OTHER"`: Other reasons

---

## Error Handling

### Expected HTTP Status Codes

- `200 OK`: Successful request
- `201 Created`: Successful creation (POST requests)
- `400 Bad Request`: Invalid request data
- `401 Unauthorized`: Invalid or expired token (triggers auto-logout)
- `403 Forbidden`: Insufficient permissions
- `404 Not Found`: Resource not found
- `500 Internal Server Error`: Server error
- `503 Service Unavailable`: Service temporarily unavailable

### Error Response Format

```json
{
  "detail": "Error message description"
}
```

Or for validation errors:
```json
{
  "detail": [
    {
      "loc": ["body", "quantity"],
      "msg": "value is not a valid decimal",
      "type": "type_error.decimal"
    }
  ]
}
```

### Mobile App Error Handling

- **401 Errors**: Automatically triggers logout and redirects to login
- **Network Errors**: Displays retry button
- **Validation Errors**: Shows inline error messages below form fields
- **Server Errors**: Displays user-friendly error message with retry option

---

## Query Parameters Summary

### Common Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `location_id` | integer | No | Filter by location |
| `kind` | string | No | Filter by item kind (enum) |
| `search` | string | No | Search by name or SKU |
| `skip` | integer | No | Pagination offset (default: 0) |
| `limit` | integer | No | Items per page (default: 10) |
| `page` | integer | No | Page number (alternative to skip) |
| `page_size` | integer | No | Items per page (alternative to limit) |
| `is_active` | boolean | No | Filter by active status (locations) |
| `is_read` | boolean | No | Filter by read status (alerts) |

### Search Behavior

- Search is case-insensitive
- Searches across item name and SKU
- Mobile app implements 500ms debounce to reduce API calls
- Empty search string should return all items (no filter applied)

### Pagination

- Default page size: 10 items
- Mobile app supports infinite scroll/pagination
- Total count is required in pagination response for UI display

---

## Request/Response Examples

### Example 1: Get Inventory Overview with Filters

**Request:**
```
GET /inventory/overview?location_id=1&kind=FINISHED_PRODUCT&search=product&page=1&page_size=20
Authorization: Bearer <token>
```

**Response:**
```json
{
  "kpis": {
    "total_items": 150,
    "total_skus": 75,
    "total_quantity_all_locations": "5000.50",
    "low_stock_items": 5,
    "out_of_stock_items": 2
  },
  "items": [
    {
      "id": 1,
      "name": "Product A",
      "sku": "SKU-001",
      "unit": "kg",
      "kind": "FINISHED_PRODUCT",
      "total_quantity": "100.50"
    }
  ],
  "page": {
    "skip": 0,
    "limit": 20,
    "total": 150
  }
}
```

### Example 2: Create Stock Movement (Stock-Out)

**Request:**
```
POST /inventory/adjust
Authorization: Bearer <token>
Content-Type: application/json

{
  "item_id": 1,
  "location_id": 1,
  "quantity": "-10.50",
  "type": "ADJUST",
  "reason": "SALE",
  "reference": "SALE-12345",
  "note": "Customer sale"
}
```

**Response:**
```json
{
  "id": 1,
  "item_id": 1,
  "location_id": 1,
  "quantity": "-10.50",
  "type": "ADJUST",
  "reason": "SALE",
  "reference": "SALE-12345",
  "note": "Customer sale",
  "created_at": "2024-01-01T12:00:00Z",
  "created_by_id": 1
}
```

### Example 3: Create Stock Transfer

**Request:**
```
POST /inventory/transfer
Authorization: Bearer <token>
Content-Type: application/json

{
  "item_id": 1,
  "from_location_id": 1,
  "to_location_id": 2,
  "quantity": "25.50",
  "note": "Transfer to store for sale"
}
```

**Response:**
```json
{
  "id": 1,
  "item_id": 1,
  "item_name": "Product A",
  "from_location_id": 1,
  "from_location_name": "Warehouse A",
  "to_location_id": 2,
  "to_location_name": "Store B",
  "quantity": "25.50",
  "created_at": "2024-01-01T12:00:00Z",
  "created_by_id": 1
}
```

### Example 4: Cycle Count Adjustment

**Request:**
```
POST /inventory/cycle-count/adjust
Authorization: Bearer <token>
Content-Type: application/json

{
  "item_id": 1,
  "location_id": 1,
  "system_quantity": "50.25",
  "counted_quantity": "48.00",
  "note": "Physical count shows discrepancy"
}
```

**Response:**
```json
{
  "id": 1,
  "item_id": 1,
  "location_id": 1,
  "system_quantity": "50.25",
  "counted_quantity": "48.00",
  "variance": "-2.25",
  "created_at": "2024-01-01T12:00:00Z",
  "created_by_id": 1
}
```

---

## Important Notes for Backend Developer

### 1. Decimal Handling
- All quantity fields are sent/received as **strings** (not numbers)
- Format: Decimal numbers as strings (e.g., `"10.50"`, `"0.25"`)
- Reason: Prevents floating-point precision issues
- Backend should parse these strings to decimal/numeric types

### 2. Stock Movement Quantity Sign
- **Positive quantity**: Stock-in (adds to inventory)
- **Negative quantity**: Stock-out (removes from inventory)
- Mobile app validates: Stock-out quantity cannot exceed available stock

### 3. Stock Transfer Behavior
- Mobile app expects backend to create **two movements**:
  1. OUT movement from source location
  2. IN movement to destination location
- Both movements should be linked to the same transfer record

### 4. Cycle Count Variance
- Mobile app calculates variance: `counted_quantity - system_quantity`
- Backend should also calculate and return variance in response
- Positive variance = gain (counted more than system)
- Negative variance = loss (counted less than system)

### 5. Pagination
- Mobile app uses both `skip/limit` and `page/page_size` patterns
- Backend should support both for flexibility
- Always return total count for UI pagination controls

### 6. Search Functionality
- Search should be case-insensitive
- Should search across: item name, SKU
- Empty search should return all items (no filter)

### 7. Filtering
- Multiple filters can be combined (AND logic)
- Filters are optional - if not provided, return all matching items
- `is_active=true` is default for location filtering

### 8. Authentication
- All endpoints require Bearer token authentication
- 401 responses trigger automatic logout in mobile app
- Token should be validated on every request

### 9. Error Messages
- Error messages should be user-friendly
- Validation errors should specify which field failed
- Network/server errors should provide actionable information

### 10. Response Consistency
- All list endpoints should return pagination object
- All creation endpoints should return created object with ID
- Timestamps should be in ISO 8601 format
- Nullable fields should be `null` (not omitted) when empty

---

## Testing Recommendations

### Test Scenarios for Backend

1. **Stock Movement Validation**
   - Test stock-out with quantity exceeding available stock (should fail)
   - Test stock-in with positive quantity (should succeed)
   - Test with invalid item_id or location_id (should return 404)

2. **Stock Transfer Validation**
   - Test transfer with same from/to location (should fail in mobile, backend should also validate)
   - Test transfer with quantity exceeding available stock (should fail)
   - Test transfer with valid data (should create two movements)

3. **Cycle Count**
   - Test with counted quantity > system quantity (positive variance)
   - Test with counted quantity < system quantity (negative variance)
   - Test with counted quantity = system quantity (zero variance)

4. **Pagination**
   - Test with various page sizes
   - Test with skip/limit parameters
   - Verify total count accuracy

5. **Search and Filters**
   - Test search with partial matches
   - Test multiple filter combinations
   - Test empty search (should return all)

6. **Authentication**
   - Test all endpoints without token (should return 401)
   - Test with expired token (should return 401)
   - Test with invalid token (should return 401)

---

## Contact & Support

For questions or clarifications about the mobile app's API requirements, please refer to:
- Implementation Plan: `IMPLEMENTATION_PLAN.md`
- Source Code: `lib/features/inventory/data/inventory_api.dart`
- Repository Layer: `lib/features/inventory/data/inventory_repository.dart`

---

**Document Version:** 1.0  
**Last Updated:** Phase 9 Complete  
**Mobile App Version:** 0.1.0

