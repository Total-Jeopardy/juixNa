# Core Widgets Library

Reusable UI components used across the JuixNa app. All widgets follow the app's design system and support dark mode.

## Design Principles

- **Consistency**: All widgets use `AppColors`, consistent border radius values, and typography
- **Customizable**: Widgets accept optional parameters for colors, sizes, and behaviors
- **Dark Mode**: All widgets automatically adapt to light/dark theme
- **Reusable**: Widgets are generic and can be configured for different use cases

## Available Widgets

### 1. KPICard
**File:** `kpi_card.dart`

Displays a key performance indicator with optional trend indicator, icon, and tap action.

**Use Cases:**
- Dashboard KPI cards (Total Sales, Total Expenses, Total Profit)
- Statistics display with trend indicators
- Metric cards with icons

**Example:**
```dart
KPICard(
  title: 'Total Sales',
  value: '\$12,450',
  suffix: '+15% vs last week',
  showTrendUp: true,
  icon: Icons.monetization_on_rounded,
  onTap: () => navigateToSalesReport(),
)
```

### 2. ActionCard
**File:** `action_card.dart`

Displays an action item with icon, title, subtitle, and optional badge/trailing widget.

**Use Cases:**
- Quick Actions section (Inventory, Sales, Production, Reports)
- Menu items with icons
- Navigation cards

**Example:**
```dart
ActionCard(
  icon: Icons.inventory_2_rounded,
  title: 'Inventory',
  subtitle: 'View & manage stock levels',
  iconColor: AppColors.mango,
  badge: NotificationDot(),
  onTap: () => navigateToInventory(),
)
```

### 3. PillButton
**File:** `pill_button.dart`

Rounded pill-shaped button with selected/unselected states.

**Use Cases:**
- Period selectors (Today, Week, Month)
- Filter buttons
- Tab navigation
- Category selectors

**Example:**
```dart
PillButton(
  label: 'This Week',
  isSelected: selectedPeriod == PeriodFilter.week,
  onTap: () => setPeriod(PeriodFilter.week),
  trailing: Icon(Icons.keyboard_arrow_down_rounded),
)
```

### 4. StatusChip
**File:** `status_chip.dart`

Displays status information with icon, text, and optional timestamp.

**Use Cases:**
- Online/Offline indicators
- Sync status
- Connection status
- Last updated timestamps

**Factory Constructors:**
- `StatusChip.online(timestamp: '2m ago')`
- `StatusChip.offline(timestamp: 'Last updated 10:30 AM')`
- `StatusChip.updating()`

**Example:**
```dart
StatusChip.online(timestamp: 'Last updated 2m ago')
```

### 5. SelectorButton
**File:** `selector_button.dart`

Button that opens a picker/modal (e.g., location, date, filter).

**Use Cases:**
- Location selectors
- Date pickers
- Filter dropdowns
- Category selectors

**Example:**
```dart
SelectorButton(
  label: 'All Locations',
  leadingIcon: Icons.store_rounded,
  onTap: () => showLocationPicker(),
)
```

### 6. InfoBadge
**File:** `info_badge.dart`

Small badge for counts, tags, status indicators.

**Use Cases:**
- Notification counts
- "Coming Soon" tags
- "NO ACCESS" badges
- Status indicators

**Factory Constructors:**
- `InfoBadge.notification(count: 5)`
- `InfoBadge.comingSoon()`
- `InfoBadge.soon()`
- `InfoBadge.noAccess()`

**Example:**
```dart
InfoBadge.notification(count: 3)
InfoBadge.comingSoon()
```

### 7. AppCard
**File:** `app_card.dart`

Base card container with consistent styling.

**Use Cases:**
- Container for grouped content
- Card layouts
- Tappable cards

**Example:**
```dart
AppCard(
  child: Column(
    children: [
      Text('Card Content'),
    ],
  ),
  onTap: () => handleCardTap(),
)
```

### 8. StatChip
**File:** `stat_chip.dart`

Displays a statistic with title and value (enhanced version of inventory StatChip).

**Use Cases:**
- Statistics display
- KPI chips
- Metric chips

**Note:** This is a shared version. The inventory module has its own StatChip that can be migrated to use this one.

**Example:**
```dart
StatChip(
  title: 'CURRENT STOCK',
  value: '1,240',
  suffix: 'units',
)
```

## Usage Pattern

```dart
import 'package:juix_na/core/widgets/index.dart';

// Use widgets directly
KPICard(
  title: 'Total Sales',
  value: '\$12,450',
  showTrendUp: true,
)

// Or import specific widgets
import 'package:juix_na/core/widgets/kpi_card.dart';
```

## Color System

All widgets use `AppColors` from `lib/app/app_colors.dart`:
- Primary: `AppColors.mango` (orange)
- Secondary: `AppColors.deepGreen`
- Backgrounds: `AppColors.surface`, `AppColors.background`
- Dark mode: `AppColors.darkCard`, `AppColors.darkTextPrimary`, etc.

## Border Radius Values

- **12px**: Small cards, action items
- **16px**: Buttons, selectors, chips
- **18px**: Standard cards
- **20px**: Pill buttons, larger cards
- **24px**: Input fields, large cards
- **40px**: Stat chips
- **999px**: Fully rounded pills

## Dark Mode Support

All widgets automatically detect dark mode using:
```dart
final isDark = Theme.of(context).brightness == Brightness.dark;
```

Widgets adapt colors, borders, and shadows based on the theme.

## Customization

Most widgets accept optional parameters for:
- Colors (backgroundColor, textColor, borderColor, etc.)
- Sizes (fontSize, padding, borderRadius, iconSize, etc.)
- Behaviors (onTap, badges, trailing widgets, etc.)

If a parameter is not provided, widgets use sensible defaults based on the current theme.

## Best Practices

1. **Reuse widgets** instead of creating new ones
2. **Use factory constructors** when available (e.g., `StatusChip.online()`)
3. **Customize with parameters** rather than creating wrapper widgets
4. **Follow the design system** - use AppColors and standard border radius values
5. **Test in both themes** - ensure widgets work in light and dark modes

## Migration Notes

- The `StatChip` in `lib/features/inventory/widgets/` can be migrated to use the core version
- Inventory screens can gradually adopt core widgets for consistency
- New features should use core widgets from the start

