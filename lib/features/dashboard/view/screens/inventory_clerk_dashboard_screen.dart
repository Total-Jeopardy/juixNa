import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:juix_na/app/app_colors.dart';
import 'package:juix_na/core/auth/auth_error_handler.dart';
import 'package:juix_na/core/network/api_result.dart';
import 'package:juix_na/core/utils/error_display.dart';
import 'package:juix_na/core/widgets/bottom_nav_bar.dart';
import 'package:juix_na/core/widgets/error_overlay.dart';
import 'package:juix_na/features/dashboard/model/dashboard_models.dart';
import 'package:juix_na/features/dashboard/viewmodel/dashboard_vm.dart';
import 'package:juix_na/features/inventory/model/inventory_models.dart';
import 'package:juix_na/features/inventory/viewmodel/inventory_overview_vm.dart';

/// Inventory Clerk Dashboard Screen
///
/// Role-specific dashboard for Inventory Clerk role with limited access.
/// Structure based on design:
/// 1. AppBar (Inventory Clerk Dashboard title, "STOCK ACCESS ONLY" badge, refresh icon, notification bell, profile icon)
/// 2. Online Status Chip (green dot + "Online" + "Last updated Xm ago")
/// 3. Filter Chips Row (Location dropdown, Period selector: Today, Week, Month, Custom)
/// 4. KPI Cards Row (Low Stock, Out of Stock - role-specific metrics)
/// 5. Quick Actions Section (Inventory, Cycle Counts, Transfers, Sales NO ACCESS, Reports NO ACCESS)
/// 6. Stock Trend Section (bar chart placeholder with "No trend data yet")
/// 7. Priority Alerts Section (inventory-related alerts only with disclaimer)
/// 8. Info message about hidden features for role

class InventoryClerkDashboardScreen extends ConsumerStatefulWidget {
  const InventoryClerkDashboardScreen({super.key});

  @override
  ConsumerState<InventoryClerkDashboardScreen> createState() =>
      _InventoryClerkDashboardScreenState();
}

class _InventoryClerkDashboardScreenState
    extends ConsumerState<InventoryClerkDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load dashboard data when screen first appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = ref.read(dashboardProvider.notifier);
      viewModel.loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch ViewModel state to trigger data loading and react to state changes
    final dashboardState = ref.watch(dashboardProvider);

    // Get current route to determine active tab
    final currentLocation = GoRouterState.of(context).uri.path;
    final currentIndex = _getCurrentNavIndex(currentLocation);

    // Determine if we should show loading skeleton
    // Show skeleton if main loading is true, or if individual sections are loading with no data
    final state = dashboardState.value;
    final shouldShowSkeleton =
        dashboardState.isLoading ||
        (state != null &&
            state.isLoadingKPIs == true &&
            state.inventoryClerkKpis == null) ||
        (state != null &&
            state.isLoadingCharts == true &&
            state.productSalesChart.isEmpty &&
            state.salesTrendChart.isEmpty &&
            (state.inventoryValueChart == null ||
                state.inventoryValueChart!.isEmpty)) ||
        (state != null &&
            state.isLoadingAlerts == true &&
            state.alerts.isEmpty);

    // Determine if we should show empty state overlay
    // Show empty state when not loading and no data exists
    final shouldShowEmptyState =
        !shouldShowSkeleton &&
        state != null &&
        state.inventoryClerkKpis == null &&
        state.productSalesChart.isEmpty &&
        state.salesTrendChart.isEmpty &&
        (state.inventoryValueChart == null ||
            state.inventoryValueChart!.isEmpty) &&
        state.alerts.isEmpty;

    // Handle loading and error states gracefully
    if (shouldShowSkeleton) {
      return Scaffold(
        backgroundColor: const Color(0xFFFDF7EE), // Light cream background
        bottomNavigationBar: CustomBottomNavBar(currentIndex: currentIndex),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              final viewModel = ref.read(dashboardProvider.notifier);
              await viewModel.loadDashboardData();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Loading skeleton view
                  _LoadingView(),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Determine if we should show error overlay
    // Show error overlay when there's an error (AsyncError or state.error)
    String? errorMessage;
    String? lastSuccessfulUpdate;
    dashboardState.when(
      data: (state) {
        if (state.error != null && state.error!.isNotEmpty) {
          errorMessage = state.error;
          // Format last successful update time if available
          if (state.lastSyncTime != null) {
            final now = DateTime.now();
            final difference = now.difference(state.lastSyncTime!);
            if (difference.inMinutes < 1) {
              lastSuccessfulUpdate = 'Last successful update: just now';
            } else if (difference.inMinutes < 60) {
              lastSuccessfulUpdate =
                  'Last successful update: ${difference.inMinutes}m ago';
            } else if (difference.inHours < 24) {
              lastSuccessfulUpdate =
                  'Last successful update: ${difference.inHours}h ago';
            } else {
              lastSuccessfulUpdate =
                  'Last successful update: ${difference.inDays}d ago';
            }
          }
        }
      },
      error: (error, stackTrace) {
        errorMessage = error.toString();
      },
      loading: () {
        // Loading state handled above with early return
      },
    );

    final shouldShowErrorOverlay =
        !shouldShowSkeleton && errorMessage != null && errorMessage!.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7EE), // Light cream background
      bottomNavigationBar: CustomBottomNavBar(currentIndex: currentIndex),
      body: Stack(
        children: [
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                // Refresh dashboard data
                final viewModel = ref.read(dashboardProvider.notifier);
                await viewModel.loadDashboardData();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. AppBar (JuixNa branding, Dashboard title, STOCK ACCESS ONLY badge, notification, profile)
                    _AppBar(),

                    const SizedBox(height: 16),

                    // 2. Filter Chips Row (Location dropdown, Period selector)
                    _FilterChipsRow(),

                    const SizedBox(height: 16),

                    // 4. KPI Cards Row (Low Stock, Out of Stock - role-specific)
                    _KPICardsRow(),

                    const SizedBox(height: 20),

                    // 5. Quick Actions Section (Inventory, Cycle Counts, Transfers, Sales NO ACCESS, Reports NO ACCESS)
                    _QuickActionsSection(),

                    const SizedBox(height: 20),

                    // 6. Stock Trend Section (bar chart placeholder with empty state)
                    _StockTrendSection(),

                    const SizedBox(height: 20),

                    // 7. Priority Alerts Section (inventory-related alerts only)
                    _PriorityAlertsSection(),

                    const SizedBox(height: 20),

                    // 8. Info message about hidden features
                    _InfoMessage(),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          // Empty state overlay with blurred background
          if (shouldShowEmptyState) _EmptyStateOverlay(),
          // Error overlay with blurred background
          if (shouldShowErrorOverlay)
            ErrorOverlay(
              title: "Can't load dashboard right now",
              message:
                  "We're having trouble connecting. Check your internet connection and try again.",
              onRetry: () {
                final viewModel = ref.read(dashboardProvider.notifier);
                viewModel.loadDashboardData();
              },
              secondaryLabel: 'Open Inventory',
              onSecondary: () {
                context.go('/inventory');
              },
              lastUpdatedText: lastSuccessfulUpdate,
            ),
        ],
      ),
    );
  }

  /// Helper method to determine the current navigation bar index based on route
  int _getCurrentNavIndex(String location) {
    if (location == '/dashboard' || location.startsWith('/dashboard')) {
      return 0; // Home
    } else if (location == '/inventory' || location.startsWith('/inventory')) {
      return 1; // Stock
    } else if (location.startsWith('/alerts')) {
      return 3; // Alerts
    } else if (location.startsWith('/menu') ||
        location.startsWith('/settings')) {
      return 4; // Menu
    }
    return 0; // Default to Home
  }
}

