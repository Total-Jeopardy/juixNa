import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:juix_na/app/app_colors.dart';
import 'package:juix_na/features/auth/viewmodel/auth_vm.dart';
import 'package:juix_na/features/inventory/model/inventory_models.dart';
import 'package:juix_na/features/inventory/viewmodel/cycle_count_state.dart';
import 'package:juix_na/features/inventory/viewmodel/cycle_count_vm.dart';

/// Cycle Counts Screen - Skeleton Framework
///
/// Structure based on design:
/// 1. AppBar (back button, title, sync status)
/// 2. Online Status Indicator
/// 3. COUNT SETUP Section
///    - Date field
///    - Product field (with icon, name, SKU)
///    - Batch field (required, conditional)
///    - Location field
/// 4. QUANTITIES Section
///    - System Quantity (display only)
///    - Counted Quantity (input with +/- buttons)
///    - Variance (calculated display)
/// 5. Approval Message (when variance requires approval)
/// 6. Footer buttons (Cancel, Adjust Stock, Save Count)

class CycleCountsScreen extends ConsumerStatefulWidget {
  const CycleCountsScreen({super.key});

  @override
  ConsumerState<CycleCountsScreen> createState() => _CycleCountsScreenState();
}

class _CycleCountsScreenState extends ConsumerState<CycleCountsScreen> {
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
              // 1. AppBar (back button, title, sync status)
              _AppBar(),

              const SizedBox(height: 12),

              // 2. Online Status Indicator
              _OnlineStatusIndicator(),

              const SizedBox(height: 16),

              // 3. COUNT SETUP Section
              _CountSetupSection(),

              const SizedBox(height: 16),

              // 4. QUANTITIES Section
              _QuantitiesSection(),

              const SizedBox(height: 16),

              // 5. Approval Message (conditional, elevated card at bottom)
              // Shows when variance exists and user needs approval
              _ApprovalMessage(),

              const SizedBox(height: 16),

