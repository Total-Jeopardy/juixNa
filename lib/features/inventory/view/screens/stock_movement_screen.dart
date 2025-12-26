import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:juix_na/app/app_colors.dart';
import 'package:juix_na/core/network/api_result.dart';
import 'package:juix_na/core/utils/error_display.dart';
import 'package:juix_na/features/inventory/model/inventory_models.dart';
import 'package:juix_na/features/inventory/viewmodel/stock_movement_state.dart';
import 'package:juix_na/features/inventory/viewmodel/stock_movement_vm.dart';

/// Stock Movement Screen - Skeleton Framework
///
/// Structure based on design:
/// 1. AppBar (back button, title, theme toggle)
/// 2. Online Status Indicator
/// 3. Movement Toggle (Stock-In / Stock-Out)
/// 4. Form Card
///    - Date picker
///    - Product picker
///    - Batch # field (conditional)
///    - Quantity field
///    - Unit Cost + Location (inline row)
///    - Reason field
///    - Reference field
///    - Notes/Reason text area
/// 5. View Recent Movements link
/// 6. Footer buttons (Cancel, Save Movement)

class StockMovementScreen extends ConsumerStatefulWidget {
  const StockMovementScreen({super.key});

  @override
  ConsumerState<StockMovementScreen> createState() =>
      _StockMovementScreenState();
}

class _StockMovementScreenState extends ConsumerState<StockMovementScreen> {
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
              _AppBar(),

              const SizedBox(height: 12),

              Center(child: _OnlineStatusIndicator()),

              const SizedBox(height: 12),

              _MovementToggle(),

              const SizedBox(height: 16),

              _FormCard(
                children: [
                  _DateField(),
                  _ProductField(),
                  _BatchField(),
                  _QuantityField(),
                  const SizedBox(height: 12),
                  _UnitCostLocationRow(),
                  const SizedBox(height: 12),
                  _NotesReasonField(),
                  const SizedBox(height: 12),
                  _ViewRecentMovementsLink(),
                ],
              ),

              const SizedBox(height: 18),

              _FooterButtons(),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// PLACEHOLDER WIDGETS - To be implemented step by step
// ============================================================================

class _AppBar extends ConsumerWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(stockMovementProvider.notifier);

    return Row(
      children: [
        // Back button (left arrow)
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.deepGreen),
        ),

        // Title (centered)
        const Expanded(
          child: Text(
            'Stock Movement',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.deepGreen,
            ),
          ),
        ),

        // refresh button (right side)
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: AppColors.mangoLight.withValues(
              alpha: 0.2,
            ), // Light orange background
            borderRadius: BorderRadius.circular(20), // Pill shape
          ),
          child: TextButton.icon(
            onPressed: () async {
              // Refresh products with current location (if any)
              final state = ref.read(stockMovementProvider);
              state.whenData((currentState) async {
                await viewModel.loadProducts(
                  locationId: currentState.selectedLocationId,
                );
              });
            },
            label: const Text(
              'Refresh',
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
        color: Colors.white, // Light off-white background
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
    );
  }
}

class _MovementToggle extends ConsumerWidget {
  const _MovementToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(stockMovementProvider);
    final viewModel = ref.read(stockMovementProvider.notifier);