// ============================================================================
// PLACEHOLDER COMPONENTS - To be implemented step by step
// ============================================================================

/// 1. AppBar Section
/// Contains: Top row (JuixNa logo/branding with ONLINE status, notification, profile),
///           Middle row (Dashboard title with STOCK ACCESS ONLY badge)
class _AppBar extends ConsumerWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFFDF7EE), // Light cream background
      ),
      child: Column(
        children: [
          // Top row: App branding (left) + User actions (right)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Logo + JuixNa text + ONLINE status
              Row(
                children: [
                  // Orange square icon with rounded corners and white icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.mango, // Orange background
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                    ),
                    child: const Icon(
                      Icons.local_drink, // Juice glass/cup icon
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'JuixNa',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepGreen,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // ONLINE status
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'ONLINE',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.success,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              // Right: Notification bell + Profile avatar (smaller icons)
              Row(
                children: [
                  // Notification Bell - White circular button with badge (smaller)
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _CircularIconButton(
                        icon: Icons.notifications_outlined,
                        iconColor: AppColors.deepGreen,
                        size: 36, // Smaller size
                        iconSize: 18, // Smaller icon
                        onPressed: () {
                          // Navigate to alerts/reorder alerts screen
                          context.push('/inventory/reorder-alerts');
                        },
                      ),
                      // Red notification badge
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8), // Keep spacing the same
                  // Profile Avatar (smaller)
                  GestureDetector(
                    onTap: () {
                      // Show "Coming soon" for profile screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Profile screen coming soon',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: AppColors.info,
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 18, // Smaller radius (was 20)
                      backgroundColor: const Color(0xFFD97706),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 20, // Smaller icon (was 24)
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Middle row: Dashboard title + subtitle with STOCK ACCESS ONLY badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepGreen,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 2), // Reduced spacing
              // Subtitle row with STOCK ACCESS ONLY badge on same line
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Inventory Clerk View',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  // STOCK ACCESS ONLY badge on same line as subtitle (more transparent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted.withOpacity(
                        0.5,
                      ), // More transparent
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.borderSubtle.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'STOCK ACCESS ONLY',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Circular icon button widget used for refresh and notification icons
class _CircularIconButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onPressed;
  final double size;
  final double iconSize;

  const _CircularIconButton({
    required this.icon,
    required this.iconColor,
    required this.onPressed,
    this.size = 40, // Default size
    this.iconSize = 20, // Default icon size
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: iconSize),
        ),
      ),
    );
  }
}

/// 2. Online Status Chip
/// Contains: Green dot, "Online" text, bullet point, "Last updated Xm ago"
class _OnlineStatusChip extends ConsumerWidget {
  const _OnlineStatusChip();

  /// Format time as relative string (e.g., "2m ago", "1h ago")
  String _formatTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return '2m ago'; // Default placeholder

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get lastSyncTime from dashboard state
    final dashboardState = ref.watch(dashboardProvider);
    final lastSyncTime = dashboardState.value?.lastSyncTime;
    final timeAgo = _formatTimeAgo(lastSyncTime);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white, // Very light, almost off-white background
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderSubtle, // Very subtle light grey border
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Green circular dot
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          // "Online" text in dark green
          Text(
            'Online',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.deepGreen,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 6),
          // Dark green bullet point (using explicit Unicode bullet)
          Text(
            '\u2022', // Unicode bullet character
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.deepGreen,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 6),
          // "Last updated Xm ago" text in dark green
          Text(
            'Last updated $timeAgo',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.deepGreen,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// 3. Filter Chips Row
/// Contains: Location dropdown ("All Locations"), Period selector buttons (Today, This Week, This Month, Custom Range)
class _FilterChipsRow extends ConsumerStatefulWidget {
  const _FilterChipsRow();

  @override
  ConsumerState<_FilterChipsRow> createState() => _FilterChipsRowState();
}

class _FilterChipsRowState extends ConsumerState<_FilterChipsRow> {
  // Cache locations to avoid refetching on every tap
  List<Location>? _cachedLocations;
  bool _isLoadingLocations = false;

  /// Get location name by ID from cache
  String? _getLocationName(int? locationId) {
    if (locationId == null || _cachedLocations == null) return null;
    try {
      return _cachedLocations!.firstWhere((l) => l.id == locationId).name;
    } catch (e) {
      return null;
    }
  }

  /// Load locations with caching, auth handling, and loading state
  Future<List<Location>?> _loadLocations(BuildContext context) async {
    // Return cached locations if available
    if (_cachedLocations != null) {
      return _cachedLocations;
    }

    // Show loading indicator
    setState(() {
      _isLoadingLocations = true;
    });

    try {
      final locationsResult = await ref
          .read(inventoryRepositoryProvider)
          .getLocations();

      if (!context.mounted) return null;

      // Handle 401 errors (auto-logout)
      // WidgetRef extends Ref, cast needed for type checker compatibility
      await AuthErrorHandler.handleUnauthorized(ref as Ref, locationsResult);

      if (locationsResult.isSuccess) {
        final locations = (locationsResult as ApiSuccess<List<Location>>).data;
        // Cache locations for future use
        setState(() {
          _cachedLocations = locations;
          _isLoadingLocations = false;
        });
        return locations;
      } else {
        // Show error
        final failure = locationsResult as ApiFailure<List<Location>>;
        if (context.mounted) {
          ErrorDisplay.showError(context, failure.error);
        }
        setState(() {
          _isLoadingLocations = false;
        });
        return null;
      }
    } catch (e) {
      setState(() {
        _isLoadingLocations = false;
      });
      if (context.mounted) {
        ErrorDisplay.showError(
          context,
          ApiError(
            type: ApiErrorType.unknown,
            message: 'Failed to load locations: ${e.toString()}',
          ),
        );
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Connect to dashboard ViewModel for period and location selection
    final dashboardState = ref.watch(dashboardProvider);
    final viewModel = ref.read(dashboardProvider.notifier);
    final currentPeriod =
        dashboardState.value?.selectedPeriod ?? PeriodFilter.week;
    final selectedLocationId = dashboardState.value?.selectedLocationId;
    final locationName = _getLocationName(selectedLocationId);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Location Selector Button - Pill-shaped, slightly longer
          _PeriodButton(
            label: selectedLocationId == null
                ? 'All Locations'
                : (locationName ?? 'Location'),
            isSelected: false,
            showIcon: true,
            icon: _isLoadingLocations ? Icons.hourglass_empty : Icons.store,
            onTap: () async {
              if (_isLoadingLocations)
                return; // Prevent multiple taps while loading

              // Load locations (uses cache if available)
              final locations = await _loadLocations(context);

              if (!context.mounted || locations == null) return;

              // Handle empty list
              if (locations.isEmpty) {
                ErrorDisplay.showError(
                  context,
                  ApiError(
                    type: ApiErrorType.notFound,
                    message: 'No locations available',
                  ),
                );
                return;
              }

              final currentSelected = selectedLocationId;

              // Show bottom sheet with location options
              final selected = await showModalBottomSheet<int?>(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          'Select Location',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.deepGreen,
                              ),
                        ),
                      ),
                      ListTile(
                        title: const Text('All Locations'),
                        leading: const Icon(Icons.store_outlined),
                        selected: currentSelected == null,
                        onTap: () => Navigator.pop(context, null),
                      ),
                      const Divider(),
                      if (locations.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              'No locations available',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                      else
                        ...locations.map(
                          (location) => ListTile(
                            title: Text(location.name),
                            leading: const Icon(Icons.store),
                            selected: currentSelected == location.id,
                            onTap: () => Navigator.pop(context, location.id),
                          ),
                        ),
                    ],
                  ),
                ),
              );

              if (selected != null && selected != currentSelected) {
                viewModel.setLocation(selected);
              } else if (selected == null && currentSelected != null) {
                viewModel.setLocation(null);
              }
            },
          ),
          const SizedBox(width: 8),
          // Period Selector Buttons - Pill-shaped
          _PeriodButton(
            label: 'Today',
            isSelected: currentPeriod == PeriodFilter.today,
            onTap: () => viewModel.setPeriod(PeriodFilter.today),
          ),
          const SizedBox(width: 6),
          _PeriodButton(
            label: 'This Week',
            isSelected: currentPeriod == PeriodFilter.week,
            onTap: () => viewModel.setPeriod(PeriodFilter.week),
          ),
          const SizedBox(width: 6),
          _PeriodButton(
            label: 'This Month',
            isSelected: currentPeriod == PeriodFilter.month,
            onTap: () => viewModel.setPeriod(PeriodFilter.month),
          ),
          const SizedBox(width: 6),
          _PeriodButton(
            label: 'Custom Range',
            isSelected: currentPeriod == PeriodFilter.custom,
            onTap: () async {
              // Show date range picker
              final DateTimeRange? picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange:
                    dashboardState.value?.startDate != null &&
                        dashboardState.value?.endDate != null
                    ? DateTimeRange(
                        start: dashboardState.value!.startDate!,
                        end: dashboardState.value!.endDate!,
                      )
                    : null,
              );
              if (picked != null) {
                viewModel.setCustomDateRange(picked.start, picked.end);
              }
            },
          ),
        ],
      ),
    );
  }
}

