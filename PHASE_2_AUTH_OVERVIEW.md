# Phase 2: Authentication Module - Overview & Plan

## 🎯 What We're Building

Phase 2 implements a complete authentication system that:
1. **Authenticates users** via the backend API
2. **Manages user session** (login, logout, token storage)
3. **Protects routes** (redirects unauthenticated users to login)
4. **Provides auth state** throughout the app (who's logged in, are they authenticated)

---

## 🏗️ Architecture Overview

Following the **MVVM + Riverpod** pattern established in Phase 1:

```
┌─────────────────────────────────────────────────────────┐
│                    UI Layer (View)                       │
│  ┌──────────────────────────────────────────────────┐  │
│  │  LoginScreen                                      │  │
│  │  - Email/Password input                          │  │
│  │  - Login button                                  │  │
│  │  - Error display                                 │  │
│  │  - Loading states                                │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                        ↕ (ref.watch/ref.read)
┌─────────────────────────────────────────────────────────┐
│              State Management (ViewModel)                │
│  ┌──────────────────────────────────────────────────┐  │
│  │  AuthViewModel (AsyncNotifier)                   │  │
│  │  - login(email, password)                        │  │
│  │  - logout()                                      │  │
│  │  - checkAuthStatus()                             │  │
│  │  - State: loading, authenticated, error          │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                        ↕ (calls)
┌─────────────────────────────────────────────────────────┐
│              Business Logic (Repository)                 │
│  ┌──────────────────────────────────────────────────┐  │
│  │  AuthRepository                                  │  │
│  │  - Wraps AuthApi calls                           │  │
│  │  - Handles token storage                        │  │
│  │  - Transforms DTOs → Models                     │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                        ↕ (uses)
┌─────────────────────────────────────────────────────────┐
│              Data Layer (API)                            │
│  ┌──────────────────────────────────────────────────┐  │
│  │  AuthApi                                         │  │
│  │  - POST /api/auth/login                          │  │
│  │  - Uses ApiClient (already set up)              │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                        ↕ (stores)
┌─────────────────────────────────────────────────────────┐
│              Storage (TokenStore)                       │
│  ┌──────────────────────────────────────────────────┐  │
│  │  TokenStore (already exists)                     │  │
│  │  - saveAccessToken(token)                        │  │
│  │  - getAccessToken()                              │  │
│  │  - clear()                                       │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

---

## 📋 What We'll Build (4 Sub-Phases)

### **2.1 Auth Data Layer** 📡
**Purpose:** Connect to backend API and handle data transformation

**Files to create/implement:**
- `lib/features/auth/data/auth_api.dart`
  - `login(String email, String password)` → calls `POST /api/auth/login`
  - Returns `ApiResult<LoginResponseDTO>`
  
- `lib/features/auth/data/auth_repository.dart`
  - Wraps `AuthApi` calls
  - Saves token to `TokenStore` after successful login
  - Handles errors and transforms DTOs to domain models
  
- `lib/features/auth/model/auth_dtos.dart`
  - `LoginRequestDTO` (email, password)
  - `LoginResponseDTO` (access_token, user data, token_type, expires_in?)
  
- `lib/features/auth/model/user_models.dart`
  - `User` domain model:
    - `id: int`
    - `email: String`
    - `name: String`
    - `roles: List<String>` (e.g., ["manager", "staff", "admin"])
    - `permissions: List<String>` (e.g., ["inventory.view", "sales.create", "finance.costs.view"])
  - Helper methods: 
    - `hasRole(String role)` → `bool`
    - `hasPermission(String permission)` → `bool`
    - `hasAnyRole(List<String> roles)` → `bool`
    - `hasAnyPermission(List<String> permissions)` → `bool`
  - Convert from DTO

**Backend Endpoint:**
```
POST /api/auth/login
Body: { "email": "user@example.com", "password": "password123" }
Response: { 
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

**Test Accounts:**
- Admin: `admin@example.com` / `secret123`
- Manager: `manager@example.com` / `secret123`
- Staff: `staff@example.com` / `secret123`

---

### **2.2 Auth State Management** 🧠
**Purpose:** Manage authentication state using Riverpod

**Files to create/implement:**
- `lib/features/auth/viewmodel/auth_state.dart`
  - `AuthState` sealed class:
    - `AuthState.initial()` - app just started, checking auth
    - `AuthState.authenticated(User user)` - user is logged in
    - `AuthState.unauthenticated()` - no user logged in
    - `AuthState.loading()` - login in progress
    - `AuthState.error(String message)` - login failed

- `lib/features/auth/viewmodel/auth_vm.dart`
  - `AuthViewModel` extends `AsyncNotifier<AuthState>`
  - Methods:
    - `login(String email, String password)` - calls repository, updates state
    - `logout()` - clears token, sets state to unauthenticated
    - `checkAuthStatus()` - checks if token exists, validates it
  - Provider: `authViewModelProvider`

**Additional Providers:**
- `currentUserProvider` - derived from auth state (User?)
- `isAuthenticatedProvider` - derived from auth state (bool)
- `userRolesProvider` - derived from current user (List<String>)
- `userPermissionsProvider` - derived from current user (List<String>)

---

### **2.3 Auth UI Integration** 🎨
**Purpose:** Connect LoginScreen to ViewModel and handle user interactions

**Files to update:**
- `lib/features/auth/view/screens/login_screen.dart`
  - Convert to `ConsumerWidget` (or `ConsumerStatefulWidget`)
  - Add email/password `TextEditingController`s
  - Watch `authViewModelProvider` for state
  - Call `ref.read(authViewModelProvider.notifier).login(...)` on submit
  - Show loading indicator when `state is AuthState.loading`
  - Show error message when `state is AuthState.error`
  - Navigate to dashboard/home on successful login
  - Add form validation (email format, password not empty)

**UI States to Handle:**
- ✅ Initial: Show login form
- ⏳ Loading: Disable button, show spinner
- ✅ Success: Navigate away
- ❌ Error: Show error message, keep form enabled

---

### **2.4 Auth Guards & Navigation** 🛡️
**Purpose:** Protect routes and handle app initialization

**What we'll implement:**

1. **Auth Guard Logic**
   - Check if user is authenticated before accessing protected routes
   - Redirect to login if not authenticated
   - (We'll use this when we add routing in Phase 6)

2. **App Initialization**
   - On app start, check if token exists
   - If token exists, validate it (or assume valid for now)
   - Set initial route based on auth status:
     - Authenticated → Dashboard/Home
     - Not authenticated → Login

3. **Logout Functionality**
   - Clear token from `TokenStore`
   - Update auth state to `unauthenticated`
   - Navigate to login screen

4. **Token Refresh** (if needed)
   - Handle 401 responses from API
   - Attempt token refresh
   - If refresh fails, logout user
   - (May be deferred if backend doesn't support refresh yet)

---

## 🔄 User Flow

### **Login Flow:**
```
1. User opens app
   ↓
2. App checks: Is token stored? → No
   ↓
3. Show LoginScreen
   ↓
4. User enters email/password, taps "Login"
   ↓
5. AuthViewModel.login() called
   ↓
6. AuthRepository.login() → AuthApi.login()
   ↓
7. API returns token + user data
   ↓
8. Repository saves token to TokenStore
   ↓
9. ViewModel updates state to AuthState.authenticated(user)
   ↓
10. LoginScreen detects authenticated state
   ↓
11. Navigate to Dashboard/Home
```

### **App Start Flow (with existing token):**
```
1. App starts
   ↓
2. AuthViewModel.checkAuthStatus() called
   ↓
3. TokenStore.getAccessToken() → returns token
   ↓
4. (Optional) Validate token with backend
   ↓
5. If valid: AuthState.authenticated(user)
   ↓
6. Navigate to Dashboard/Home
   ↓
7. If invalid/missing: AuthState.unauthenticated()
   ↓
8. Navigate to LoginScreen
```

### **Logout Flow:**
```
1. User taps "Logout" button
   ↓
2. AuthViewModel.logout() called
   ↓
3. TokenStore.clear() → removes token
   ↓
4. ViewModel updates state to AuthState.unauthenticated()
   ↓
5. Navigate to LoginScreen
```

---

## 🔑 Key Design Decisions

### **1. State Management Pattern**
- **Why AsyncNotifier?** 
  - Login is an async operation (API call)
  - AsyncNotifier handles loading/error states elegantly
  - Matches Riverpod 3.x best practices

### **2. Token Storage**
- **Why TokenStore?**
  - Already exists and works
  - Uses secure storage (encrypted on device)
  - Simple API (save, get, clear)

### **3. Auth State Design**
- **Why sealed class?**
  - Type-safe state representation
  - Exhaustive pattern matching
  - Clear state transitions

### **4. Repository Pattern**
- **Why separate Repository from API?**
  - Repository handles business logic (token storage)
  - API is just HTTP calls
  - Easier to test and mock
  - Can add caching/offline support later

---

## 📦 Dependencies We'll Use

✅ **Already Available:**
- `flutter_riverpod` - state management
- `http` - HTTP client (via ApiClient)
- `flutter_secure_storage` - token storage (via TokenStore)

❌ **No New Dependencies Needed!**

---

## 🧪 Testing Strategy

**What we'll test:**
1. ✅ Login with valid credentials → success
2. ✅ Login with invalid credentials → error shown
3. ✅ Login with network error → error shown
4. ✅ App start with existing token → auto-login
5. ✅ App start without token → show login
6. ✅ Logout → token cleared, navigate to login
7. ✅ Token injection in API calls (already works)

---

## 🚀 After Phase 2

Once Phase 2 is complete:
- ✅ Users can log in
- ✅ Auth state is available app-wide
- ✅ Protected routes can check auth status
- ✅ Token is automatically included in API calls
- ✅ Ready to build Inventory module (Phase 3) with auth-protected endpoints

---

## ⚠️ Important Notes

1. **Backend API Assumptions:**
   - Endpoint: `POST /api/auth/login`
   - Request: `{ "email": "...", "password": "..." }`
   - Response: `{ "access_token": "...", "user": {...} }`
   - **We'll need to verify actual API response format!**

2. **Token Validation:**
   - For v1, we'll assume token is valid if it exists
   - Can add token validation endpoint later if needed
   - 401 responses from API will trigger logout

3. **Navigation:**
   - We'll use simple `Navigator.pushReplacement` for now
   - Full routing (go_router) comes in Phase 6
   - Auth guards will be added when routing is implemented

4. **User Model & RBAC:**
   - Include: id, email, name, roles, permissions
   - Backend has RBAC with permission codes (e.g., `inventory.view`, `sales.create`)
   - Store roles/permissions in User model for UI conditional rendering
   - Backend handles permission enforcement; mobile app uses it for UX only

---

## 📝 Implementation Order

**Recommended sequence:**
1. **2.1 Data Layer** (API, DTOs, Repository) - Foundation
2. **2.2 State Management** (State, ViewModel) - Core logic
3. **2.3 UI Integration** (LoginScreen) - User-facing
4. **2.4 Auth Guards** (Navigation, initialization) - Polish

This order ensures each layer builds on the previous one.

---

## ✅ Success Criteria

Phase 2 is complete when:
- [ ] User can log in with email/password
- [ ] Token is saved and retrieved correctly
- [ ] Auth state is available throughout app
- [ ] Login screen shows loading/error states
- [ ] App initializes with correct route (login vs dashboard)
- [ ] Logout works correctly
- [ ] Token is included in all API requests (already works)

---

**Ready to start?** We'll begin with **Phase 2.1 (Auth Data Layer)** - building the API client, DTOs, and repository! 🚀