    return state.when(
      data: (movementState) {
        final isStockOut =
            movementState.movementType == StockMovementType.stockOut;

        return LayoutBuilder(
          builder: (context, constraints) {
            final halfWidth = constraints.maxWidth / 2;

            return Container(
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFE9DDCC), // Light beige/cream background
                borderRadius: BorderRadius.circular(999), // Fully rounded ends
              ),
              child: Stack(
                children: [
                  // Animated orange selector thumb
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    left: isStockOut ? halfWidth : 4,
                    right: isStockOut ? 4 : halfWidth,
                    top: 4,
                    bottom: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.mangoGradientStart,
                            AppColors.mangoGradientEnd,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.mango.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Text labels
                  Row(
                    children: [
                      // Stock-In (left)
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            viewModel.setMovementType(
                              StockMovementType.stockIn,
                            );
                          },
                          child: Center(
                            child: Text(
                              'Stock-In',
                              style: TextStyle(
                                color: isStockOut
                                    ? AppColors
                                          .deepGreen // Dark text when unselected
                                    : Colors.white, // White text when selected
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Stock-Out (right)
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            viewModel.setMovementType(
                              StockMovementType.stockOut,
                            );
                          },
                          child: Center(
                            child: Text(
                              'Stock-Out',
                              style: TextStyle(
                                color: isStockOut
                                    ? Colors
                                          .white // White text when selected
                                    : AppColors
                                          .deepGreen, // Dark text when unselected
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const SizedBox(
        height: 46,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox(height: 46),
    );
  }
}

class _FormCard extends StatelessWidget {
  final List<Widget> children;
  const _FormCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9F0), // Light cream/off-white background
        borderRadius: BorderRadius.circular(24), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _DateField extends ConsumerWidget {
  const _DateField();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(stockMovementProvider);
    final viewModel = ref.read(stockMovementProvider.notifier);

    return state.when(
      data: (movementState) {
        final dateLabel = DateFormat('MM/dd/yyyy').format(movementState.date);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
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
                    initialDate: movementState.date,
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
          ),
        );
      },
      loading: () => const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox(height: 80),
    );
  }
}

class _ProductField extends ConsumerWidget {
  const _ProductField();

  Future<void> _showProductPicker(
    BuildContext context,
    StockMovementState state,
    StockMovementViewModel viewModel,
  ) async {
    if (state.isLoadingItems) return;

    // Load products if not already loaded
    if (state.availableItems.isEmpty && !state.isLoadingItems) {
      viewModel.loadProducts();
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
                                      item.sku,
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
    final state = ref.watch(stockMovementProvider);
    final viewModel = ref.read(stockMovementProvider.notifier);

    return state.when(
      data: (movementState) {
        final productName =
            movementState.selectedItem?.name ?? 'Select product';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
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
                onTap: movementState.isLoadingItems
                    ? null
                    : () =>
                          _showProductPicker(context, movementState, viewModel),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: movementState.selectedItem != null ? 80 : 54,
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
                  child: movementState.selectedItem != null
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
                                    movementState.selectedItem != null &&
                                        movementState
                                            .selectedItem!
                                            .sku
                                            .isNotEmpty
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
                                    movementState.selectedItem!.name,
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
                                    'SKU: ${movementState.selectedItem!.sku} • ${movementState.selectedItem!.unit}',
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
                                productName,
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            // Dropdown icon (orange)
                            if (movementState.isLoadingItems)
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
              // Error message for product field
              if (movementState.selectedItem == null &&
                  (movementState.quantity > 0 ||
                      movementState.selectedLocationId != null ||
                      movementState.reason.isNotEmpty)) ...[
                const SizedBox(height: 6),
                const Text(
                  'Product selection is required',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox(height: 80),
    );
  }
}

class _BatchField extends ConsumerWidget {
  const _BatchField();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(stockMovementProvider);

    return state.when(
      data: (movementState) {
        // Show batch field only if product is selected
        // In the future, check if product.requiresBatch
        final requiresBatch = movementState.selectedItem != null;
        // For now, assume batch is required if product is selected and not filled
        final batchNumber = null; // movementState.batchNumber;
        final hasError = requiresBatch && batchNumber == null;
        final batchValue = batchNumber ?? 'Select Batch';

        // Always show the field for now (will be conditional based on product batch-tracking requirement)
        // if (!requiresBatch) {
        //   return const SizedBox.shrink(); // Hide if no product selected
        // }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label with "Required" indicator
              Row(
                children: [
                  const Text(
                    'Batch #',
                    style: TextStyle(
                      color: AppColors.deepGreen,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Required',
                    style: TextStyle(
                      color: hasError ? AppColors.error : AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Input field
              InkWell(
                onTap: () {
                  ErrorDisplay.showSuccess(
                    context,
                    'Batch picker will be implemented',
                    duration: const Duration(seconds: 2),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white, // White background
                    borderRadius: BorderRadius.circular(23), // Rounded corners
                    border: Border.all(
                      color: hasError
                          ? AppColors
                                .error // Red border when error
                          : AppColors.mangoLight, // Light orange border
                      width: hasError ? 1.2 : 1,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      // Batch text
                      Expanded(
                        child: Text(
                          batchValue,
                          style: TextStyle(
                            color: batchNumber != null
                                ? AppColors.deepGreen
                                : AppColors.textMuted,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      // Error icon or dropdown
                      if (hasError)
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 16,
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
              // Error messages
              if (hasError) ...[
                const SizedBox(height: 6),
                const Text(
                  'Batch selection is required.',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'This product is batch-tracked.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const SizedBox(height: 80),
      error: (_, __) => const SizedBox(height: 80),
    );
  }
}

class _QuantityField extends ConsumerWidget {
  const _QuantityField();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(stockMovementProvider);
    final viewModel = ref.read(stockMovementProvider.notifier);

    return state.when(
      data: (movementState) {
        // Always show quantity field for now (will be conditional based on product selection)
        // if (movementState.selectedItem == null) {
        //   return const SizedBox.shrink();
        // }

        // Show loading while fetching available stock
        if (movementState.isLoadingAvailableStock) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
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
                Container(
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.mangoLight, width: 1),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.mango,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final quantity = movementState.quantity.toInt();
        // Available stock only shown when location is selected
        final available = movementState.selectedLocationId != null
            ? (movementState.availableStock?.toInt() ?? 0)
            : null;

        // Red border only shows when:
        // 1. Product and location are selected
        // 2. Available stock is loaded
        // 3. Quantity exceeds available stock (for stock-out)
        final exceeds = movementState.quantityExceedsAvailable;
        final hasError =
            movementState.selectedItem != null &&
            movementState.selectedLocationId != null &&
            movementState.availableStock != null &&
            exceeds;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label
              const Text(
                'Quantity',
                style: TextStyle(
                  color: AppColors.deepGreen,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              // Quantity input with +/- buttons
              Row(
                children: [
                  // Minus button (circular, beige border)
                  InkWell(
                    onTap: () {
                      final newQuantity = (quantity - 1).clamp(0, 9999);
                      viewModel.setQuantity(newQuantity.toDouble());
                    },
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.borderSoft, // Beige border
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.remove,
                        color: AppColors.deepGreen,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12), // Width/spacing
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
                          color: hasError
                              ? AppColors
                                    .error // Red border when error
                              : AppColors.mangoLight, // Light orange border
                          width: hasError ? 1.2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Quantity number
                          Text(
                            quantity.toString(),
                            style: const TextStyle(
                              color: AppColors.deepGreen,
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // "Units" label
                          Text(
                            'Units',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12), // Width/spacing
                  // Plus button (circular, orange filled)
                  InkWell(
                    onTap: () {
                      final newQuantity = (quantity + 1).clamp(0, 9999);
                      viewModel.setQuantity(newQuantity.toDouble());
                    },
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.mango, // Orange filled
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              // Error message and available stock
              const SizedBox(height: 6),
              Row(
                children: [
                  // Error message (use state's quantityError getter)
                  if (movementState.quantityError != null)
                    Expanded(
                      child: Text(
                        movementState.quantityError!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const Spacer(),
                  // Available stock (only show when location is selected)
                  if (available != null)
                    Text(
                      'Available: $available',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(height: 80),
      error: (_, __) => const SizedBox(height: 80),
    );
  }
}

class _UnitCostLocationRow extends ConsumerWidget {
  const _UnitCostLocationRow();

  Future<void> _showLocationPicker(
    BuildContext context,
    StockMovementState state,
    StockMovementViewModel viewModel,
  ) async {
    if (state.isLoadingLocations) return;

    // Load locations if not already loaded
    if (state.availableLocations.isEmpty && !state.isLoadingLocations) {
      // Locations should be loaded when ViewModel initializes
    }

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
    final state = ref.watch(stockMovementProvider);
    final viewModel = ref.read(stockMovementProvider.notifier);

    return state.when(
      data: (movementState) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Unit Cost (left) - smaller width
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label
                    const Text(
                      'Unit Cost',
                      style: TextStyle(
                        color: AppColors.deepGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Input field (locked)
                    Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFFE9DDCC,
                        ), // Light beige background
                        borderRadius: BorderRadius.circular(
                          23,
                        ), // Rounded corners
                        border: Border.all(
                          color: AppColors.borderSoft,
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          // Unit cost text
                          Expanded(
                            child: Text(
                              '\$ 4.50', // Placeholder - unit cost not yet available from API
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          // Lock icon
                          const Icon(
                            Icons.lock_outline,
                            color: AppColors.textMuted,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                    // Permission text
                    const SizedBox(height: 6),
                    const Text(
                      'MANAGER/ADMIN ONLY',
                      style: TextStyle(
                        color: AppColors.deepGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12), // Spacing between fields
              // Location (right) - larger width
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label - aligned with Unit Cost label
                    const Text(
                      'Location',
                      style: TextStyle(
                        color: AppColors.deepGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Selection field - aligned with Unit Cost field
                    InkWell(
                      onTap: movementState.isLoadingLocations
                          ? null
                          : () => _showLocationPicker(
                              context,
                              movementState,
                              viewModel,
                            ),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        height: 54, // Same height as Unit Cost field
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
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          children: [
                            // Location text
                            Expanded(
                              child: Text(
                                movementState.selectedLocation?.name ??
                                    'Select location',
                                style: TextStyle(
                                  color: movementState.selectedLocation != null
                                      ? AppColors.deepGreen
                                      : AppColors.textMuted,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Dropdown icon (orange chevrons)
                            if (movementState.isLoadingLocations)
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
                    // Error message for location field
                    if (movementState.selectedLocationId == null &&
                        (movementState.selectedItem != null ||
                            movementState.quantity > 0 ||
                            movementState.reason.isNotEmpty)) ...[
                      const SizedBox(height: 6),
                      const Text(
                        'Location selection is required',
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ] else
                      // Empty space to match Unit Cost's "MANAGER/ADMIN ONLY" text height
                      const SizedBox(
                        height: 29,
                      ), // 6 (spacing) + 11 (text) + 12 (extra)
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(height: 80),
      error: (_, __) => const SizedBox(height: 80),
    );
  }
}

class _NotesReasonField extends ConsumerStatefulWidget {
  const _NotesReasonField();

  @override
  ConsumerState<_NotesReasonField> createState() => _NotesReasonFieldState();
}

class _NotesReasonFieldState extends ConsumerState<_NotesReasonField> {
  late TextEditingController _controller;
  static const int _maxLength = 250;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateControllerIfChanged(String newValue) {
    if (_controller.text != newValue) {
      _controller.value = TextEditingValue(
        text: newValue,
        selection: TextSelection.collapsed(offset: newValue.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stockMovementProvider);
    final viewModel = ref.read(stockMovementProvider.notifier);

    return state.when(
      data: (movementState) {
        // Update controller if state changed externally
        _updateControllerIfChanged(movementState.note ?? '');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            const Text(
              'Notes / Reason',
              style: TextStyle(
                color: AppColors.deepGreen,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            // Text input field
            Container(
              decoration: BoxDecoration(
                color: Colors.white, // White background
                borderRadius: BorderRadius.circular(16), // Rounded corners
                border: Border.all(
                  color: AppColors.borderSoft, // Light beige border
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _controller,
                maxLength: _maxLength,
                maxLines: 5,
                minLines: 5,
                style: const TextStyle(
                  color: AppColors.deepGreen,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'Describe the reason for stock adjustment...',
                  hintStyle: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  counterText: '', // Hide default counter
                ),
                onChanged: (value) {
                  // Set both reason and note from the Notes/Reason field
                  // Reason is required by API, note is optional
                  if (value.isEmpty) {
                    viewModel.setReason('');
                    viewModel.setNote(null);
                  } else {
                    // Use the input as reason (required field)
                    // Also set it as note for additional context
                    viewModel.setReason(value);
                    viewModel.setNote(value);
                  }
                },
                buildCounter:
                    (
                      BuildContext context, {
                      required int currentLength,
                      required int? maxLength,
                      required bool isFocused,
                    }) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 16, bottom: 12),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            '$currentLength/$maxLength',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
              ),
            ),
            // Error message for reason field
            if (movementState.reason.isEmpty &&
                (movementState.selectedItem != null ||
                    movementState.selectedLocationId != null ||
                    movementState.quantity > 0)) ...[
              const SizedBox(height: 6),
              const Text(
                'Reason is required',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        );
      },
      loading: () => const SizedBox(height: 120),
      error: (_, __) => const SizedBox(height: 120),
    );
  }
}

class _ViewRecentMovementsLink extends StatelessWidget {
  const _ViewRecentMovementsLink();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to transfer history screen
        context.push('/inventory/transfer/history');
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // History icon
            const Icon(
              Icons.history_rounded,
              color: AppColors.deepGreen,
              size: 20,
            ),
            const SizedBox(width: 8),
            // Text
            const Text(
              'View Recent Movements',
              style: TextStyle(
                color: AppColors.deepGreen,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 8),
            // Filter icon
            const Icon(
              Icons.filter_list_rounded,
              color: AppColors.deepGreen,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}


class _FooterButtons extends ConsumerWidget {
  const _FooterButtons();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(stockMovementProvider);
    final viewModel = ref.read(stockMovementProvider.notifier);

    return state.when(
      data: (movementState) {
        final isValid = movementState.isValid;
        final isSubmitting = movementState.isSubmitting;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
          child: Row(
            children: [
              // Cancel button (left)
              Expanded(
                child: InkWell(
                  onTap: isSubmitting
                      ? null
                      : () {
                          Navigator.of(context).pop();
                        },
                  borderRadius: BorderRadius.circular(999), // Fully rounded
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white, // White background
                      borderRadius: BorderRadius.circular(999), // Fully rounded
                      border: Border.all(
                        color: AppColors.borderSoft, // Light border
                        width: 1,
                      ),
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
              const SizedBox(width: 12), // Spacing between buttons
              // Save Movement button (right)
              Expanded(
                flex: 2, // Wider than Cancel button
                child: InkWell(
                  onTap: (isValid && !isSubmitting)
                      ? () async {
                          final success = await viewModel.createStockMovement();
                          if (!context.mounted) return;

                          if (success) {
                            // Show success message
                            ErrorDisplay.showSuccess(
                              context,
                              'Stock movement saved successfully',
                            );
                            // Navigate back on success
                            Navigator.of(context).maybePop();
                          } else {
                            // Show error message (read fresh state for error)
                            final currentState = ref.read(
                              stockMovementProvider,
                            );
                            currentState.whenData((state) {
                              if (state.error != null && context.mounted) {
                                // Convert string error to ApiError for ErrorDisplay
                                ErrorDisplay.showError(
                                  context,
                                  ApiError(
                                    type: ApiErrorType.unknown,
                                    message: state.error!,
                                  ),
                                );
                              }
                            });
                          }
                        }
                      : null,
                  borderRadius: BorderRadius.circular(999), // Fully rounded
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: (isValid && !isSubmitting)
                          ? AppColors
                                .mango // Orange when enabled
                          : const Color(0xFFE0E0E0), // Light gray when disabled
                      borderRadius: BorderRadius.circular(999), // Fully rounded
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Button text
                        Text(
                          'Save Movement',
                          style: TextStyle(
                            color: (isValid && !isSubmitting)
                                ? Colors
                                      .white // White text when enabled
                                : const Color(
                                    0xFF9E9E9E,
                                  ), // Dark gray when disabled
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        // Disabled icon or loading indicator
                        if (!isValid || isSubmitting) ...[
                          const SizedBox(width: 8),
                          if (isSubmitting)
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF9E9E9E),
                              ),
                            )
                          else
                            Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF9E9E9E),
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(height: 56),
      error: (_, __) => const SizedBox(height: 56),
    );
  }
}
