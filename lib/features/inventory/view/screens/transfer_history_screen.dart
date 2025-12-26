import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:juix_na/app/app_colors.dart';
import 'package:juix_na/core/network/api_result.dart';
import 'package:juix_na/features/inventory/data/inventory_repository.dart';
import 'package:juix_na/features/inventory/model/inventory_models.dart';
import 'package:juix_na/features/inventory/viewmodel/inventory_overview_vm.dart';
import 'package:juix_na/features/inventory/viewmodel/transfer_history_state.dart';
import 'package:juix_na/features/inventory/viewmodel/transfer_history_vm.dart';

/// Transfer History Screen
///
/// Displays a list of stock transfers (movements with type: TRANSFER) with filtering capabilities.
class TransferHistoryScreen extends ConsumerStatefulWidget {
  const TransferHistoryScreen({super.key});

  @override
  ConsumerState<TransferHistoryScreen> createState() =>
      _TransferHistoryScreenState();
}

class _TransferHistoryScreenState extends ConsumerState<TransferHistoryScreen> {
  String _activeFilter = 'This Week'; // 'This Week', 'Product', 'Source'

  @override
  Widget build(BuildContext context) {
    final transferState = ref.watch(transferHistoryProvider);
    final viewModel = ref.read(transferHistoryProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7EE), // Light cream background
      body: SafeArea(
        child: transferState.when(
          data: (state) => Column(
            children: [
              // AppBar
              _AppBar(viewModel: viewModel),

              const SizedBox(height: 12),

              // Location Selector + Online Status Chip (row)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: _LocationAndStatusRow(
                  selectedLocationId: state.selectedLocationId,
                  availableLocations: state.availableLocations,
                  onLocationSelected: (locationId) {
                    if (locationId == null) {
                      viewModel.clearLocationFilter();
                    } else {
                      viewModel.filterByLocation(locationId);
                    }
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Filter Buttons Row
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                child: _FilterButtons(
                  activeFilter: _activeFilter,
                  state: state,
                  viewModel: viewModel,
                  onFilterChanged: (filter) {
                    setState(() {
                      _activeFilter = filter;
                    });
                    // Apply filter based on selection
                    if (filter == 'This Week') {
                      final now = DateTime.now();
                      final startOfWeek = now.subtract(
                        Duration(days: now.weekday - 1),
                      );
                      final fromDate = DateTime(
                        startOfWeek.year,
                        startOfWeek.month,
                        startOfWeek.day,
                      );
                      viewModel.setDateRange(fromDate: fromDate);
                    } else if (filter == 'Product') {
                      _showProductPicker(context, ref, viewModel);
                    } else if (filter == 'Source') {
                      // Source filter is handled by location selector above
                      // This button just highlights the active filter
                    }
                  },
                ),
              ),

              // Transfer List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => viewModel.refresh(),
                  child: _TransferList(state: state),
                ),
              ),
            ],
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.mango),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  'Error loading transfer history',
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
  final TransferHistoryViewModel viewModel;

  const _AppBar({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // Close/Back button
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.close, color: AppColors.deepGreen),
          ),

          // Title (centered)
          const Expanded(
            child: Text(
              'Transfer History',
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
              color: AppColors.mangoLight.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Location Selector + Online Status Chip Row
class _LocationAndStatusRow extends ConsumerWidget {
  final int? selectedLocationId;
  final List<Location> availableLocations;
  final ValueChanged<int?> onLocationSelected;

  const _LocationAndStatusRow({
    required this.selectedLocationId,
    required this.availableLocations,
    required this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get screen width to ensure proper sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = 14.0 * 2;
    final spacing = 12.0;
    final availableWidth = screenWidth - horizontalPadding - spacing;
    final locationWidth = availableWidth * 0.65;
    final statusWidth = availableWidth * 0.35;

    return Row(
      children: [
        SizedBox(
          width: locationWidth,
          child: _LocationSelector(
            selectedLocationId: selectedLocationId,
            availableLocations: availableLocations,
            onTap: () => _showLocationPicker(
              context,
              availableLocations,
              selectedLocationId,
              onLocationSelected,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(width: statusWidth, child: _OnlineStatusChip()),
      ],
    );
  }

  Future<void> _showLocationPicker(
    BuildContext context,
    List<Location> locations,
    int? selectedLocationId,
    ValueChanged<int?> onLocationSelected,
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
          color: Color(0xFFFFF9F0),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderSoft,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Select Source Location',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.deepGreen,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.deepGreen),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
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
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: locations.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.borderSoft,
                ),
                itemBuilder: (context, index) {
                  final location = locations[index];
                  return ListTile(
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
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Show product picker for filtering transfers by product.
Future<void> _showProductPicker(
  BuildContext context,
  WidgetRef ref,
  TransferHistoryViewModel viewModel,
) async {
  final repository = ref.read(inventoryRepositoryProvider);
  bool isLoading = true;
  List<InventoryItem> items = [];
  String? error;

  // Load items
  final result = await repository.getInventoryItems(limit: 100);
  if (result.isSuccess) {
    final success = result as ApiSuccess<InventoryItemsResponse>;
    items = success.data.items;
    isLoading = false;
  } else {
    final failure = result as ApiFailure<InventoryItemsResponse>;
    error = failure.error.message;
    isLoading = false;
  }

  if (!context.mounted) return;

  await showModalBottomSheet<InventoryItem?>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFFF9F0),
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
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Select Product',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.deepGreen,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.deepGreen),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          // Content
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(color: AppColors.mango),
            )
          else if (error != null)
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading products',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 48,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No products available',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: items.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.borderSoft,
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).pop(item);
                      viewModel.filterByItem(item.id);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.mangoLight.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.inventory_2_rounded,
                              color: AppColors.mango,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    color: AppColors.deepGreen,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                if (item.sku.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'SKU: ${item.sku} • ${item.unit}',
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.textMuted,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}

/// Location Selector Button
class _LocationSelector extends StatelessWidget {
  final int? selectedLocationId;
  final List<Location> availableLocations;
  final VoidCallback onTap;

  const _LocationSelector({
    required this.selectedLocationId,
    required this.availableLocations,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String locationText = 'All Locations';
    if (selectedLocationId != null) {
      try {
        final location = availableLocations.firstWhere(
          (l) => l.id == selectedLocationId,
        );
        locationText = location.name;
      } catch (e) {
        locationText = 'Unknown';
      }
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSoft, width: 1),
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
            const Icon(
              Icons.warehouse_rounded,
              color: AppColors.mango,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                locationText,
                style: const TextStyle(
                  color: AppColors.deepGreen,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const Icon(
              Icons.expand_more_rounded,
              color: AppColors.textMuted,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

/// Online Status Chip
class _OnlineStatusChip extends StatelessWidget {
  const _OnlineStatusChip();

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('h:mm a').format(DateTime.now());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'Online \u2022 $timeStr',
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

/// Filter Buttons Row
class _FilterButtons extends StatelessWidget {
  final String activeFilter;
  final TransferHistoryState state;
  final TransferHistoryViewModel viewModel;
  final ValueChanged<String> onFilterChanged;

  const _FilterButtons({
    required this.activeFilter,
    required this.state,
    required this.viewModel,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Get selected product name if any
    String? selectedProductName;
    if (state.selectedItemId != null) {
      try {
        final transfer = state.transfers.firstWhere(
          (t) => t.itemId == state.selectedItemId,
        );
        selectedProductName = transfer.itemName;
      } catch (e) {
        selectedProductName = null;
      }
    }

    // Get selected location name if any
    String? selectedLocationName;
    if (state.selectedLocationId != null) {
      try {
        final location = state.availableLocations.firstWhere(
          (l) => l.id == state.selectedLocationId,
        );
        selectedLocationName = location.name;
      } catch (e) {
        selectedLocationName = null;
      }
    }

    return Row(
      children: [
        Expanded(
          child: _FilterButton(
            label: 'This Week',
            isActive: activeFilter == 'This Week',
            showChevron: false,
            onTap: () => onFilterChanged('This Week'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _FilterButton(
            label: selectedProductName ?? 'Product',
            isActive: activeFilter == 'Product' || state.selectedItemId != null,
            showChevron: true,
            onTap: () => onFilterChanged('Product'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _FilterButton(
            label: selectedLocationName ?? 'Source',
            isActive:
                activeFilter == 'Source' || state.selectedLocationId != null,
            showChevron: false,
            onTap: () => onFilterChanged('Source'),
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
  final bool showChevron;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.isActive,
    this.showChevron = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.mango : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? AppColors.mango : AppColors.borderSoft,
            width: 1,
          ),
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
          children: [
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ),
            if (showChevron) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.expand_more_rounded,
                color: isActive ? Colors.white : AppColors.textMuted,
                size: 18,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Transfer List
class _TransferList extends StatelessWidget {
  final TransferHistoryState state;

  const _TransferList({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(color: AppColors.mango),
        ),
      );
    }

    if (state.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                state.error ?? 'Unknown error',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (!state.hasTransfers) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.swap_horiz,
                size: 64,
                color: AppColors.textMuted.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No transfers found',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Stock transfers will appear here',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    // Note: Transfers appear as two movements (OUT from source, IN to destination)
    // Each movement shares the same reference. For v1, we show each movement separately.
    // Group by reference to show related movements together
    final groupedTransfers = <String, List<StockMovement>>{};
    for (var movement in state.transfers) {
      final key = movement.reference ?? 'TR-${movement.id}';
      groupedTransfers.putIfAbsent(key, () => []).add(movement);
    }

    // Flatten grouped transfers for display (for v1, show all movements)
    // Sort by createdAt (newest first)
    final sortedTransfers = state.transfers.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      itemCount: sortedTransfers.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final movement = sortedTransfers[index];
        return _TransferCard(movement: movement);
      },
    );
  }
}

/// Transfer Card Widget
/// Displays a single transfer movement.
/// Note: Transfers create two movements (OUT/IN), each shown separately.
class _TransferCard extends StatelessWidget {
  final StockMovement movement;

  const _TransferCard({required this.movement});

  @override
  Widget build(BuildContext context) {
    // Extract transfer ID from reference or use movement ID
    final transferId = movement.reference ?? 'TR-${movement.id}';

    // Determine status (for v1, all transfers are SYNCED since they're in the system)
    final status = TransferDisplayStatus.synced;

    // Get quantity (absolute value for display)
    final quantity = movement.quantity.abs();

    // Determine if this is OUT or IN movement
    final isOut = movement.quantity < 0 || movement.type == MovementType.out;
    final directionText = isOut ? 'OUT' : 'IN';
    final locationLabel = isOut ? 'From' : 'To';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row (Transfer ID, Product Name, Status)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Transfer ID and Product Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Transfer ID
                    Text(
                      '#$transferId',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Product Name
                    Text(
                      movement.itemName,
                      style: const TextStyle(
                        color: AppColors.deepGreen,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              // Right: Status Badge
              _StatusBadge(status: status),
            ],
          ),

          const SizedBox(height: 12),

          // Quantity (prominent, orange)
          Row(
            children: [
              Text(
                quantity.toStringAsFixed(0),
                style: const TextStyle(
                  color: AppColors.mango,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'units ($directionText)',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Location (simplified for v1 - shows single location)
          _LocationDisplay(
            label: locationLabel,
            locationName: movement.locationName,
          ),

          const SizedBox(height: 12),

          // Timestamp
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 16,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                DateFormat('MMM dd, h:mm a').format(movement.createdAt),
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Status Badge Widget
class _StatusBadge extends StatelessWidget {
  final TransferDisplayStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    String label;
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case TransferDisplayStatus.synced:
        label = 'SYNCED';
        backgroundColor = AppColors.success;
        textColor = Colors.white;
        icon = Icons.check_circle_rounded;
        break;
      case TransferDisplayStatus.pending:
        label = 'PENDING';
        backgroundColor = AppColors.mango;
        textColor = Colors.white;
        icon = Icons.more_horiz_rounded;
        break;
      case TransferDisplayStatus.failed:
        label = 'FAILED';
        backgroundColor = AppColors.error;
        textColor = Colors.white;
        icon = Icons.error_outline_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Location Display Widget (simplified for v1)
class _LocationDisplay extends StatelessWidget {
  final String label;
  final String locationName;

  const _LocationDisplay({required this.label, required this.locationName});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Location icon
        Icon(Icons.warehouse_rounded, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 8),
        // Location text
        Expanded(
          child: Text(
            '$label: $locationName',
            style: const TextStyle(
              color: AppColors.deepGreen,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
