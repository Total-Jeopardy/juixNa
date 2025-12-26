# JuixNa - Inventory Management System

A modern Flutter application for inventory management, built with clean architecture principles and Riverpod for state management.

## 📋 Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Setup Instructions](#setup-instructions)
- [API Configuration](#api-configuration)
- [Build Instructions](#build-instructions)
- [Project Structure](#project-structure)
- [Testing](#testing)
- [Environment Variables](#environment-variables)

## ✨ Features

### Authentication
- Secure login with email/password
- Token-based authentication
- Automatic token refresh and logout on 401 errors

### Inventory Management
- **Overview Dashboard**: View inventory items, KPIs, and filter by location/kind
- **Stock Movement**: Adjust stock in/out with reason tracking
- **Stock Transfer**: Transfer items between locations
- **Cycle Count**: Perform inventory counts and adjust discrepancies
- **Reorder Alerts**: Monitor low stock items and alerts
- **Transfer History**: View complete transfer history with filtering

### User Experience
- Pull-to-refresh on all list screens
- Inline form validation with error messages
- Double-submit prevention
- Debounced search (500ms)
- Loading states and error handling
- Consistent error display using `ErrorDisplay` utility

## 🏗️ Architecture

This project follows **MVVM (Model-View-ViewModel)** architecture with clean separation of concerns:

```
lib/
├── app/                    # App-level configuration
│   ├── router.dart        # Navigation setup with go_router
│   └── theme.dart         # App theming
├── core/                   # Core utilities and infrastructure
│   ├── auth/              # Authentication utilities
│   ├── network/           # API client and result types
│   ├── utils/             # Shared utilities (error display, formatters)
│   └── widgets/           # Reusable widgets
├── features/              # Feature modules
│   ├── auth/              # Authentication feature
│   │   ├── data/          # API and repository
│   │   ├── model/         # Domain models and DTOs
│   │   ├── view/          # UI screens
│   │   └── viewmodel/     # State management
│   └── inventory/         # Inventory feature
│       ├── data/          # API and repository
│       ├── model/         # Domain models and DTOs
│       ├── view/          # UI screens and widgets
│       └── viewmodel/     # State management
└── bootstrap.dart         # App initialization
```

### Key Architectural Patterns

- **State Management**: Riverpod with `AsyncNotifier` for async state
- **Navigation**: `go_router` with route guards and redirects
- **API Layer**: Repository pattern with DTO-to-domain model transformation
- **Error Handling**: Centralized error display and authentication error handling
- **Dependency Injection**: Riverpod providers for all dependencies

## 🚀 Setup Instructions

### Prerequisites

- Flutter SDK (3.10.1 or higher)
- Dart SDK (3.10.1 or higher)
- Android Studio / VS Code with Flutter extensions
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd juixNa
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 🔧 API Configuration

The app connects to a FastAPI backend. Configuration is managed in `lib/core/config/app_config.dart`.

### Available Environments

- **Production** (default): `https://juixna-api.onrender.com`
- **Development**: `http://127.0.0.1:8000`
- **Staging**: `https://juixna-api-staging.onrender.com`

### Setting Environment

The app uses compile-time constants to determine the environment:

```bash
# Development
flutter run --dart-define=ENV=dev

# Staging
flutter run --dart-define=ENV=staging

# Production (default)
flutter run
```

### API Endpoints

The app uses the following main endpoints:

- `POST /auth/login` - User authentication
- `GET /inventory/locations` - Get locations
- `GET /inventory/overview` - Get inventory overview
- `POST /inventory/adjust` - Create stock movement
- `POST /inventory/transfer` - Create stock transfer
- `GET /inventory/transfers` - Get transfer history
- `POST /inventory/cycle-count/adjust` - Adjust stock from cycle count

## 📦 Build Instructions

### Android

```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release
```

### iOS

```bash
# Debug build
flutter build ios --debug

# Release build
flutter build ios --release
```

### Web

```bash
flutter build web
```

## 📁 Project Structure

### Core Modules

- **`core/auth/`**: Authentication error handling and guards
- **`core/network/`**: API client with error handling and token management
- **`core/utils/`**: Shared utilities (error display, formatters, logger)
- **`core/widgets/`**: Reusable UI components

### Feature Modules

Each feature follows the same structure:

- **`data/`**: API clients and repositories (data layer)
- **`model/`**: Domain models and DTOs
- **`view/`**: UI screens and widgets
- **`viewmodel/`**: State management with Riverpod

## 🧪 Testing

The project includes comprehensive test coverage:

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/features/inventory/viewmodel/inventory_overview_vm_test.dart

# Run integration tests
flutter test integration_test/app_test.dart
```

### Test Structure

- **Unit Tests** (88 tests): Models, state classes, repositories, ViewModels
- **Integration Tests** (3 tests): Login flow, inventory loading flow
- **UI Tests** (8 tests): Screen rendering, form interactions, navigation

### Test Coverage

- ✅ Model serialization/deserialization
- ✅ State management and validation logic
- ✅ Repository data transformation
- ✅ ViewModel error handling and state updates
- ✅ Full user flows (login, inventory loading)
- ✅ UI rendering and interactions

## 🔐 Environment Variables

The app uses compile-time constants for configuration. No `.env` file is required.

### Available Constants

- `ENV`: Environment name (`dev`, `staging`, `prod`)
  - Set via: `--dart-define=ENV=dev`

### Test Accounts

For development and testing, the following test accounts are available (defined in `lib/core/config/app_config.dart`):

- **Admin**: `admin@example.com` / `secret123`
- **Manager**: `manager@example.com` / `secret123`
- **Staff**: `staff@example.com` / `secret123`

## 🛠️ Development

### Code Style

The project uses `dart format` for consistent code style:

```bash
# Format all files
dart format lib test integration_test
```

### Linting

The project uses `flutter_lints` for code quality:

```bash
# Analyze code
flutter analyze
```

### Adding New Features

1. Create feature directory under `lib/features/`
2. Follow the structure: `data/`, `model/`, `view/`, `viewmodel/`
3. Add routes in `lib/app/router.dart`
4. Create corresponding tests
5. Update this README if needed

## 📝 License

[Add your license information here]

## 🤝 Contributing

[Add contribution guidelines here]

## 📞 Support

[Add support contact information here]
