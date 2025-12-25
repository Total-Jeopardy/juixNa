# Online-Only Architecture - Confirmation

## ✅ Current Status: Online-Only App

The JuixNa mobile app is designed and implemented as a **fully online application** with no offline storage or sync capabilities.

---

## 📦 Storage Analysis

### What We Store Locally
- **Auth Token Only** (`TokenStore` using `flutter_secure_storage`)
  - Purpose: Persist login session across app restarts
  - Why: Necessary for online apps to avoid re-login on every app launch
  - Scope: Only the JWT access token, no other data

### What We DON'T Store
- ❌ No local database (no SQLite, Hive, etc.)
- ❌ No offline data caching
- ❌ No sync queue for pending operations
- ❌ No local persistence of inventory/sales/production data
- ❌ No offline-first patterns

---

## 🔄 Data Flow

```
User Action → ViewModel → Repository → API Call → Backend
                                    ↓
                              Fresh Data → UI
```

**All data is fetched fresh from the API on each screen load.**

---

## 🎨 UI Updates for Online-Only

### Changes Made:

1. **StockMovementScreen**
   - ❌ Removed "Sync" button (was placeholder)
   - ❌ Removed "Pending Sync" / "Synced" status indicators
   - ✅ Kept "Online/Offline" status as connectivity indicator (informational only)
   - ✅ Shows warning only when offline (no internet connection)

2. **InventoryOverviewScreen**
   - ✅ Changed "Sync" button → "Refresh" button
   - ✅ Added TODO comment for future refresh implementation
   - ✅ Button ready to reload data from API when ViewModel is implemented

### UI Philosophy:
- **Online status**: Shown for user awareness (informational)
- **Offline warning**: Shown when no internet (user needs to connect)
- **No sync indicators**: Removed all "pending sync" / "synced" messaging
- **Refresh buttons**: Will reload data from API (not sync from local storage)

---

## 📋 Dependencies Check

### Current Dependencies:
```yaml
dependencies:
  flutter_riverpod: ^3.0.3      # State management (online)
  flutter_secure_storage: ^10.0.0  # Auth token only
  http: ^1.6.0                  # API calls (online)
  intl: ^0.19.0                 # Formatting (no storage)
```

### No Offline Packages:
- ❌ No `sqflite` (SQLite database)
- ❌ No `hive` (local database)
- ❌ No `shared_preferences` (beyond secure storage)
- ❌ No `drift` / `moor` (database ORMs)
- ❌ No offline sync libraries

---

## 🚀 Architecture Pattern

### Repository Pattern (Online-Only):
```dart
Repository → API Call → Backend
         ↓
    Fresh Data
```

**Not:**
```dart
Repository → Local Cache → API Call (if needed)
```

### State Management:
- Riverpod providers fetch data directly from API
- No local caching layer
- No offline queue
- All operations require internet connection

---

## ⚠️ User Experience Implications

### What Users Will Experience:

1. **Requires Internet Connection**
   - App cannot function without internet
   - All operations require API connectivity

2. **Real-Time Data**
   - Data is always fresh from backend
   - No stale cached data
   - Changes are immediately reflected

3. **No Offline Mode**
   - If internet is lost, app shows offline warning
   - Users cannot continue working offline
   - Must reconnect to use app

4. **Fast API Dependency**
   - App performance depends on API response times
   - Slow network = slow app experience

---

## 🔮 Future Considerations (If Needed)

If offline support is ever needed in the future, would require:
1. Add local database (sqflite/hive)
2. Implement sync queue for pending operations
3. Add conflict resolution logic
4. Add background sync service
5. Update all repositories to support offline mode

**For now: Online-only is the design decision and implementation matches this.**

---

## ✅ Verification Checklist

- [x] No offline storage packages in `pubspec.yaml`
- [x] Only `TokenStore` uses local storage (auth token only)
- [x] All repositories call API directly (no local caching)
- [x] UI elements updated to reflect online-only behavior
- [x] Removed "sync" / "pending sync" messaging
- [x] Changed "Sync" buttons to "Refresh" (for API reload)
- [x] Online/Offline status is informational only
- [x] No offline queue or sync mechanisms

---

**Status: ✅ Confirmed Online-Only Architecture**

