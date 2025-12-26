import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:juix_na/app/app_colors.dart';
import 'package:juix_na/features/inventory/model/inventory_models.dart';
import 'package:juix_na/features/inventory/viewmodel/inventory_overview_vm.dart';
import 'package:juix_na/features/inventory/viewmodel/reorder_alerts_state.dart';
import 'package:juix_na/features/inventory/viewmodel/reorder_alerts_vm.dart';
import 'package:juix_na/features/inventory/widgets/reorder_alert_card.dart';

/// Reorder Alerts Screen
///
/// Displays low stock and out of stock alerts with filtering and location selection.
class ReorderAlertsScreen extends ConsumerStatefulWidget {
  const ReorderAlertsScreen({super.key});

  @override
  ConsumerState<ReorderAlertsScreen> createState() =>
      _ReorderAlertsScreenState();
}

class _ReorderAlertsScreenState extends ConsumerState<ReorderAlertsScreen> {
  String _activeFilter = 'All'; // 'All', 'Low Stock', 'Out of Stock'

  @override
  Widget build(BuildContext context) {
    final alertsState = ref.watch(reorderAlertsProvider);
    final viewModel = ref.read(reorderAlertsProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7EE), // Light cream background
      body: SafeArea(
        child: alertsState.when(
          data: (state) => RefreshIndicator(
            onRefresh: () => viewModel.refresh(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. AppBar (back button, title, sync button)
                  _AppBar(viewModel: viewModel),

                  const SizedBox(height: 12),

                  // 2. Location Selector + Online Status Chip (row)
                  _LocationAndStatusRow(
                    selectedLocationId: state.selectedLocationId,
                    onLocationSelected: (locationId) {
                      if (locationId == null) {
                        viewModel.clearLocationFilter();
                      } else {
                        viewModel.filterByLocation(locationId);
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // 3. Filter Buttons (All, Low Stock, Out of Stock)
                  _FilterButtons(
                    activeFilter: _activeFilter,
                    onFilterChanged: (filter) {
                      setState(() {
                        _activeFilter = filter;
                      });
                    },
                    lowStockCount: state.lowStockAlerts.length,
                    outOfStockCount: state.outOfStockCount,
                  ),

                  const SizedBox(height: 12),

                  // 4. Mark All As Read link
                  _MarkAllAsReadLink(
                    onPressed: () {
                      viewModel.dismissAlerts(state.alerts);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('All alerts marked as read'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // 5. Alert List
                  _AlertList(
                    state: state,
                    activeFilter: _activeFilter,
                    onDismiss: (alert) {
                      viewModel.dismissAlert(alert);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${alert.item.name} dismissed'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  'Error loading reorder alerts',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: AppColors.error),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    error.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => viewModel.refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Widget Components
// ============================================================================

class _AppBar extends StatelessWidget {
  final ReorderAlertsViewModel viewModel;

  const _AppBar({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Back button (left arrow)
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.deepGreen),
        ),

        // Title (centered)
        const Expanded(
          child: Text(
            'Reorder Alerts',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.deepGreen,
            ),
          ),
        ),

        // Sync button (right side)
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: AppColors.mangoLight.withValues(
              alpha: 0.2,
            ), // Light orange background
            borderRadius: BorderRadius.circular(20), // Pill shape
          ),
          child: TextButton.icon(
            onPressed: () => viewModel.refresh(),
            label: const Text(
              'Sync',
              style: TextStyle(
                color: AppColors.mango,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            icon: const Icon(Icons.sync, color: AppColors.mango, size: 18),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
      ],
    );
  }
}

/// Location Selector + Online Status Chip Row
class _LocationAndStatusRow extends ConsumerWidget {
  final int? selectedLocationId;
  final ValueChanged<int?> onLocationSelected;

  const _LocationAndStatusRow({
    required this.selectedLocationId,
    required this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get screen width to ensure proper sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = 14.0 * 2; // Left + right padding from parent
    final spacing = 12.0; // Gap between location and status
    final availableWidth = screenWidth - horizontalPadding - spacing;

    // Location takes ~65%, Status takes ~35%
    final locationWidth = availableWidth * 0.65;
    final statusWidth = availableWidth * 0.35;

    final locations = ref.watch(inventoryLocationsProvider);

    return Row(
      children: [
        // Location Selector (left)
        SizedBox(
          width: locationWidth,
          child: _LocationSelector(
            selectedLocationId: selectedLocationId,
            locations: locations,
            onTap: () => _showLocationPicker(context, locations),
          ),
        ),
        const SizedBox(width: 12),
        // Online Status Chip (right)
        SizedBox(width: statusWidth, child: _OnlineStatusChip()),
      ],
    );
  }

  Future<void> _showLocationPicker(
    BuildContext context,
    List<Location> locations,
  ) async {
    await showModalBottomSheet<int?>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFFFFF9F0), // Light cream background
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderSoft,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Text(
                'Select Location',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.deepGreen,
                ),
              ),
            ),
            // "All Locations" option
            ListTile(
              title: const Text(
                'All Locations',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepGreen,
                ),
              ),
              leading: Radio<int?>(
                value: null,
                groupValue: selectedLocationId,
                onChanged: (value) {
                  Navigator.pop(context, value);
                  onLocationSelected(value);
                },
              ),
            ),
            // Location options
            ...locations.map(
              (location) => ListTile(
                title: Text(
                  location.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepGreen,
                  ),
                ),
                subtitle: location.description != null
                    ? Text(location.description!)
                    : null,
                leading: Radio<int?>(
                  value: location.id,
                  groupValue: selectedLocationId,
                  onChanged: (value) {
                    Navigator.pop(context, value);
                    onLocationSelected(value);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Location Selector Button
class _LocationSelector extends StatelessWidget {
  final int? selectedLocationId;
  final List<Location> locations;
  final VoidCallback onTap;

  const _LocationSelector({
    required this.selectedLocationId,
    required this.locations,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Find selected location name
    String displayName = 'All Locations';
    if (selectedLocationId != null) {
      final location = locations.firstWhere(
        (loc) => loc.id == selectedLocationId,
        orElse: () => Location(
          id: -1,
          name: 'Unknown',
          description: null,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      if (location.id != -1) {
        displayName = location.name;
      }
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white, // White background
          borderRadius: BorderRadius.circular(16), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Building/store icon (dark green)
            const Icon(
              Icons.store_rounded,
              color: AppColors.deepGreen,
              size: 18,
            ),
            const SizedBox(width: 8),
            // Location name text (with overflow handling)
            Flexible(
              child: Text(
                displayName,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 4),
            // Dropdown chevron (dark green)
            const Icon(
              Icons.expand_more_rounded,
              color: AppColors.deepGreen,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

/// Online Status Chip (right side)
class _OnlineStatusChip extends StatelessWidget {
  const _OnlineStatusChip();

  @override
  Widget build(BuildContext context) {
    // Format current time
    final now = DateTime.now();
    final timeStr = DateFormat('h:mm a').format(now);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.15), // Light green background
        borderRadius: BorderRadius.circular(16), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Green circle icon
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.success, // Green color
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          // "Online • {time}" text (with overflow handling)
          Flexible(
            child: Text(
              'Online \u2022 $timeStr', // Using Unicode bullet character
              style: const TextStyle(
                color: AppColors.deepGreen,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Filter Buttons Row (All, Low Stock, Out of Stock)
class _FilterButtons extends StatelessWidget {
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;
  final int lowStockCount;
  final int outOfStockCount;

  const _FilterButtons({
    required this.activeFilter,
    required this.onFilterChanged,
    required this.lowStockCount,
    required this.outOfStockCount,
  });

  @override
  Widget build(BuildContext context) {
    // Get screen width and calculate available space
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = 14.0 * 2; // Left + right padding from parent
    final spacing = 10.0 * 2; // Two spacing gaps between 3 buttons
    final availableWidth = screenWidth - horizontalPadding - spacing;

    // Calculate button widths (equal distribution)
    final buttonWidth = availableWidth / 3;

    return Row(
      children: [
        // "All" button (active, orange)
        SizedBox(
          width: buttonWidth,
          child: _FilterButton(
            label: 'All',
            isActive: activeFilter == 'All',
            badge: null,
            onTap: () => onFilterChanged('All'),
          ),
        ),
        const SizedBox(width: 10),
        // "Low Stock" button (white, orange badge)
        SizedBox(
          width: buttonWidth,
          child: _FilterButton(
            label: 'Low Stock',
            isActive: activeFilter == 'Low Stock',
            badge: lowStockCount > 0
                ? _FilterBadge(count: lowStockCount, color: AppColors.mango)
                : null,
            onTap: () => onFilterChanged('Low Stock'),
          ),
        ),
        const SizedBox(width: 10),
        // "Out of Stock" button (white, red badge)
        SizedBox(
          width: buttonWidth,
          child: _FilterButton(
            label: 'Out of Stock',
            isActive: activeFilter == 'Out of Stock',
            badge: outOfStockCount > 0
                ? _FilterBadge(count: outOfStockCount, color: AppColors.error)
                : null,
            onTap: () => onFilterChanged('Out of Stock'),
          ),
        ),
      ],
    );
  }
}

/// Individual Filter Button
class _FilterButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final Widget? badge;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.isActive,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.mango
              : Colors.white, // Orange if active, white otherwise
          borderRadius: BorderRadius.circular(16), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Label text (with overflow handling)
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                  fontSize: 12, // Slightly smaller to prevent overflow
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ),
            // Badge (if provided and not active)
            if (badge != null && !isActive) ...[
              const SizedBox(width: 4),
              badge!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Filter Badge (count indicator)
class _FilterBadge extends StatelessWidget {
  final int count;
  final Color color;

  const _FilterBadge({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10), // Pill shape
      ),
      child: Text(
        count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}

/// Mark All As Read Link
class _MarkAllAsReadLink extends StatelessWidget {
  final VoidCallback onPressed;

  const _MarkAllAsReadLink({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Checklist/filter icon
              const Icon(
                Icons.checklist_rounded,
                color: AppColors.mango,
                size: 16,
              ),
              const SizedBox(width: 6),
              // "MARK ALL AS READ" text
              const Text(
                'MARK ALL AS READ',
                style: TextStyle(
                  color: AppColors.mango,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Alert List (connected to ViewModel)
class _AlertList extends StatelessWidget {
  final ReorderAlertsState state;
  final String activeFilter;
  final ValueChanged<ReorderAlert> onDismiss;

  const _AlertList({
    required this.state,
    required this.activeFilter,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    // Filter alerts based on active filter
    List<ReorderAlert> filteredAlerts;
    switch (activeFilter) {
      case 'Low Stock':
        filteredAlerts = state.lowStockAlerts;
        break;
      case 'Out of Stock':
        filteredAlerts = state.outOfStockAlerts;
        break;
      case 'All':
      default:
        filteredAlerts = state.alerts;
        break;
    }

    // Empty state
    if (filteredAlerts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: AppColors.textMuted.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                activeFilter == 'All'
                    ? 'No reorder alerts'
                    : 'No $activeFilter alerts',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'All items are well stocked',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    // Group alerts by location for display
    final alertsByLocation = <String?, List<ReorderAlert>>{};
    for (final alert in filteredAlerts) {
      final locationKey = alert.locationName ?? 'Unknown Location';
      alertsByLocation.putIfAbsent(locationKey, () => []).add(alert);
    }

    // Build list with location headers
    final widgets = <Widget>[];
    bool isFirstGroup = true;

    alertsByLocation.forEach((locationName, alerts) {
      // Add location header (skip for first group if only one location)
      if (!isFirstGroup || alertsByLocation.length > 1) {
        widgets.add(_LocationHeader(locationName: locationName ?? 'Unknown'));
        widgets.add(const SizedBox(height: 12));
      }

      // Add alert cards for this location
      for (final alert in alerts) {
        widgets.add(
          ReorderAlertCard(
            alert: alert,
            onCreateRequest: () {
              // TODO: Navigate to create request screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Create request for ${alert.item.name}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            onViewProduct: () {
              // TODO: Navigate to product details
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('View ${alert.item.name} details'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            onDismiss: () => onDismiss(alert),
          ),
        );
        widgets.add(const SizedBox(height: 12));
      }

      isFirstGroup = false;
    });

    // Remove last spacing
    if (widgets.isNotEmpty) {
      widgets.removeLast();
    }

    return Column(children: widgets);
  }
}

/// Location Header Widget
/// Displays location name when alerts are grouped by location
class _LocationHeader extends StatelessWidget {
  final String locationName;

  const _LocationHeader({required this.locationName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          locationName,
          style: const TextStyle(
            color: AppColors.deepGreen,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