              // 6. Footer buttons (Cancel, Adjust Stock, Save Count)
              _FooterButtons(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// PLACEHOLDER COMPONENTS
// ============================================================================

class _AppBar extends ConsumerWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(cycleCountProvider.notifier);
    final countState = ref.watch(cycleCountProvider);

    return Row(
      children: [
        // Back button
        IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.deepGreen,
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // Title (centered)
        const Expanded(
          child: Text(
            'Cycle Counts',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.deepGreen,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
        ),
        // Refresh button (pill-shaped, matching Stock Movement style)
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: TextButton.icon(
            onPressed: () {
              // Reload system quantity if item and location are selected
              countState.whenData((state) {
                if (state.selectedItem != null &&
                    state.selectedLocationId != null) {
                  viewModel.getSystemQuantity(
                    itemId: state.selectedItem!.id,
                    locationId: state.selectedLocationId!,
                  );
                } else {
                  // Otherwise, just reload locations
                  viewModel.loadProducts();
                }
              });
            },
            icon: const Icon(Icons.sync, color: AppColors.mango, size: 16),
            label: const Text(
              'Refresh',
              style: TextStyle(
                color: AppColors.mango,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: const Color(
                0xFFFFF9F0,
              ), // Light cream background
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999), // Fully rounded pill
              ),
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

    return Center(
      child: Container(
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
            // "LAST REFRESHED: [time]" text
            Text(
              'LAST REFRESHED: $timeStr',
              style: const TextStyle(
                color: AppColors.deepGreen,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountSetupSection extends StatelessWidget {
  const _CountSetupSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          const Text(
            'COUNT SETUP',
            style: TextStyle(
              color: AppColors.deepGreen,
              fontWeight: FontWeight.w800,
              fontSize: 14,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          // TODO: Date field
          _DateField(),
          const SizedBox(height: 12),
          // TODO: Product field
          _ProductField(),
          const SizedBox(height: 12),
          // TODO: Batch field (conditional, required)
          _BatchField(),
          const SizedBox(height: 12),
          // TODO: Location field
          _LocationField(),
        ],
      ),
    );
  }
}

class _DateField extends ConsumerWidget {
  const _DateField();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cycleCountProvider);
    final viewModel = ref.read(cycleCountProvider.notifier);

    return state.when(
      data: (countState) {
        // NOTE: Date is stored in state but not sent to API in v1.
        // It's display-only for user reference. The API uses server timestamp.
        final dateLabel = DateFormat('MMM dd, yyyy').format(countState.date);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            const Text(
              'Date',
              style: TextStyle(
                color: AppColors.deepGreen,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            // Input field
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: countState.date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  viewModel.setDate(picked);
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white, // White background
                  borderRadius: BorderRadius.circular(23), // Rounded corners
                  border: Border.all(
                    color: AppColors.mangoLight, // Light orange border
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    // Date text
                    Expanded(
                      child: Text(
                        dateLabel,
                        style: const TextStyle(
                          color: AppColors.deepGreen,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    // Calendar icon (orange)
                    const Icon(
                      Icons.calendar_today_outlined,
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

  Future<void> _showProductPicker(
    BuildContext context,
    CycleCountState state,
    CycleCountViewModel viewModel,
  ) async {
    if (state.isLoadingItems) return;

    // Load products if not already loaded
    if (state.availableItems.isEmpty && !state.isLoadingItems) {
      viewModel.loadProducts(locationId: state.selectedLocationId);
    }

    final selected = await showModalBottomSheet<InventoryItem?>(
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
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Select Product',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.deepGreen,
                        fontSize: 20,
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
            if (state.isLoadingItems)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(color: AppColors.mango),
              )
            else if (state.availableItems.isEmpty)
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
                  itemCount: state.availableItems.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.borderSoft,
                  ),
                  itemBuilder: (context, index) {
                    final item = state.availableItems[index];
                    return InkWell(
                      onTap: () => Navigator.of(context).pop(item),
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
                                      'SKU: ${item.sku}',
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

    if (selected != null) {
      viewModel.selectItem(selected);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cycleCountProvider);
    final viewModel = ref.read(cycleCountProvider.notifier);

    return state.when(
      data: (countState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            const Text(
              'Product',
              style: TextStyle(
                color: AppColors.deepGreen,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            // Input field - Product card style when selected
            InkWell(
              onTap: countState.isLoadingItems
                  ? null
                  : () => _showProductPicker(context, countState, viewModel),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: countState.selectedItem != null ? 80 : 54,
                decoration: BoxDecoration(
                  color: Colors.white, // White background
                  borderRadius: BorderRadius.circular(23), // Rounded corners
                  border: Border.all(
                    color: AppColors.mangoLight, // Light orange border
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: countState.selectedItem != null
                    ? Row(
                        children: [
                          // Product image thumbnail (or placeholder)
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.mangoLight.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.borderSoft,
                                width: 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child:
                                  countState.selectedItem != null &&
                                      countState.selectedItem!.sku.isNotEmpty
                                  ? // TODO: Replace with actual image URL when available
                                    // For now, show a placeholder with product icon
                                    Container(
                                      color: AppColors.mangoLight.withOpacity(
                                        0.2,
                                      ),
                                      child: const Icon(
                                        Icons.inventory_2_rounded,
                                        color: AppColors.mango,
                                        size: 28,
                                      ),
                                    )
                                  : Container(
                                      color: AppColors.mangoLight.withOpacity(
                                        0.2,
                                      ),
                                      child: const Icon(
                                        Icons.inventory_2_rounded,
                                        color: AppColors.mango,
                                        size: 28,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Product details
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product name
                                Text(
                                  countState.selectedItem!.name,
                                  style: const TextStyle(
                                    color: AppColors.deepGreen,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                // SKU and unit
                                Text(
                                  'SKU: ${countState.selectedItem!.sku} • ${countState.selectedItem!.unit}',
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Chevron icon
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.textMuted,
                            size: 20,
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          // Placeholder text
                          Expanded(
                            child: Text(
                              'Select product',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          // Dropdown icon
                          if (countState.isLoadingItems)
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
                              color: AppColors.mango,
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
}

class _BatchField extends ConsumerWidget {
  const _BatchField();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // NOTE: Batch tracking is not implemented in v1 per API specification.
    // This field is hidden for now. When batch tracking is added, implement
    // the field similar to ProductField/LocationField with a batch picker.
    return const SizedBox.shrink();
  }
}

class _LocationField extends ConsumerWidget {
  const _LocationField();

  Future<void> _showLocationPicker(
    BuildContext context,
    CycleCountState state,
    CycleCountViewModel viewModel,
  ) async {
    if (state.isLoadingLocations) return;

    final selected = await showModalBottomSheet<Location?>(
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
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Select Location',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.deepGreen,
                        fontSize: 20,
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
            if (state.isLoadingLocations)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(color: AppColors.mango),
              )
            else if (state.availableLocations.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 48,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No locations available',
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
                  itemCount: state.availableLocations.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.borderSoft,
                  ),
                  itemBuilder: (context, index) {
                    final location = state.availableLocations[index];
                    return InkWell(
                      onTap: () => Navigator.of(context).pop(location),
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
                                Icons.location_on_rounded,
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
                                    location.name,
                                    style: const TextStyle(
                                      color: AppColors.deepGreen,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (location.description != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      location.description!,
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

    if (selected != null) {
      viewModel.selectLocation(selected.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cycleCountProvider);
    final viewModel = ref.read(cycleCountProvider.notifier);

    return state.when(
      data: (countState) {
        final selectedLocation = countState.availableLocations.firstWhere(
          (loc) => loc.id == countState.selectedLocationId,
          orElse: () => Location(
            id: -1,
            name: '',
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            const Text(
              'Location',
              style: TextStyle(
                color: AppColors.deepGreen,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            // Input field
            InkWell(
              onTap: countState.isLoadingLocations
                  ? null
                  : () => _showLocationPicker(context, countState, viewModel),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white, // White background
                  borderRadius: BorderRadius.circular(23), // Rounded corners
                  border: Border.all(
                    color: AppColors.mangoLight, // Light orange border
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    // Location text
                    Expanded(
                      child: Text(
                        countState.selectedLocationId != null
                            ? selectedLocation.name
                            : 'Select location',
                        style: TextStyle(
                          color: countState.selectedLocationId != null
                              ? AppColors.deepGreen
                              : AppColors.textMuted,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Dropdown icon
                    if (countState.isLoadingLocations)
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
                        color: AppColors.mango,
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
}

class _QuantitiesSection extends StatelessWidget {
  const _QuantitiesSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          const Text(
            'QUANTITIES',
            style: TextStyle(
              color: AppColors.deepGreen,
              fontWeight: FontWeight.w800,
              fontSize: 14,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          // TODO: System Quantity (display only)
          _SystemQuantityField(),
          const SizedBox(height: 16),
          // TODO: Counted Quantity (input with +/- buttons)
          _CountedQuantityField(),
          const SizedBox(height: 12),
          // TODO: Variance (calculated display)
          _VarianceField(),
        ],
      ),
    );
  }
}

class _SystemQuantityField extends ConsumerWidget {
  const _SystemQuantityField();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cycleCountProvider);
    final viewModel = ref.read(cycleCountProvider.notifier);

    return state.when(
      data: (countState) {
        final systemQty = countState.systemQuantity;
        final isLoading = countState.isLoadingSystemQuantity;
        final hasItem = countState.selectedItem != null;
        final hasLocation = countState.selectedLocationId != null;
        final canLoad = hasItem && hasLocation && !isLoading;

        // Determine what to show
        String displayText;
        bool showRefresh = false;

        if (isLoading) {
          displayText = 'Loading...';
        } else if (systemQty != null) {
          // Show the actual quantity from database
          displayText = '${systemQty.toInt()} units';
          showRefresh = true;
        } else if (hasItem && hasLocation) {
          // Both selected but quantity not loaded yet (shouldn't happen, but handle it)
          displayText = 'Tap to load';
          showRefresh = true;
        } else {
          // Missing product or location
          displayText = 'N/A';
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main container with System Quantity label and value
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5), // Light gray/beige background
                borderRadius: BorderRadius.circular(16), // Rounded corners
              ),
              child: Row(
                children: [
                  // "System Quantity" label
                  const Text(
                    'System Quantity',
                    style: TextStyle(
                      color: AppColors.deepGreen,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  // Quantity value in gray pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0), // Light gray background
                      borderRadius: BorderRadius.circular(12), // Rounded pill
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isLoading)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textMuted,
                            ),
                          )
                        else
                          Text(
                            displayText,
                            style: const TextStyle(
                              color: AppColors.deepGreen,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        // Refresh button (only show when quantity is loaded or can be loaded)
                        if (showRefresh && !isLoading) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: canLoad
                                ? () {
                                    // Manually trigger system quantity load
                                    viewModel.getSystemQuantity(
                                      itemId: countState.selectedItem!.id,
                                      locationId:
                                          countState.selectedLocationId!,
                                    );
                                  }
                                : null,
                            child: Icon(
                              Icons.refresh_rounded,
                              size: 16,
                              color: canLoad
                                  ? AppColors.mango
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Description text
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                hasItem && hasLocation
                    ? 'Based on Product + Location + Batch'
                    : 'Select Product and Location to load quantity',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
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

class _CountedQuantityField extends ConsumerWidget {
  const _CountedQuantityField();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cycleCountProvider);
    final viewModel = ref.read(cycleCountProvider.notifier);

    return state.when(
      data: (countState) {
        // Get counted quantity (default to 0 if null)
        final countedQty = countState.countedQuantity ?? 0.0;
        final quantity = countedQty.toInt();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            const Text(
              'Counted Quantity',
              style: TextStyle(
                color: AppColors.mango, // Orange color as per design
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            // Quantity input with +/- buttons
            Row(
              children: [
                // Minus button (circular, light grey background)
                InkWell(
                  onTap: () {
                    final newQuantity = (quantity - 1).clamp(0, 9999);
                    viewModel.setCountedQuantity(newQuantity.toDouble());
                  },
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0), // Light grey background
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.remove,
                      color: AppColors.deepGreen,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12), // Spacing
                // Quantity input field (rounded rectangular)
                Expanded(
                  child: Container(
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white, // White background
                      borderRadius: BorderRadius.circular(
                        23,
                      ), // Rounded corners
                      border: Border.all(
                        color: AppColors.mangoLight, // Light orange border
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Quantity number (large, bold, black)
                        Text(
                          quantity.toString(),
                          style: const TextStyle(
                            color: AppColors.deepGreen, // Black/dark green
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12), // Spacing
                // Plus button (circular, orange filled)
                InkWell(
                  onTap: () {
                    final newQuantity = (quantity + 1).clamp(0, 9999);
                    viewModel.setCountedQuantity(newQuantity.toDouble());
                  },
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.mango, // Orange filled
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ],
        );
      },
      loading: () => const SizedBox(height: 80),
      error: (_, __) => const SizedBox(height: 80),
    );
  }
}

class _VarianceField extends ConsumerWidget {
  const _VarianceField();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cycleCountProvider);

    return state.when(
      data: (countState) {
        // Only show variance if both quantities are set
        if (countState.systemQuantity == null ||
            countState.countedQuantity == null) {
          return const SizedBox.shrink(); // Hide if not ready
        }

        final variance = countState.variance;
        if (variance == null || variance == 0.0) {
          return const SizedBox.shrink(); // Hide if no variance
        }

        final isNegative = variance < 0;
        final absoluteVariance = variance.abs();
        final varianceText = isNegative
            ? '-${absoluteVariance.toInt()} units'
            : '+${absoluteVariance.toInt()} units';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE), // Light red background
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
          child: Row(
            children: [
              // Warning icon (red triangular with exclamation)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.error, // Red background
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              // "Variance" label
              const Text(
                'Variance',
                style: TextStyle(
                  color: AppColors.error, // Red text
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              // Variance value
              Text(
                varianceText,
                style: const TextStyle(
                  color: AppColors.error, // Red text
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
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

class _ApprovalMessage extends ConsumerWidget {
  const _ApprovalMessage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countState = ref.watch(cycleCountProvider);
    final currentUser = ref.watch(currentUserProvider);

    return countState.when(
      data: (state) {
        // Only show if there's a variance (both quantities must be set)
        if (state.systemQuantity == null || state.countedQuantity == null) {
          return const SizedBox.shrink();
        }

        // Calculate variance
        final variance = state.variance;
        if (variance == null || variance == 0.0) {
          return const SizedBox.shrink();
        }

        final absoluteVariance = variance.abs();
        final isNegative = variance < 0;

        // Check if user needs approval (clerk/staff, not manager/admin)
        // For testing: if currentUser is null, assume needs approval
        final needsApproval =
            currentUser == null ||
            (!currentUser.isManager && !currentUser.isAdmin);

        // Only show if variance exists and user needs approval
        if (!needsApproval) {
          return const SizedBox.shrink();
        }

        // Elevated card at bottom
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9F0), // Light cream background
            borderRadius: BorderRadius.circular(20), // Rounded corners
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowSoft,
                blurRadius: 15,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Warning message section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Shield icon (orange with lock/exclamation)
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.mango.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        color: AppColors.mango,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Warning text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: AppColors.deepGreen,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                height: 1.4,
                              ),
                              children: [
                                const TextSpan(text: 'Variance of '),
                                TextSpan(
                                  text:
                                      '${isNegative ? '-' : '+'}${absoluteVariance.toInt()}',
                                  style: const TextStyle(
                                    color: AppColors
                                        .error, // Red for variance number
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const TextSpan(
                                  text: ' requires Manager Approval.',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Submitting will create a pending approval request.',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Information message (Clerks create pending approval)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.mangoLight.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.mango,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Clerks create pending approval. Managers/Admin can approve.',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Action buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    // Cancel button (light grey)
                    Expanded(child: _CancelButton()),
                    const SizedBox(width: 12),
                    // Adjust Stock button (orange with arrow)
                    Expanded(flex: 2, child: _AdjustStockButton()),
                  ],
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

class _CancelButton extends ConsumerWidget {
  const _CancelButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0), // Light grey background
          borderRadius: BorderRadius.circular(999), // Fully rounded
        ),
        child: const Center(
          child: Text(
            'Cancel',
            style: TextStyle(
              color: AppColors.deepGreen,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}

class _AdjustStockButton extends ConsumerWidget {
  const _AdjustStockButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countState = ref.watch(cycleCountProvider);
    final viewModel = ref.read(cycleCountProvider.notifier);

    return countState.when(
      data: (state) {
        final isSubmitting = state.isSubmitting;
        final canSubmit =
            state.systemQuantity != null &&
            state.countedQuantity != null &&
            state.selectedItem != null &&
            state.selectedLocationId != null;

        return InkWell(
          onTap: canSubmit && !isSubmitting
              ? () async {
                  // Call adjustStockFromCount which will create pending approval for clerks
                  final success = await viewModel.adjustStockFromCount();
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Stock adjustment request created (pending approval)',
                        ),
                        backgroundColor: AppColors.success,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    Navigator.of(context).pop();
                  } else if (context.mounted) {
                    // Show error if any
                    final errorState = ref.read(cycleCountProvider);
                    errorState.whenData((s) {
                      if (s.error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(s.error!),
                            backgroundColor: AppColors.error,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    });
                  }
                }
              : null,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: canSubmit && !isSubmitting
                  ? AppColors
                        .mango // Orange background
                  : AppColors.borderSoft, // Disabled grey
              borderRadius: BorderRadius.circular(999), // Fully rounded
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSubmitting)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else ...[
                  const Text(
                    'Adjust Stock',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
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
        );
      },
      loading: () => const SizedBox(height: 48),
      error: (_, __) => const SizedBox(height: 48),
    );
  }
}

class _FooterButtons extends ConsumerWidget {
  const _FooterButtons();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countState = ref.watch(cycleCountProvider);
    final viewModel = ref.read(cycleCountProvider.notifier);
    final currentUser = ref.watch(currentUserProvider);

    return countState.when(
      data: (state) {
        final isSubmitting = state.isSubmitting;
        final canSave =
            state.selectedItem != null &&
            state.selectedLocationId != null &&
            state.countedQuantity != null;

        // Check if user can approve directly (manager/admin)
        final canApproveDirectly =
            currentUser != null &&
            (currentUser.isManager || currentUser.isAdmin);

        // Check if there's a variance that needs approval
        final hasVariance = state.variance != null && state.variance != 0.0;
        final needsApproval = hasVariance && !canApproveDirectly;

        return Row(
          children: [
            // Cancel button
            Expanded(
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0), // Light grey background
                    borderRadius: BorderRadius.circular(999), // Fully rounded
                  ),
                  child: const Center(
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.deepGreen,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Adjust Stock button (only show if there's a variance)
            if (hasVariance)
              Expanded(
                flex: 2,
                child: InkWell(
                  onTap: canSave && !isSubmitting
                      ? () async {
                          final success = await viewModel
                              .adjustStockFromCount();
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  needsApproval
                                      ? 'Stock adjustment request created (pending approval)'
                                      : 'Stock adjusted successfully',
                                ),
                                backgroundColor: AppColors.success,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            Navigator.of(context).pop();
                          } else if (context.mounted) {
                            final errorState = ref.read(cycleCountProvider);
                            errorState.whenData((s) {
                              if (s.error != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(s.error!),
                                    backgroundColor: AppColors.error,
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              }
                            });
                          }
                        }
                      : null,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: canSave && !isSubmitting
                          ? AppColors
                                .mango // Orange background
                          : AppColors.borderSoft, // Disabled grey
                      borderRadius: BorderRadius.circular(999), // Fully rounded
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isSubmitting)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        else ...[
                          Text(
                            needsApproval
                                ? 'Adjust Stock (REQUIRES APPROVAL)'
                                : 'Adjust Stock',
                            style: TextStyle(
                              color: canSave && !isSubmitting
                                  ? Colors.white
                                  : AppColors.textMuted,
                              fontWeight: FontWeight.w800,
                              fontSize: needsApproval ? 13 : 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (!needsApproval) ...[
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              )
            else
              // Save Count button (when no variance or variance is 0)
              Expanded(
                flex: 2,
                child: InkWell(
                  onTap: canSave && !isSubmitting
                      ? () async {
                          // Save count without adjusting stock
                          final success = await viewModel.createCycleCount();
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cycle count saved successfully'),
                                backgroundColor: AppColors.success,
                                duration: Duration(seconds: 2),
                              ),
                            );
                            Navigator.of(context).pop();
                          } else if (context.mounted) {
                            final errorState = ref.read(cycleCountProvider);
                            errorState.whenData((s) {
                              if (s.error != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(s.error!),
                                    backgroundColor: AppColors.error,
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              }
                            });
                          }
                        }
                      : null,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: canSave && !isSubmitting
                          ? AppColors
                                .mango // Orange background
                          : AppColors.borderSoft, // Disabled grey
                      borderRadius: BorderRadius.circular(999), // Fully rounded
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isSubmitting)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        else ...[
                          const Text(
                            'Save Count',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.check_rounded,
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
      loading: () => const SizedBox(height: 52),
      error: (_, __) => const SizedBox(height: 52),
    );
  }
}
