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
import 'package:juix_na/features/dashboard/model/dashboard_models.dart';
import 'package:juix_na/features/dashboard/viewmodel/dashboard_vm.dart';
import 'package:juix_na/features/inventory/model/inventory_models.dart';
import 'package:juix_na/features/inventory/viewmodel/inventory_overview_vm.dart';

/// Dashboard Screen - Skeleton Framework
///
/// Structure based on design:
/// 1. AppBar (Dashboard title, refresh icon, notification bell, profile icon)
/// 2. Online Status Chip (green dot + "Online" + "Last updated Xm ago")
/// 3. Filter Chips Row (Location dropdown, Period selector: Today, Week, Month, Custom)
/// 4. KPI Cards Row (Total Sales, Total Expenses - side by side)
/// 5. Quick Actions Section (4 cards in 2x2 grid: Inventory, Sales, Production, Reports)
/// 6. Analytics Overview Section
///    - Sales Trend Card (bar chart for last 7 days)
///    - Top Products Card (donut chart with top 3 products)
/// 7. Alerts Section (list of alert cards with swipe to dismiss)

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
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

    // Handle loading and error states gracefully
    if (dashboardState.isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFFDF7EE),
        body: const Center(child: CircularProgressIndicator()),
        bottomNavigationBar: CustomBottomNavBar(currentIndex: currentIndex),
      );
    }

    // Handle AsyncValue errors using when() pattern
    // This handles both provider-level errors (AsyncError) and state-level errors (state.error)
    dashboardState.when(
      data: (state) {
        // Show error from state.error (state-level errors from ViewModel)
        if (state.error != null && state.error!.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              ErrorDisplay.showError(
                context,
                ApiError(type: ApiErrorType.unknown, message: state.error!),
                onRetry: () {
                  final viewModel = ref.read(dashboardProvider.notifier);
                  viewModel.loadDashboardData();
                },
              );
            }
          });
        }
      },
      error: (error, stackTrace) {
        // Handle AsyncValue error (provider-level error - e.g., initial load failure)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            ErrorDisplay.showError(
              context,
              ApiError(type: ApiErrorType.unknown, message: error.toString()),
              onRetry: () {
                final viewModel = ref.read(dashboardProvider.notifier);
                viewModel.loadDashboardData();
              },
            );
          }
        });
      },
      loading: () {
        // Loading state handled above with early return
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7EE), // Light cream background
      bottomNavigationBar: CustomBottomNavBar(currentIndex: currentIndex),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Refresh dashboard data
            final viewModel = ref.read(dashboardProvider.notifier);
            await viewModel.loadDashboardData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. AppBar (Dashboard title, refresh, notification, profile)
                _AppBar(),

                // 2. Online Status Chip (green dot + "Online" + "Last updated Xm ago")
                Center(child: _OnlineStatusChip()),

                const SizedBox(height: 16),

                // 3. Filter Chips Row (Location dropdown, Period selector)
                _FilterChipsRow(),

                const SizedBox(height: 16),

                // 4. KPI Cards Row (Total Sales, Total Expenses)
                _KPICardsRow(),

                const SizedBox(height: 20),

                // 5. Quick Actions Section
                _QuickActionsSection(),

                const SizedBox(height: 20),

                // 6. Analytics Overview Section
                _AnalyticsOverviewSection(),

                const SizedBox(height: 20),

                // 7. Alerts Section
                _AlertsSection(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
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
/// Contains: Dashboard title, refresh icon, notification bell (with badge), profile icon
class _AppBar extends ConsumerWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Connect refresh to dashboard ViewModel when implementing data loading
    // final viewModel = ref.read(dashboardProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFFDF7EE), // Light cream background
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Logo/Icon + Title
          Row(
            children: [
              // Dark green circular icon with coffee cup
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.deepGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.coffee,
                  color: Color(0xFFFFBD3B), // Golden-yellow coffee cup
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Dashboard',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepGreen,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          // Right: Actions (refresh, notification, profile)
          Row(
            children: [
              // Refresh Icon - White circular button
              _CircularIconButton(
                icon: Icons.refresh,
                iconColor: AppColors.deepGreen,
                onPressed: () {
                  final viewModel = ref.read(dashboardProvider.notifier);
                  viewModel.loadDashboardData();
                },
              ),
              const SizedBox(width: 8),
              // Notification Bell - White circular button with badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _CircularIconButton(
                    icon: Icons.notifications_outlined,
                    iconColor: AppColors.deepGreen,
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
              const SizedBox(width: 8),
              // Profile Avatar
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
                  radius: 20,
                  backgroundColor: const Color(
                    0xFFD97706,
                  ), // Light brown/orange background
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 24,
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

/// Circular icon button widget used for refresh and notification icons
class _CircularIconButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onPressed;

  const _CircularIconButton({
    required this.icon,
    required this.iconColor,
    required this.onPressed,
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
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
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
      // Note: WidgetRef should extend Ref per Riverpod docs, but Dart analyzer requires explicit cast
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
/// Contains: Horizontally scrollable KPI cards (Total Sales, Total Expenses, Total Profit)
class _KPICardsRow extends ConsumerWidget {
  const _KPICardsRow();

  String _formatCurrency(double amount) {
    if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '\$${amount.toStringAsFixed(0)}';
  }

  String _formatTrend(double? trend) {
    if (trend == null) return '';
    final sign = trend >= 0 ? '+' : '';
    return '$sign${trend.toStringAsFixed(0)}%';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get KPI data from dashboard state
    final dashboardState = ref.watch(dashboardProvider);
    final kpis = dashboardState.value?.kpis;
    final isLoadingKPIs = dashboardState.value?.isLoadingKPIs ?? false;

    return SizedBox(
      height: 148, // Fixed height matching card height
      child: isLoadingKPIs && kpis == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Total Sales Card
                  _KPICard(
                    title: 'Total Sales',
                    value: kpis != null
                        ? _formatCurrency(kpis.totalSales)
                        : '\$0',
                    trend: kpis?.salesTrend != null
                        ? '${_formatTrend(kpis!.salesTrend)} vs last period'
                        : 'No data',
                    icon: Icons.attach_money,
                    isGradient: true,
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
                                  'Sales detail screen coming soon',
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
                  const SizedBox(width: 12),
                  // Total Expenses Card
                  _KPICard(
                    title: 'Total Expenses',
                    value: kpis != null
                        ? _formatCurrency(kpis.totalExpenses)
                        : '\$0',
                    trend: kpis?.expensesTrend != null
                        ? _formatTrend(kpis!.expensesTrend)
                        : 'No data',
                    icon: Icons.receipt,
                    isGradient: false, // White background
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
                                  'Expenses detail screen coming soon',
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
                  const SizedBox(width: 12),
                  // Total Profit Card
                  _KPICard(
                    title: 'Total Profit',
                    value: kpis != null && kpis.totalProfit != null
                        ? _formatCurrency(kpis.totalProfit!)
                        : kpis != null
                        ? _formatCurrency(kpis.totalSales - kpis.totalExpenses)
                        : '\$0',
                    trend: kpis?.profitTrend != null
                        ? '${_formatTrend(kpis!.profitTrend)} vs last period'
                        : kpis != null
                        ? 'Calculated'
                        : 'No data',
                    icon: Icons.trending_up,
                    isGradient: false,
                    backgroundColor: AppColors.success.withOpacity(
                      0.1,
                    ), // Light green tint
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
                                  'Profit detail screen coming soon',
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

/// 5. Quick Actions Section
/// Contains: Heading "Quick Actions" + 2x4 grid of action cards
class _QuickActionsSection extends ConsumerWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.deepGreen,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16),
        // 2x2 Grid of Quick Action Cards
        Column(
          children: [
            // First row: Inventory and Sales
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.inventory_2,
                    title: 'Inventory',
                    subtitle: 'View stock levels & items',
                    backgroundColor: const Color(0xFFFFE5D6), // Light peach
                    iconBackgroundColor: const Color(
                      0xFFFFD4B3,
                    ), // Slightly darker peach circle
                    iconColor: const Color(0xFFFFBD3B), // Golden-yellow icon
                    titleColor: AppColors.deepGreen,
                    hasNotification: true, // Red dot in top-right
                    onTap: () {
                      context.go('/inventory');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.shopping_bag,
                    title: 'Sales',
                    subtitle: 'Manage POS & Orders',
                    badge: 'Coming Soon',
                    badgeIcon: Icons.lock_outline,
                    iconBackgroundColor:
                        AppColors.surfaceMuted, // Light gray circle
                    iconColor: AppColors.textSecondary, // Dark gray icon
                    titleColor:
                        AppColors.textSecondary, // Gray title (still bold)
                    isDisabled: true,
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
                                  'Sales module coming soon',
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
            const SizedBox(height: 12),
            // Second row: Production and Reports
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.factory,
                    title: 'Production',
                    subtitle: 'Juice mixing queue',
                    badge: 'Soon',
                    badgeIcon: Icons.access_time,
                    iconBackgroundColor:
                        AppColors.surfaceMuted, // Light gray circle
                    iconColor: AppColors.textSecondary, // Dark gray icon
                    titleColor:
                        AppColors.textSecondary, // Gray title (still bold)
                    isDisabled: true,
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
                                  'Production module coming soon',
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
                    badge: 'Soon',
                    badgeIcon: Icons.lock_outline,
                    iconBackgroundColor:
                        AppColors.surfaceMuted, // Light gray circle
                    iconColor: AppColors.textSecondary, // Dark gray icon
                    titleColor:
                        AppColors.textSecondary, // Gray title (still bold)
                    isDisabled: true,
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
                                  'Reports module coming soon',
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
  final String? badge; // "Coming Soon", "Soon", etc.
  final IconData? badgeIcon; // Lock or clock icon for badge
  final Color? backgroundColor; // Light peach for active, white for disabled
  final Color?
  iconBackgroundColor; // Circular background for icon (peach or gray)
  final Color? iconColor; // Icon color (golden-yellow or dark gray)
  final Color? titleColor; // Dark green for active, gray for disabled
  final bool hasNotification; // Red notification dot in top-right
  final bool
  isDisabled; // If true, card is disabled (gray text, no interaction)
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
    this.titleColor,
    this.hasNotification = false,
    this.isDisabled = false,
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

    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
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
          child: isDisabled
              ? ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                  child: Stack(
                    children: [
                      _buildCardContent(
                        context,
                        iconBg,
                        icColor,
                        tColor,
                        subColor,
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    _buildCardContent(
                      context,
                      iconBg,
                      icColor,
                      tColor,
                      subColor,
                    ),
                    // Red notification dot in top-right corner (only for active cards)
                    if (hasNotification && !isDisabled)
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
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon in circular background
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, size: 32, color: icColor),
        ),
        // Badge positioned below icon (horizontally centered)
        if (badge != null) ...[
          const SizedBox(height: 8),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success, // Dark green badge
                borderRadius: BorderRadius.circular(12), // Pill-shaped
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (badgeIcon != null) ...[
                    Icon(badgeIcon, size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                    ),
                  ),
                ],
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

/// 6. Analytics Overview Section
/// Contains: Heading "Analytics Overview" + Sales Trend card + Top Products card
class _AnalyticsOverviewSection extends ConsumerWidget {
  const _AnalyticsOverviewSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics Overview',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        // Sales Trend Card
        _SalesTrendCard(),
        const SizedBox(height: 12),
        // Top Products Card
        _TopProductsCard(),
      ],
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

/// 7. Alerts Section
/// Contains: Heading "Alerts" + "See all" button + list of alert cards
class _AlertsSection extends ConsumerWidget {
  const _AlertsSection();

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
    final alerts = dashboardState.value?.alerts ?? [];
    final isLoadingAlerts = dashboardState.value?.isLoadingAlerts ?? false;
    final selectedLocationId = dashboardState.value?.selectedLocationId;

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
                      Text(
                        'Alerts',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepGreen, // Dark green text
                          fontSize: 16,
                        ),
                      ),
                      // Show location filter indicator if location is selected
                      if (selectedLocationId != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            'Location filtered',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
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
      ],
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