/// Period selector button - Pill-shaped
class _PeriodButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showIcon;
  final IconData? icon;

  const _PeriodButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.showIcon = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ), // Taller height
        decoration: BoxDecoration(
          color: isSelected ? AppColors.mango : Colors.white,
          borderRadius: BorderRadius.circular(20), // Pill shape
          border: isSelected
              ? null // No border when selected (orange background extends to edge)
              : Border.all(color: AppColors.borderSubtle, width: 1),
        ),
        child: IntrinsicWidth(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showIcon && icon != null) ...[
                Icon(icon, size: 16, color: AppColors.deepGreen),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.deepGreen, // Dark green text for both states
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              if (showIcon) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: AppColors.deepGreen,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 4. KPI Cards Row
/// Contains: Horizontally scrollable KPI cards (Low Stock, Out of Stock) - Inventory Clerk specific
class _KPICardsRow extends ConsumerWidget {
  const _KPICardsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get KPI data from dashboard state
    final dashboardState = ref.watch(dashboardProvider);
    final inventoryClerkKPIs = dashboardState.value?.inventoryClerkKpis;
    final isLoadingKPIs = dashboardState.value?.isLoadingKPIs ?? false;

    // Show loading indicator while KPIs are loading
    if (isLoadingKPIs && inventoryClerkKPIs == null) {
      return const SizedBox(
        height: 158,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Show "No data" state if KPIs are not available (null after loading)
    if (!isLoadingKPIs && inventoryClerkKPIs == null) {
      return SizedBox(
        height: 158,
        child: Center(
          child: Text(
            'No KPI data available',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    // Get Low Stock and Out of Stock counts (default to 0 if null)
    final lowStockCount = inventoryClerkKPIs?.lowStockCount ?? 0;
    final outOfStockCount = inventoryClerkKPIs?.outOfStockCount ?? 0;

    return SizedBox(
      height: 158, // Increased height to prevent overflow (was 148)
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Low Stock Card
            _InventoryClerkKPICard(
              title: 'Low Stock',
              value: lowStockCount.toString(),
              status: lowStockCount > 0 ? 'ACTION NEEDED' : 'ALL GOOD',
              statusColor: lowStockCount > 0
                  ? AppColors.error
                  : AppColors.success,
              icon: Icons.warning_amber_rounded,
              iconBackgroundColor: AppColors.error.withOpacity(0.15),
              iconColor: AppColors.error,
              leftBorderColor: AppColors.error, // Red border for Low Stock
              backgroundColor: Colors.white,
              onTap: () {
                context.go('/inventory/reorder-alerts');
              },
            ),
            const SizedBox(width: 12),
            // Out of Stock Card
            _InventoryClerkKPICard(
              title: 'Out of Stock',
              value: outOfStockCount.toString(),
              status: outOfStockCount > 0 ? 'ACTION NEEDED' : 'ALL GOOD',
              statusColor: outOfStockCount > 0
                  ? AppColors.error
                  : AppColors.success,
              icon: Icons.shopping_cart,
              iconBackgroundColor: AppColors.textSecondary.withOpacity(
                0.15,
              ), // Gray for Out of Stock
              iconColor: AppColors.textSecondary, // Gray icon for Out of Stock
              leftBorderColor: const Color(
                0xFF1E40AF,
              ), // Dark blue border for Out of Stock
              backgroundColor: Colors.white,
              onTap: () {
                context.go('/inventory/reorder-alerts');
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// KPI Card widget - Clean, reusable card matching design
class _KPICard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final IconData icon;
  final bool isGradient; // true for orange gradient, false for white
  final Color?
  backgroundColor; // Optional background color for non-gradient cards
  final VoidCallback onTap;

  const _KPICard({
    required this.title,
    required this.value,
    required this.trend,
    required this.icon,
    this.isGradient = false,
    this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 190, // Fixed width for all cards
        height: 148, // Fixed height for all cards
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: isGradient
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFFA51F), // Deep orange at top-left
                      Color(
                        0xFFFFB84D,
                      ), // Lighter orange at bottom-right (fades out)
                    ],
                  )
                : null,
            color: isGradient ? null : (backgroundColor ?? Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: isGradient
                ? null
                : Border.all(color: AppColors.borderSubtle, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Use min to prevent overflow
            children: [
              // Top row: Icon circle and arrow
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icon in light orange circle
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isGradient
                          ? Colors.white.withOpacity(0.25)
                          : AppColors.mango.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: isGradient ? Colors.white : AppColors.deepGreen,
                    ),
                  ),
                  // Arrow icon
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: isGradient ? Colors.white : AppColors.deepGreen,
                  ),
                ],
              ),
              const SizedBox(height: 10), // Reduced spacing
              // Title
              Text(
                title,
                style: TextStyle(
                  color: isGradient
                      ? Colors.white.withOpacity(0.9)
                      : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6), // Spacing between title and value
              // Value
              Text(
                value,
                style: TextStyle(
                  color: isGradient ? Colors.white : AppColors.deepGreen,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.0, // Tighter line height
                ),
              ),
              const Spacer(), // Push trend badge to bottom
              // Trend badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: isGradient
                      ? Colors.white.withOpacity(0.2)
                      : AppColors.mango.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 14,
                      color: isGradient ? Colors.white : AppColors.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trend,
                      style: TextStyle(
                        color: isGradient ? Colors.white : AppColors.error,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        height: 1.0, // Tighter line height
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Inventory Clerk KPI Card widget - Specialized for Low Stock and Out of Stock metrics
class _InventoryClerkKPICard extends StatelessWidget {
  final String title;
  final String value;
  final String status; // "ACTION NEEDED" or "ALL GOOD"
  final Color statusColor; // Red for action needed, green for all good
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;
  final Color
  leftBorderColor; // Colored left border (red for Low Stock, dark blue for Out of Stock)
  final Color backgroundColor;
  final VoidCallback onTap;

  const _InventoryClerkKPICard({
    required this.title,
    required this.value,
    required this.status,
    required this.statusColor,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.leftBorderColor,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 190, // Fixed width matching other KPI cards
          height: 158, // Increased height to prevent overflow (was 148)
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                // Colored left border (thick, curved)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: leftBorderColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                  ),
                ),
                // Large background icon (faint, positioned top-right)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(
                    icon,
                    size: 70,
                    color: iconColor.withOpacity(
                      0.15,
                    ), // More visible background icon
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: Icon circle
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: iconBackgroundColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, size: 20, color: iconColor),
                      ),
                      const SizedBox(height: 10),
                      // Title
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Value (large, bold)
                      Text(
                        value,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: AppColors.deepGreen,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              height: 1.0,
                            ),
                      ),
                      const Spacer(), // Push status badge to bottom
                      // Status badge at bottom
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              status == 'ACTION NEEDED'
                                  ? Icons.error_outline
                                  : Icons.check_circle_outline,
                              size: 14,
                              color: statusColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              status,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 5. Quick Actions Section
/// Contains: Heading "Quick Actions" + 3-2 grid of action cards
class _QuickActionsSection extends ConsumerWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.deepGreen,
                fontSize: 18,
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 12),
                height: 1,
                color: AppColors.borderSubtle, // Horizontal line
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Grid of Quick Action Cards (1-2-2 layout)
        Column(
          children: [
            // First row: Inventory (full width, horizontal layout)
            _QuickActionCard(
              icon: Icons.inventory_2,
              title: 'Inventory',
              subtitle: 'View & manage stock levels',
              backgroundColor: const Color(0xFFFFE5D6), // Light peach
              iconBackgroundColor: const Color(0xFFFFD4B3), // Orange circle
              iconColor: Colors.white, // White icon
              iconShape: BoxShape.circle, // Circular for Inventory
              titleColor: AppColors.deepGreen,
              isFullWidth: true, // Full width horizontal layout
              onTap: () {
                context.go('/inventory');
              },
            ),
            const SizedBox(height: 12),
            // Second row: Cycle Counts and Transfers (side by side)
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.assignment,
                    title: 'Cycle Counts',
                    subtitle: 'Audit stocks',
                    backgroundColor: Colors.white,
                    iconBackgroundColor:
                        AppColors.deepGreen, // Dark green square
                    iconColor: Colors.white, // White icon
                    iconShape: BoxShape.rectangle, // Square for Cycle Counts
                    iconSize: 24, // Smaller icon size
                    titleColor: AppColors.deepGreen,
                    onTap: () {
                      context.push('/inventory/cycle-count');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.local_shipping,
                    title: 'Transfers',
                    subtitle: 'Move stock',
                    backgroundColor: Colors.white,
                    iconBackgroundColor:
                        AppColors.deepGreen, // Dark green square
                    iconColor: Colors.white, // White icon
                    iconShape: BoxShape.rectangle, // Square for Transfers
                    iconSize: 24, // Smaller icon size
                    titleColor: AppColors.deepGreen,
                    onTap: () {
                      context.push('/inventory/transfer');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Third row: Sales (NO ACCESS) and Reports (NO ACCESS) (side by side)
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.attach_money, // Dollar sign for Sales
                    title: 'Sales',
                    subtitle: 'Manage POS & Orders',
                    badge: 'NO ACCESS',
                    badgeIcon: Icons.lock_outline,
                    iconBackgroundColor: AppColors.surfaceMuted, // Light gray
                    iconColor: AppColors.textSecondary, // Gray icon
                    iconShape: BoxShape.rectangle,
                    titleColor: AppColors.textSecondary, // Gray title
                    isDisabled: true,
                    showLockIcon: true, // Lock icon in top-right
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Access denied: Sales module not available for your role',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: AppColors.info,
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.bar_chart,
                    title: 'Reports',
                    subtitle: 'Analytics & PDF',
                    badge: 'NO ACCESS',
                    badgeIcon: Icons.lock_outline,
                    iconBackgroundColor: AppColors.surfaceMuted, // Light gray
                    iconColor: AppColors.textSecondary, // Gray icon
                    iconShape: BoxShape.rectangle,
                    titleColor: AppColors.textSecondary, // Gray title
                    isDisabled: true,
                    showLockIcon: true, // Lock icon in top-right
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Access denied: Reports module not available for your role',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: AppColors.info,
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// Quick Action Card widget - Pixel perfect design matching specifications
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge; // "NO ACCESS", etc.
  final IconData? badgeIcon; // Lock icon for badge
  final Color? backgroundColor; // Light peach for active, white for disabled
  final Color?
  iconBackgroundColor; // Background for icon (orange circle, green square, or gray)
  final Color? iconColor; // Icon color (white for active, gray for disabled)
  final BoxShape iconShape; // Circle for Inventory, rectangle for others
  final Color? titleColor; // Dark green for active, gray for disabled
  final bool hasNotification; // Red notification dot in top-right
  final bool
  isDisabled; // If true, card is disabled (gray text, no interaction)
  final bool showLockIcon; // Show lock icon in top-right for disabled cards
  final bool isFullWidth; // If true, card is full width with horizontal layout
  final double
  iconSize; // Size of the icon (default 32, smaller for Cycle Counts/Transfers)
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badge,
    this.badgeIcon,
    this.backgroundColor,
    this.iconBackgroundColor,
    this.iconColor,
    this.iconShape = BoxShape.circle, // Default to circle
    this.titleColor,
    this.hasNotification = false,
    this.isDisabled = false,
    this.showLockIcon = false,
    this.isFullWidth = false,
    this.iconSize = 32, // Default icon size
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine colors based on state
    final bgColor = backgroundColor ?? Colors.white;
    final iconBg =
        iconBackgroundColor ??
        (isDisabled ? AppColors.surfaceMuted : const Color(0xFFFFD4B3));
    final icColor =
        iconColor ??
        (isDisabled ? AppColors.textSecondary : const Color(0xFFFFBD3B));
    final tColor = titleColor ?? AppColors.deepGreen;
    final subColor = AppColors.textSecondary;

    // Adjust icon container size based on icon size
    final iconContainerSize = iconSize + 24; // Add padding around icon

    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: isFullWidth
              ? const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ) // Reduced height for full width
              : const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: !isDisabled
                ? Border.all(color: AppColors.borderSubtle, width: 1)
                : null, // Border only for active cards
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowSoft,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              _buildCardContent(
                context,
                iconBg,
                icColor,
                tColor,
                subColor,
                iconShape,
                iconContainerSize,
              ),
              // Red notification dot or lock icon in top-right corner
              if (showLockIcon && isDisabled)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(
                    Icons.lock_outline,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                )
              else if (hasNotification && !isDisabled)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(
    BuildContext context,
    Color iconBg,
    Color icColor,
    Color tColor,
    Color subColor,
    BoxShape iconShape,
    double iconContainerSize,
  ) {
    // For full width cards, use horizontal layout
    if (isFullWidth) {
      return Row(
        children: [
          // Icon on left
          Container(
            width: iconContainerSize,
            height: iconContainerSize,
            decoration: BoxDecoration(
              color: iconBg,
              shape: iconShape,
              borderRadius: iconShape == BoxShape.rectangle
                  ? BorderRadius.circular(8)
                  : null,
            ),
            child: Icon(icon, size: iconSize, color: icColor),
          ),
          const SizedBox(width: 16),
          // Text content in middle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: tColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: subColor,
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Arrow icon on right
          Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.mango),
        ],
      );
    }

    // For regular cards, use vertical layout
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon in background (circle or square with rounded corners)
        Container(
          width: iconContainerSize,
          height: iconContainerSize,
          decoration: BoxDecoration(
            color: iconBg,
            shape: iconShape,
            borderRadius: iconShape == BoxShape.rectangle
                ? BorderRadius.circular(8) // Rounded corners for squares
                : null,
          ),
          child: Icon(icon, size: iconSize, color: icColor),
        ),
        // Badge positioned below icon (horizontally centered)
        if (badge != null) ...[
          const SizedBox(height: 8),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(
                  0.15,
                ), // Light gray for NO ACCESS
                borderRadius: BorderRadius.circular(12), // Pill-shaped
              ),
              child: Text(
                badge!,
                style: TextStyle(
                  color: AppColors.textSecondary, // Gray text for NO ACCESS
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  height: 1.0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ] else
          const SizedBox(height: 20),
        // Title
        Text(
          title,
          style: TextStyle(
            color: tColor,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        // Subtitle
        Text(
          subtitle,
          style: TextStyle(
            color: subColor,
            fontSize: 12,
            fontWeight: FontWeight.normal,
            height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// 6. Stock Trend Section
/// Contains: Stock Trend card with empty state placeholder
/// TODO: Bind to actual stock trend data based on period and location filters
class _StockTrendSection extends ConsumerWidget {
  const _StockTrendSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title on left, "Last 7 Days" on right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title on left
              Text(
                'Stock Trend',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepGreen,
                  fontSize: 16,
                ),
              ),
              // "Last 7 Days" on right in orange/golden-yellow
              Text(
                'Last 7 Days',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mango, // Light orange/golden-yellow
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Empty state: Placeholder box with dashed border and "No trend data yet" text
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted.withOpacity(
                0.3,
              ), // Lighter gray background
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.borderSubtle,
                width: 1.5,
                style: BorderStyle
                    .solid, // Solid border instead of dashed (Flutter limitation)
              ),
            ),
            child: Stack(
              children: [
                // Faint bar chart background design
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(7, (index) {
                        return Container(
                          width: 20,
                          height: (30 + (index * 8) + (index % 2 == 0 ? 15 : 0))
                              .toDouble(),
                          decoration: BoxDecoration(
                            color: AppColors.textSecondary.withOpacity(
                              0.08,
                            ), // Very faint gray
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                // Centered "No trend data yet" text
                Center(
                  child: Text(
                    'No trend data yet',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary, // Medium gray
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Sales Trend Card (with bar chart)
class _SalesTrendCard extends ConsumerWidget {
  const _SalesTrendCard();

  /// Generate dummy sales trend data for design preview
  List<SalesTrendPoint> _getDummyData() {
    final now = DateTime.now();
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      // Thursday (index 3) has the highest value to match design
      final amount = index == 3
          ? 850.0
          : (400.0 + (index * 50) + (index == 2 ? 200 : 0));
      return SalesTrendPoint(
        date: date,
        salesAmount: amount,
        quantity: amount / 10,
        dayLabel: days[index],
      );
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesTrendData = ref.watch(dashboardSalesTrendChartProvider);
    final isLoading =
        ref.watch(dashboardProvider).value?.isLoadingCharts ?? false;

    // Use dummy data if no real data is available (for design preview)
    final displayData = salesTrendData.isEmpty && !isLoading
        ? _getDummyData()
        : salesTrendData;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and View button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Orange vertical line indicator
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.mango,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sales Trend',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepGreen,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Last 7 days',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // View button
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.mango.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'View',
                  style: TextStyle(
                    color: AppColors.mango,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Bar chart
          if (isLoading)
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: CircularProgressIndicator()),
            )
          else
            SizedBox(
              height: 200,
              child: _SalesTrendBarChart(data: displayData),
            ),
        ],
      ),
    );
  }
}

/// Sales Trend Bar Chart Widget
class _SalesTrendBarChart extends StatelessWidget {
  final List<SalesTrendPoint> data;

  const _SalesTrendBarChart({required this.data});

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    // Find the maximum value for scaling and the highlighted bar (highest value)
    double maxValue = 0;
    int highlightedIndex = 0;
    for (int i = 0; i < data.length; i++) {
      if (data[i].salesAmount > maxValue) {
        maxValue = data[i].salesAmount;
        highlightedIndex = i;
      }
    }

    // Ensure maxValue is at least 100 to prevent division by zero
    maxValue = maxValue < 100 ? 100 : maxValue;

    const chartHeight = 200.0;

    return Stack(
      children: [
        // Bar chart
        SizedBox(
          height: chartHeight,
          child: Padding(
            padding: const EdgeInsets.only(top: 40, bottom: 0),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxValue * 1.15, // Add 15% padding at top
                minY: 0,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < data.length) {
                          return Text(
                            data[index].dayLabel,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 25,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(data.length, (index) {
                  final isHighlighted = index == highlightedIndex;
                  final barValue = data[index].salesAmount;
                  final barColor = isHighlighted
                      ? AppColors
                            .mango // Orange for highlighted bar
                      : const Color(
                          0xFFFFE5D6,
                        ).withOpacity(0.5); // Faded cream/orange for others

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: barValue,
                        color: barColor,
                        width: 32,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }),
              ),
              swapAnimationDuration: const Duration(milliseconds: 300),
              swapAnimationCurve: Curves.easeInOut,
            ),
          ),
        ),
        // Value label above highlighted bar
        Positioned(
          top: 8,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(data.length, (index) {
              if (index == highlightedIndex) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.deepGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _formatCurrency(data[index].salesAmount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }
              return const SizedBox(width: 24); // Match bar width
            }),
          ),
        ),
      ],
    );
  }
}

/// Top Products Card (with donut chart)
class _TopProductsCard extends ConsumerWidget {
  const _TopProductsCard();

  /// Generate dummy product sales data for design preview
  List<ProductSales> _getDummyData() {
    return [
      ProductSales(
        productId: 1,
        productName: 'Mango Magic',
        totalSales: 4500.0,
        quantitySold: 450.0,
        percentage: 45.0,
      ),
      ProductSales(
        productId: 2,
        productName: 'Green Detox',
        totalSales: 3000.0,
        quantitySold: 300.0,
        percentage: 30.0,
      ),
      ProductSales(
        productId: 3,
        productName: 'Others',
        totalSales: 2500.0,
        quantitySold: 250.0,
        percentage: 25.0,
      ),
    ];
  }

  /// Get color for product based on name
  Color _getProductColor(String productName) {
    if (productName.toLowerCase().contains('mango')) {
      return AppColors.mango; // Orange
    } else if (productName.toLowerCase().contains('green') ||
        productName.toLowerCase().contains('detox')) {
      return AppColors.success; // Green
    } else {
      return AppColors.textSecondary; // Light gray for "Others"
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productSalesData = ref.watch(dashboardProductSalesChartProvider);
    final isLoading =
        ref.watch(dashboardProvider).value?.isLoadingCharts ?? false;

    // Use dummy data if no real data is available (for design preview)
    final displayData = productSalesData.isEmpty && !isLoading
        ? _getDummyData()
        : productSalesData;

    // Take top 3 products (or use all if less than 3)
    final topProducts = displayData.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with green vertical bar
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.success, // Green vertical bar
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Top Products',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepGreen,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Content: Legend on left, Donut chart on right
          Row(
            children: [
              // Left: Product list with percentages
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: topProducts
                      .map(
                        (product) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _ProductItem(
                            name: product.productName,
                            percentage: '${product.percentage.toInt()}%',
                            color: _getProductColor(product.productName),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(width: 12),
              // Right: Donut chart (positioned up slightly to match design)
              Transform.translate(
                offset: const Offset(0, -17), // Move up 17 pixels
                child: SizedBox(
                  width: 120,
                  height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _TopProductsDonutChart(data: topProducts),
                      // Center text "Top 3"
                      Text(
                        'Top 3',
                        style: TextStyle(
                          color: AppColors.deepGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Product item in Top Products list
class _ProductItem extends StatelessWidget {
  final String name;
  final String percentage;
  final Color color;

  const _ProductItem({
    required this.name,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          '$name ($percentage)',
          style: TextStyle(
            color: AppColors.deepGreen,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Top Products Donut Chart Widget
class _TopProductsDonutChart extends StatelessWidget {
  final List<ProductSales> data;

  const _TopProductsDonutChart({required this.data});

  /// Get color for product based on name
  Color _getProductColor(String productName, int index) {
    if (productName.toLowerCase().contains('mango')) {
      return AppColors.mango; // Orange
    } else if (productName.toLowerCase().contains('green') ||
        productName.toLowerCase().contains('detox')) {
      return AppColors.success; // Green
    } else {
      return AppColors.textSecondary.withValues(
        alpha: 0.5,
      ); // Light gray for "Others"
    }
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceMuted,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            'No Data',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 1, // Very small gap between segments
        centerSpaceRadius: 40, // Larger hole = much thinner donut ring
        sections: List.generate(data.length, (index) {
          final product = data[index];
          return PieChartSectionData(
            value: product.percentage,
            color: _getProductColor(product.productName, index),
            radius: 12, // Smaller radius for compact chart
            title: '', // No labels on segments
            showTitle: false,
          );
        }),
      ),
      swapAnimationDuration: const Duration(milliseconds: 300),
      swapAnimationCurve: Curves.easeInOut,
    );
  }
}

/// 7. Priority Alerts Section
/// Contains: Heading "Priority Alerts" with badge + filtered inventory alerts + disclaimer
class _PriorityAlertsSection extends ConsumerWidget {
  const _PriorityAlertsSection();

  /// Format time as relative string (e.g., "2m ago", "1h ago")
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  /// Get icon, colors for alert based on type
  Map<String, dynamic> _getAlertStyle(AlertType type) {
    switch (type) {
      case AlertType.lowStock:
        return {
          'icon': Icons.checklist,
          'edgeColor': AppColors.error,
          'iconBackgroundColor': const Color(0xFFFFE5E5),
          'iconColor': AppColors.error,
        };
      case AlertType.paymentDue:
        return {
          'icon': Icons.description,
          'edgeColor': AppColors.warning,
          'iconBackgroundColor': const Color(0xFFFFF5E5),
          'iconColor': AppColors.warning,
        };
      case AlertType.upcomingBatch:
        return {
          'icon': Icons.calendar_today,
          'edgeColor': AppColors.info,
          'iconBackgroundColor': const Color(0xFFE5F0FF),
          'iconColor': AppColors.info,
        };
      case AlertType.promotionExpiry:
        return {
          'icon': Icons.local_offer,
          'edgeColor': AppColors.warning,
          'iconBackgroundColor': const Color(0xFFFFF5E5),
          'iconColor': AppColors.warning,
        };
    }
  }

  /// Navigate to relevant screen based on alert type
  void _handleAlertTap(BuildContext context, DashboardAlert alert) {
    switch (alert.type) {
      case AlertType.lowStock:
        // Navigate to inventory reorder alerts or item detail
        if (alert.itemId != null) {
          context.push('/inventory/reorder-alerts');
        } else {
          context.push('/inventory/reorder-alerts');
        }
        break;
      case AlertType.paymentDue:
        // TODO: Navigate to expense details when screen is available
        debugPrint('Navigate to payment due: ${alert.actionUrl}');
        break;
      case AlertType.upcomingBatch:
        // TODO: Navigate to batch details when screen is available
        debugPrint('Navigate to batch: ${alert.actionUrl}');
        break;
      case AlertType.promotionExpiry:
        // TODO: Navigate to promotions when screen is available
        debugPrint('Navigate to promotion: ${alert.actionUrl}');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get alerts from dashboard state
    final dashboardState = ref.watch(dashboardProvider);
    final viewModel = ref.read(dashboardProvider.notifier);
    final allAlerts = dashboardState.value?.alerts ?? [];

    // Filter alerts to show only inventory-related alerts (Low Stock and Upcoming Batch)
    final alerts = allAlerts
        .where(
          (alert) =>
              alert.type == AlertType.lowStock ||
              alert.type == AlertType.upcomingBatch,
        )
        .toList();

    final isLoadingAlerts = dashboardState.value?.isLoadingAlerts ?? false;
    final selectedLocationId = dashboardState.value?.selectedLocationId;
    final newAlertsCount = alerts.length; // Count of filtered alerts

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row with blue borders, orange icon, and "See all" link
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFDF7EE), // Light cream background
            border: Border(
              left: BorderSide(
                color: AppColors.info, // Blue vertical border on left
                width: 2,
              ),
              right: BorderSide(
                color: AppColors.info, // Blue vertical border on right
                width: 2,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Orange warning icon + "Alerts" text
              Row(
                children: [
                  // Orange warning icon (triangle with exclamation mark)
                  Icon(
                    Icons.warning,
                    color: AppColors.mango, // Orange color
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Priority Alerts',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.deepGreen, // Dark green text
                              fontSize: 16,
                            ),
                          ),
                          if (newAlertsCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.mango,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$newAlertsCount New',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              // Right: "See all" link in light orange
              TextButton(
                onPressed: () {
                  // Navigate to reorder alerts screen (main alerts screen)
                  context.push('/inventory/reorder-alerts');
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'See all',
                  style: TextStyle(
                    color: AppColors.mango, // Light orange/golden-yellow
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Alert cards list
        if (isLoadingAlerts && alerts.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (alerts.isEmpty)
          // Empty state
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 48,
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "You're all caught up",
                    style: TextStyle(
                      color: AppColors.deepGreen,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children: alerts.take(3).map((alert) {
              final style = _getAlertStyle(alert.type);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Dismissible(
                  key: Key('alert_${alert.id}'),
                  direction: DismissDirection.horizontal,
                  onDismissed: (direction) {
                    viewModel.dismissAlert(alert);
                  },
                  background: Container(
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 28,
                    ),
                  ),
                  child: _AlertCard(
                    icon: style['icon'] as IconData,
                    edgeColor: style['edgeColor'] as Color,
                    iconBackgroundColor: style['iconBackgroundColor'] as Color,
                    iconColor: style['iconColor'] as Color,
                    title: alert.title,
                    subtitle: alert.message,
                    timeAgo: _formatTimeAgo(alert.timestamp),
                    onTap: () => _handleAlertTap(context, alert),
                  ),
                ),
              );
            }).toList(),
          ),
        if (alerts.isNotEmpty) ...[
          const SizedBox(height: 12),
          // Swipe hint text
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.swipe, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                'SWIPE ON ALERT TO MARK READ',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
        // Disclaimer message for Inventory Clerk role
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Alerts shown are limited to inventory operations.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Loading Skeleton View
/// Displays skeleton placeholders matching the dashboard layout
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. AppBar skeleton (JuixNa branding, Dashboard title, STOCK ACCESS ONLY badge)
        _SkeletonAppBar(),

        const SizedBox(height: 16),

        // 2. "UPDATING..." chip skeleton
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderSubtle, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.deepGreen,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'UPDATING...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.deepGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 3. Filter chips skeleton
        _SkeletonFilterChips(),

        const SizedBox(height: 16),

        // 4. KPI cards skeleton (2 cards side by side)
        _SkeletonKPICards(),

        const SizedBox(height: 20),

        // 5. Quick Actions skeleton
        _SkeletonQuickActions(),

        const SizedBox(height: 20),

        // 6. Stock Trend skeleton
        _SkeletonStockTrend(),

        const SizedBox(height: 20),

        // 7. Alerts skeleton
        _SkeletonAlerts(),

        const SizedBox(height: 20),

        // 8. Info message skeleton
        _SkeletonInfoMessage(),

        const SizedBox(height: 40),
      ],
    );
  }
}

/// Reusable skeleton box component
class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double? borderRadius;
  final Color? color;

  const _SkeletonBox({
    required this.width,
    required this.height,
    this.borderRadius,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(borderRadius ?? 8),
      ),
    );
  }
}

/// AppBar skeleton
class _SkeletonAppBar extends StatelessWidget {
  const _SkeletonAppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(color: Color(0xFFFDF7EE)),
      child: Column(
        children: [
          // Top row: Logo + JuixNa text + ONLINE status (left), Notification + Profile (right)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _SkeletonBox(width: 40, height: 40, borderRadius: 8),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonBox(width: 80, height: 20, borderRadius: 4),
                      const SizedBox(height: 4),
                      _SkeletonBox(width: 60, height: 14, borderRadius: 4),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  _SkeletonBox(width: 40, height: 40, borderRadius: 20),
                  const SizedBox(width: 8),
                  _SkeletonBox(width: 40, height: 40, borderRadius: 20),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Middle row: Dashboard title + subtitle with STOCK ACCESS ONLY badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonBox(width: 120, height: 28, borderRadius: 4),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _SkeletonBox(width: 140, height: 14, borderRadius: 4),
                      const SizedBox(width: 8),
                      _SkeletonBox(width: 120, height: 24, borderRadius: 12),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Filter chips skeleton
class _SkeletonFilterChips extends StatelessWidget {
  const _SkeletonFilterChips();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _SkeletonBox(width: 120, height: 36, borderRadius: 20),
          const SizedBox(width: 8),
          _SkeletonBox(width: 70, height: 36, borderRadius: 20),
          const SizedBox(width: 6),
          _SkeletonBox(width: 90, height: 36, borderRadius: 20),
          const SizedBox(width: 6),
          _SkeletonBox(width: 100, height: 36, borderRadius: 20),
          const SizedBox(width: 6),
          _SkeletonBox(width: 110, height: 36, borderRadius: 20),
        ],
      ),
    );
  }
}

/// KPI cards skeleton
class _SkeletonKPICards extends StatelessWidget {
  const _SkeletonKPICards();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 158,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _SkeletonKPICard(),
            const SizedBox(width: 12),
            _SkeletonKPICard(),
          ],
        ),
      ),
    );
  }
}

/// Single KPI card skeleton
class _SkeletonKPICard extends StatelessWidget {
  const _SkeletonKPICard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      height: 158,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SkeletonBox(width: 36, height: 36, borderRadius: 18),
          const SizedBox(height: 10),
          _SkeletonBox(width: 80, height: 12, borderRadius: 4),
          const SizedBox(height: 6),
          _SkeletonBox(width: 60, height: 32, borderRadius: 4),
          const Spacer(),
          _SkeletonBox(width: 100, height: 24, borderRadius: 8),
        ],
      ),
    );
  }
}

/// Quick Actions skeleton
class _SkeletonQuickActions extends StatelessWidget {
  const _SkeletonQuickActions();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _SkeletonBox(width: 120, height: 20, borderRadius: 4),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 12),
                height: 1,
                color: AppColors.borderSubtle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Inventory full-width card skeleton
        Container(
          width: double.infinity,
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE5D6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSubtle, width: 1),
          ),
          child: Row(
            children: [
              _SkeletonBox(width: 56, height: 56, borderRadius: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SkeletonBox(width: 100, height: 18, borderRadius: 4),
                    const SizedBox(height: 4),
                    _SkeletonBox(width: 180, height: 14, borderRadius: 4),
                  ],
                ),
              ),
              _SkeletonBox(width: 16, height: 16, borderRadius: 4),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Cycle Counts and Transfers side by side
        Row(
          children: [
            Expanded(child: _SkeletonQuickActionCard()),
            const SizedBox(width: 12),
            Expanded(child: _SkeletonQuickActionCard()),
          ],
        ),
        const SizedBox(height: 12),
        // Sales and Reports disabled cards (gray skeletons)
        Row(
          children: [
            Expanded(child: _SkeletonDisabledQuickActionCard()),
            const SizedBox(width: 12),
            Expanded(child: _SkeletonDisabledQuickActionCard()),
          ],
        ),
      ],
    );
  }
}

/// Quick Action card skeleton (active)
class _SkeletonQuickActionCard extends StatelessWidget {
  const _SkeletonQuickActionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _SkeletonBox(width: 56, height: 56, borderRadius: 8),
          const SizedBox(height: 20),
          _SkeletonBox(width: 100, height: 18, borderRadius: 4),
          const SizedBox(height: 4),
          _SkeletonBox(width: 80, height: 14, borderRadius: 4),
        ],
      ),
    );
  }
}

/// Quick Action card skeleton (disabled - gray)
class _SkeletonDisabledQuickActionCard extends StatelessWidget {
  const _SkeletonDisabledQuickActionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              _SkeletonBox(
                width: 56,
                height: 56,
                borderRadius: 8,
                color: AppColors.textSecondary.withOpacity(0.2),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: _SkeletonBox(
                  width: 18,
                  height: 18,
                  borderRadius: 9,
                  color: AppColors.textSecondary.withOpacity(0.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: _SkeletonBox(
              width: 80,
              height: 24,
              borderRadius: 12,
              color: AppColors.textSecondary.withOpacity(0.15),
            ),
          ),
          const SizedBox(height: 8),
          _SkeletonBox(
            width: 60,
            height: 14,
            borderRadius: 4,
            color: AppColors.textSecondary.withOpacity(0.2),
          ),
          const SizedBox(height: 4),
          _SkeletonBox(
            width: 100,
            height: 12,
            borderRadius: 4,
            color: AppColors.textSecondary.withOpacity(0.2),
          ),
        ],
      ),
    );
  }
}

/// Stock Trend skeleton
class _SkeletonStockTrend extends StatelessWidget {
  const _SkeletonStockTrend();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SkeletonBox(width: 100, height: 20, borderRadius: 4),
              _SkeletonBox(width: 80, height: 14, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.borderSubtle,
                width: 1.5,
                style: BorderStyle.solid,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Alerts skeleton
class _SkeletonAlerts extends StatelessWidget {
  const _SkeletonAlerts();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with blue borders
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFDF7EE),
            border: Border(
              left: BorderSide(color: AppColors.info, width: 2),
              right: BorderSide(color: AppColors.info, width: 2),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _SkeletonBox(
                    width: 24,
                    height: 24,
                    borderRadius: 12,
                    color: AppColors.mango.withOpacity(0.3),
                  ),
                  const SizedBox(width: 8),
                  _SkeletonBox(width: 120, height: 18, borderRadius: 4),
                ],
              ),
              _SkeletonBox(width: 60, height: 14, borderRadius: 4),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Alert cards
        Column(
          children: [
            _SkeletonAlertCard(),
            const SizedBox(height: 12),
            _SkeletonAlertCard(),
          ],
        ),
      ],
    );
  }
}

/// Single alert card skeleton
class _SkeletonAlertCard extends StatelessWidget {
  const _SkeletonAlertCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowSoft,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left border stripe
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.3),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    _SkeletonBox(width: 44, height: 44, borderRadius: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SkeletonBox(width: 180, height: 16, borderRadius: 4),
                          const SizedBox(height: 4),
                          _SkeletonBox(width: 150, height: 14, borderRadius: 4),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _SkeletonBox(width: 50, height: 12, borderRadius: 4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Info message skeleton
class _SkeletonInfoMessage extends StatelessWidget {
  const _SkeletonInfoMessage();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _SkeletonBox(width: 24, height: 24, borderRadius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: _SkeletonBox(
              width: double.infinity,
              height: 14,
              borderRadius: 4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty State Overlay
/// Displays empty state card as an overlay with blurred background
class _EmptyStateOverlay extends ConsumerWidget {
  const _EmptyStateOverlay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(dashboardProvider.notifier);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        color: Colors.black.withOpacity(0.3),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: _EmptyHeroCard(
                onInventoryTap: () {
                  context.go('/inventory');
                },
                onRefreshTap: () {
                  viewModel.loadDashboardData();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Hero Empty Card
class _EmptyHeroCard extends StatelessWidget {
  final VoidCallback onInventoryTap;
  final VoidCallback onRefreshTap;

  const _EmptyHeroCard({
    required this.onInventoryTap,
    required this.onRefreshTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(
        18,
      ), // Reduced from 24 to 18 (25% reduction)
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Illustration placeholder with orange background
          Container(
            width: 90, // Reduced from 120 to 90 (25% reduction)
            height: 90, // Reduced from 120 to 90 (25% reduction)
            decoration: BoxDecoration(
              color: const Color(0xFFFFE5D6), // Light orange background
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 48, // Reduced from 64 to 48 (25% reduction)
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
          ),

          const SizedBox(height: 18), // Reduced from 24 to 18 (25% reduction)
          // Headline
          Text(
            'Your dashboard will come alive here',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.deepGreen,
              fontSize:
                  18, // Reduced from 20 to 18 (10% reduction, but keeping readable)
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 9), // Reduced from 12 to 9 (25% reduction)
          // Supportive copy
          Text(
            'Once you start adding stock and recording activity, your metrics and alerts will appear.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13, // Reduced from 14 to 13 (slight reduction)
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24), // Reduced from 32 to 24 (25% reduction)
          // Primary CTA button "Go to Inventory" with gradient (orange to yellow)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.mango, // Orange
                  const Color(0xFFFFBD3B), // Yellow
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: onInventoryTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                ), // Reduced from 16 to 12 (25% reduction)
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 18,
                  ), // Reduced from 20 to 18 (10% reduction)
                  const SizedBox(width: 8),
                  const Text(
                    'Go to Inventory',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ), // Reduced from 16 to 15 (slight reduction)
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12), // Reduced from 16 to 12 (25% reduction)
          // Secondary "Refresh" link/button
          TextButton(
            onPressed: onRefreshTap,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: 6,
              ), // Reduced from 8 to 6 (25% reduction)
            ),
            child: Text(
              'Refresh',
              style: TextStyle(
                color: AppColors.deepGreen,
                fontSize: 13, // Reduced from 14 to 13 (slight reduction)
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 8. Info Message Widget
/// Shows a message about hidden features for the role
class _InfoMessage extends StatelessWidget {
  const _InfoMessage();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0), // Very light beige/off-white background
        borderRadius: BorderRadius.circular(12), // Rounded corners
        // No border as per design
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circular info icon with 'i' symbol
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withOpacity(
                0.15,
              ), // Light gray circle background
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.info_outline,
              size: 16,
              color: AppColors.textSecondary, // Dark gray icon
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Some financial and admin features are hidden for your role.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.deepGreen, // Muted dark green text
                height: 1.4,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Alert Card widget - Pixel perfect design matching specifications
class _AlertCard extends StatelessWidget {
  final IconData icon;
  final Color
  edgeColor; // Color for the left edge arc (red, orange, blue, etc.)
  final Color
  iconBackgroundColor; // Background color for icon circle (light pink, etc.)
  final Color iconColor; // Color for the icon itself
  final String title;
  final String subtitle;
  final String timeAgo;
  final VoidCallback onTap;

  const _AlertCard({
    required this.icon,
    required this.edgeColor,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowSoft,
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Left edge colored arc (semi-circular with rounded corners)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: edgeColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
              ),
              // Card content
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    // Icon in circular background
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: iconBackgroundColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: iconColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    // Text content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title - Bold dark green
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.deepGreen,
                              fontSize: 15,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // Subtitle - Light gray, truncated
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              height: 1.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Time ago and arrow on the right
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          timeAgo,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
