import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:juix_na/app/app_colors.dart';
import 'package:juix_na/features/inventory/model/inventory_models.dart';
import 'package:juix_na/features/inventory/viewmodel/stock_transfer_state.dart';
import 'package:juix_na/features/inventory/viewmodel/stock_transfer_vm.dart';

/// Stock Transfer Screen
///
/// Allows transferring stock between locations with validation and error handling.
class StockTransferScreen extends ConsumerStatefulWidget {
  const StockTransferScreen({super.key});

  @override
  ConsumerState<StockTransferScreen> createState() =>
      _StockTransferScreenState();
}

class _StockTransferScreenState extends ConsumerState<StockTransferScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7EE), // Light cream background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. AppBar (back button, title, sync button)
              _AppBar(),

              const SizedBox(height: 12),

              // 2. Online Status Indicator
              Center(child: _OnlineStatusIndicator()),

              const SizedBox(height: 16),

              // 3. Form Card
              _FormCard(
                children: [
                  // Section Title
                  const Text(
                    'Transfer Setup',
                    style: TextStyle(
                      color: AppColors.deepGreen,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date field
                  _DateField(),

                  const SizedBox(height: 12),

                  // Product field
                  _ProductField(),

                  // Batch field (hidden for v1 - batches not required per API spec)
                  // TODO: Add batch field when batch tracking is implemented
                  const SizedBox.shrink(),

                  const SizedBox(height: 12),

                  // From (Source) field
                  _FromLocationField(),

                  const SizedBox(height: 12),

                  // Swap arrow button
                  _SwapLocationsButton(),

                  const SizedBox(height: 12),

                  // To (Destination) field
                  _ToLocationField(),

                  const SizedBox(height: 12),

                  // Availability info bar
                  _AvailabilityInfoBar(),

                  const SizedBox(height: 12),

                  // Quantity field
                  _QuantityField(),

                  const SizedBox(height: 12),

                  // Notes field
                  _NotesField(),
                ],
              ),

              const SizedBox(height: 18),

              // 4. Footer buttons (Cancel, Transfer Stock)
              _FooterButtons(),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Widget Components
// ============================================================================

class _AppBar extends ConsumerWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(stockTransferProvider.notifier);
    
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
            'Transfers',
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

class _OnlineStatusIndicator extends StatelessWidget {
  const _OnlineStatusIndicator();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeStr = DateFormat('h:mm a').format(now);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white, // White background
        borderRadius: BorderRadius.circular(20), // Pill shape
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
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Wi-Fi icon (green)
          Icon(
            Icons.wifi,
            size: 16,
            color: AppColors.success, // Green color
          ),
          const SizedBox(width: 8),
          // "ONLINE" text
          const Text(
            'ONLINE',
            style: TextStyle(
              color: AppColors.deepGreen,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 6),
          // Bullet point separator
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: AppColors.deepGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          // "LAST SYNC: [time]" text
          Text(
            'Last sync: $timeStr',
            style: const TextStyle(
              color: AppColors.deepGreen,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final List<Widget> children;

  const _FormCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9F0), // Light cream background
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
        children: children,
      ),
    );
  }
}

class _DateField extends ConsumerWidget {
  const _DateField();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(stockTransferProvider);
    final viewModel = ref.read(stockTransferProvider.notifier);

    return state.when(
      data: (transferState) {
        final dateStr = DateFormat('MMM dd, yyyy').format(transferState.date);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Date',
              style: TextStyle(
                color: AppColors.deepGreen,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: transferState.date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: AppColors.mango,
                          onPrimary: Colors.white,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  viewModel.setDate(picked);
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(23),
                  border: Border.all(
                    color: AppColors.mangoLight,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        dateStr,
                        style: const TextStyle(
                          color: AppColors.deepGreen,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.calendar_today_rounded,
                      color: AppColors.mango,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(height: 80),
      error: (_, __) => const SizedBox(height: 80),
    );
  }
}

class _ProductField extends ConsumerWidget {
  const _ProductField();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(stockTransferProvider);
    final viewModel = ref.read(stockTransferProvider.notifier);

    return state.when(
      data: (transferState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Product',
              style: TextStyle(
                color: AppColors.deepGreen,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: transferState.isLoadingItems
                  ? null
                  : () => _showProductPicker(context, transferState, viewModel, ref),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: transferState.selectedItem != null ? 80 : 54,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(23),
                  border: Border.all(
                    color: AppColors.mangoLight,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    // Product image/icon (if selected)
                    if (transferState.selectedItem != null) ...[
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.mangoLight.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.inventory_2_rounded,
                          color: AppColors.mango,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    // Product name and SKU
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (transferState.selectedItem != null) ...[
                            Text(
                              transferState.selectedItem!.name,
                              style: const TextStyle(
                                color: AppColors.deepGreen,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (transferState.selectedItem!.sku.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                transferState.selectedItem!.sku,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ] else
                            Text(
                              'Select product',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Dropdown icon or loading indicator
                    if (transferState.isLoadingItems)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.mango,
                        ),
                      )
                    else
                      const Icon(
                        Icons.expand_more_rounded,
                        color: AppColors.textMuted,
                        size: 24,
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(height: 80),
      error: (_, __) => const SizedBox(height: 80),
    );
  }

  Future<void> _showProductPicker(
    BuildContext context,
    StockTransferState state,
    StockTransferViewModel viewModel,
    WidgetRef ref,
  ) async {
    if (state.isLoadingItems) return;

    // Load products if not already loaded
    if (state.availableItems.isEmpty && !state.isLoadingItems) {
      await viewModel.loadProducts(locationId: state.fromLocationId);
    }

    await showModalBottomSheet<InventoryItem?>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final pickerState = ref.watch(stockTransferProvider);
        return pickerState.when(
          data: (pickerData) => Container(
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
                if (pickerData.isLoadingItems)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(color: AppColors.mango),
                  )
                else if (pickerData.availableItems.isEmpty)
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
                      itemCount: pickerData.availableItems.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.borderSoft,
                      ),
                      itemBuilder: (context, index) {
                        final item = pickerData.availableItems[index];
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).pop(item);
                            viewModel.selectItem(item);
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
          loading: () => Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF9F0),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: const Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(color: AppColors.mango),
            ),
          ),
          error: (error, stack) => Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF9F0),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load products',
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Batch field removed for v1 - batches are not required per API spec
// TODO: Add batch field when batch tracking is implemented
// (Hidden similar to Cycle Counts Screen approach)

class _FromLocationField extends ConsumerWidget {
  const _FromLocationField();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(stockTransferProvider);
    final viewModel = ref.read(stockTransferProvider.notifier);

    return state.when(
      data: (transferState) {
        final fromLocation = transferState.fromLocation;
        final displayName = fromLocation?.name ?? 'Select source location';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'From (Source)',
              style: TextStyle(
                color: AppColors.deepGreen,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: transferState.isLoadingLocations
                  ? null
                  : () => _showLocationPicker(
                        context,
                        transferState,
                        viewModel,
                        isFromLocation: true,
                      ),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(23),
                  border: Border.all(
                    color: AppColors.mangoLight,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
                        style: TextStyle(
                          color: fromLocation != null
                              ? AppColors.deepGreen
                              : AppColors.textMuted,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.warehouse_rounded,
                      color: AppColors.mango,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(height: 80),
      error: (_, __) => const SizedBox(height: 80),
    );
  }

  Future<void> _showLocationPicker(
    BuildContext context,
    StockTransferState state,
    StockTransferViewModel viewModel, {
    required bool isFromLocation,
  }) async {
    if (state.availableLocations.isEmpty) return;

    await showModalBottomSheet<Location?>(
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
              child: Text(
                isFromLocation ? 'Select Source Location' : 'Select Destination',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.deepGreen,
                    ),
              ),
            ),
            // Location list
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: state.availableLocations.length,
                itemBuilder: (context, index) {
                  final location = state.availableLocations[index];
                  return ListTile(
                    leading: const Icon(
                      Icons.warehouse_rounded,
                      color: AppColors.mango,
                    ),
                    title: Text(
                      location.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepGreen,
                      ),
                    ),
                    subtitle: location.description != null
                        ? Text(location.description!)
                        : null,
                    onTap: () {
                      Navigator.pop(context, location);
                      if (isFromLocation) {
                        viewModel.setFromLocation(location.id);
                      } else {
                        viewModel.setToLocation(location.id);
                      }
                    },
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

class _SwapLocationsButton extends ConsumerWidget {
  const _SwapLocationsButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(stockTransferProvider);
    final viewModel = ref.read(stockTransferProvider.notifier);

    return state.when(
      data: (transferState) {
        // Only show swap button if both locations are selected
        if (transferState.fromLocationId == null ||
            transferState.toLocationId == null) {
          return const SizedBox.shrink();
        }

        return Center(
          child: InkWell(
            onTap: () {
              // Swap locations
              final fromId = transferState.fromLocationId;
              final toId = transferState.toLocationId;
              if (fromId != null && toId != null) {
                viewModel.setFromLocation(toId);
                viewModel.setToLocation(fromId);
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.mangoLight.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.swap_vert_rounded,
                color: AppColors.mango,
                size: 24,
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _ToLocationField extends ConsumerWidget {
  const _ToLocationField();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(stockTransferProvider);
    final viewModel = ref.read(stockTransferProvider.notifier);

    return state.when(
      data: (transferState) {
        final toLocation = transferState.toLocation;
        final displayName = toLocation?.name ?? 'Select destination location';
        final hasError = transferState.hasSameLocations;
        final errorMessage = transferState.locationError;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'To (Destination)',
              style: TextStyle(
                color: AppColors.deepGreen,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: transferState.isLoadingLocations
                  ? null
                  : () => _showLocationPicker(
                        context,
                        transferState,
                        viewModel,
                        isFromLocation: false,
                      ),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(23),
                  border: Border.all(
                    color: hasError ? AppColors.error : AppColors.mangoLight,
                    width: hasError ? 2 : 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
                        style: TextStyle(
                          color: toLocation != null
                              ? AppColors.deepGreen
                              : AppColors.textMuted,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.warehouse_rounded,
                      color: hasError ? AppColors.error : AppColors.mango,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            // Error message
            if (hasError && errorMessage != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      errorMessage,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
      loading: () => const SizedBox(height: 80),
      error: (_, __) => const SizedBox(height: 80),
    );
  }

  Future<void> _showLocationPicker(
    BuildContext context,
    StockTransferState state,
    StockTransferViewModel viewModel, {
    required bool isFromLocation,
  }) async {
    if (state.availableLocations.isEmpty) return;

    await showModalBottomSheet<Location?>(
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
              child: Text(
                isFromLocation ? 'Select Source Location' : 'Select Destination',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.deepGreen,
                    ),
              ),
            ),
            // Location list
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: state.availableLocations.length,
                itemBuilder: (context, index) {
                  final location = state.availableLocations[index];
                  return ListTile(
                    leading: const Icon(
                      Icons.warehouse_rounded,
                      color: AppColors.mango,
                    ),
                    title: Text(
                      location.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepGreen,
                      ),
                    ),
                    subtitle: location.description != null
                        ? Text(location.description!)
                        : null,
                    onTap: () {
                      Navigator.pop(context, location);
                      if (isFromLocation) {
                        viewModel.setFromLocation(location.id);
                      } else {
                        viewModel.setToLocation(location.id);
                      }
                    },
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

class _AvailabilityInfoBar extends ConsumerWidget {
  const _AvailabilityInfoBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(stockTransferProvider);

    return state.when(
      data: (transferState) {
        // Only show if product and from location are selected
        if (transferState.selectedItem == null ||
            transferState.fromLocationId == null ||
            transferState.availableStock == null) {
          return const SizedBox.shrink();
        }

        final availableStock = transferState.availableStock!;
        final unit = transferState.selectedItem!.unit;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.success.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.local_shipping_rounded,
                color: AppColors.success,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Available in Source: ${availableStock.toStringAsFixed(0)} $unit',
                style: const TextStyle(
                  color: AppColors.deepGreen,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _QuantityField extends ConsumerWidget {
  const _QuantityField();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(stockTransferProvider);
    final viewModel = ref.read(stockTransferProvider.notifier);

    return state.when(
      data: (transferState) {
        final quantity = transferState.quantity;
        final hasError = transferState.quantityExceedsAvailable;
        final errorMessage = transferState.quantityError;
        final availableStock = transferState.availableStock;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quantity',
              style: TextStyle(
                color: AppColors.deepGreen,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                // Decrease button
                InkWell(
                  onTap: quantity > 0
                      ? () => viewModel.setQuantity(quantity - 1)
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: quantity > 0
                          ? AppColors.mangoLight.withOpacity(0.2)
                          : AppColors.borderSoft.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: quantity > 0
                            ? AppColors.mango
                            : AppColors.borderSoft,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.remove,
                      color: quantity > 0
                          ? AppColors.mango
                          : AppColors.textMuted,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Quantity input field
                Expanded(
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(23),
                      border: Border.all(
                        color: hasError
                            ? AppColors.error
                            : AppColors.mangoLight,
                        width: hasError ? 2 : 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            quantity.toStringAsFixed(0),
                            style: TextStyle(
                              color: hasError
                                  ? AppColors.error
                                  : AppColors.deepGreen,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (transferState.selectedItem != null)
                          Text(
                            transferState.selectedItem!.unit,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Increase button
                InkWell(
                  onTap: () => viewModel.setQuantity(quantity + 1),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.mangoLight.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.mango,
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: AppColors.mango,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            // Error message or available stock info
            if (hasError && errorMessage != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      errorMessage,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (availableStock != null && quantity > 0) ...[
              const SizedBox(height: 6),
              Text(
                'Available: ${availableStock.toStringAsFixed(0)} ${transferState.selectedItem?.unit ?? ''}',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        );
      },
      loading: () => const SizedBox(height: 80),
      error: (_, __) => const SizedBox(height: 80),
    );
  }
}

class _NotesField extends ConsumerWidget {
  const _NotesField();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(stockTransferProvider);
    final viewModel = ref.read(stockTransferProvider.notifier);

    return state.when(
      data: (transferState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notes',
              style: TextStyle(
                color: AppColors.deepGreen,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.mangoLight,
                  width: 1,
                ),
              ),
              child: TextField(
                onChanged: (value) => viewModel.setNote(value),
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Add notes (optional)',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14),
                  hintStyle: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                  ),
                ),
                style: const TextStyle(
                  color: AppColors.deepGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(height: 80),
      error: (_, __) => const SizedBox(height: 80),
    );
  }
}

class _FooterButtons extends ConsumerWidget {
  const _FooterButtons();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(stockTransferProvider);
    final viewModel = ref.read(stockTransferProvider.notifier);

    return state.when(
      data: (transferState) {
        final isValid = transferState.isValid;
        final isSubmitting = transferState.isSubmitting;

        return Row(
          children: [
            // Cancel button
            Expanded(
              child: InkWell(
                onTap: () => Navigator.of(context).maybePop(),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.borderSoft,
                      width: 1,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.deepGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Transfer Stock button
            Expanded(
              flex: 2,
              child: InkWell(
                onTap: isValid && !isSubmitting
                    ? () async {
                        final success = await viewModel.createStockTransfer();
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Stock transfer created successfully'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                          Navigator.of(context).maybePop();
                        } else if (context.mounted) {
                          final errorState = ref.read(stockTransferProvider);
                          final errorMessage = errorState.value?.error ??
                              'Failed to create stock transfer';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errorMessage),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    : null,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isValid && !isSubmitting
                        ? AppColors.mango
                        : AppColors.borderSoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isSubmitting) ...[
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ] else if (!isValid) ...[
                        const Icon(
                          Icons.block,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        'Transfer Stock',
                        style: TextStyle(
                          color: isValid && !isSubmitting
                              ? Colors.white
                              : Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      if (isValid && !isSubmitting) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(height: 60),
      error: (_, __) => const SizedBox(height: 60),
    );
  }
}

