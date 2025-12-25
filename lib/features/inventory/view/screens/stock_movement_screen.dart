import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:juix_na/app/app_colors.dart';
import 'package:juix_na/app/theme_controller.dart';
import 'package:juix_na/features/inventory/model/inventory_models.dart';
import 'package:juix_na/features/inventory/viewmodel/stock_movement_state.dart';
import 'package:juix_na/features/inventory/viewmodel/stock_movement_vm.dart';

class StockMovementScreen extends ConsumerStatefulWidget {
  const StockMovementScreen({super.key});

  @override
  ConsumerState<StockMovementScreen> createState() =>
      _StockMovementScreenState();
}

class _StockMovementScreenState extends ConsumerState<StockMovementScreen> {
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    _reasonController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  /// Update controller text only if the value has changed.
  /// This prevents cursor jumping on every build.
  void _updateControllerIfChanged(
    TextEditingController controller,
    String newValue,
  ) {
    if (controller.text != newValue) {
      final selection = controller.selection;
      controller.text = newValue;
      // Restore selection if it was valid, otherwise place at end
      if (selection.isValid && selection.end <= newValue.length) {
        controller.selection = selection;
      } else {
        controller.selection = TextSelection.collapsed(offset: newValue.length);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch ViewModel state
    final movementState = ref.watch(stockMovementProvider);
    final viewModel = ref.read(stockMovementProvider.notifier);

    return movementState.when(
      data: (state) => _buildContent(context, state, viewModel),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Error: ${error.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => viewModel.clearError(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    StockMovementState state,
    StockMovementViewModel viewModel,
  ) {
    // Update controllers only when state values change (not on every build)
    _updateControllerIfChanged(_reasonController, state.reason);
    _updateControllerIfChanged(_referenceController, state.reference ?? '');
    _updateControllerIfChanged(_notesController, state.note ?? '');

    final dateLabel = DateFormat('MM/dd/yyyy').format(state.date);
    final exceeds = state.quantityExceedsAvailable;
    final enabled = state.isValid && !state.isSubmitting;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7EE),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(online: true),
              const SizedBox(height: 12),
              _MovementToggle(
                movement: state.movementType,
                onChanged: (m) => viewModel.setMovementType(m),
              ),
              const SizedBox(height: 16),
              if (state.error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.errorSoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: AppColors.error),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          state.error!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        color: AppColors.error,
                        onPressed: () => viewModel.clearError(),
                      ),
                    ],
                  ),
                ),
              ],
              _FormCard(
                children: [
                  _PickerField(
                    label: 'Date',
                    value: dateLabel,
                    icon: Icons.calendar_today_outlined,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: state.date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        viewModel.setDate(picked);
                      }
                    },
                  ),
                  _PickerField(
                    label: 'Product',
                    value: state.selectedItem?.name ?? 'Select product',
                    icon: Icons.expand_more_rounded,
                    onTap: state.isLoadingItems
                        ? null
                        : () => _showProductPicker(context, state, viewModel),
                    isLoading: state.isLoadingItems,
                  ),
                  if (state.selectedItem != null &&
                      state.selectedLocationId != null) ...[
                    if (state.isLoadingAvailableStock)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else
                      _QuantityField(
                        value: state.quantity.toInt(),
                        available: state.availableStock?.toInt() ?? 0,
                        exceeds: exceeds,
                        onChange: (v) => viewModel.setQuantity(v.toDouble()),
                        errorText: state.quantityError,
                      ),
                  ],
                  const SizedBox(height: 12),
                  _PickerField(
                    label: 'Location',
                    value: state.selectedLocation?.name ?? 'Select location',
                    icon: Icons.expand_more_rounded,
                    onTap: state.isLoadingLocations
                        ? null
                        : () => _showLocationPicker(context, state, viewModel),
                    isLoading: state.isLoadingLocations,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _reasonController,
                    decoration: InputDecoration(
                      labelText: 'Reason *',
                      hintText: 'e.g., SALE, BREAKAGE, ADJUSTMENT',
                      errorText: state.fieldErrors['reason'],
                    ),
                    onChanged: (value) => viewModel.setReason(value),
                    enabled: !state.isSubmitting,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _referenceController,
                    decoration: InputDecoration(
                      labelText: 'Reference (optional)',
                      hintText: 'e.g., SALE-2025-001',
                      errorText: state.fieldErrors['reference'],
                    ),
                    onChanged: (value) =>
                        viewModel.setReference(value.isEmpty ? null : value),
                    enabled: !state.isSubmitting,
                  ),
                  const SizedBox(height: 12),
                  _NotesField(
                    controller: _notesController,
                    onChanged: (value) =>
                        viewModel.setNote(value.isEmpty ? null : value),
                    enabled: !state.isSubmitting,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _Footer(
                enabled: enabled,
                isLoading: state.isSubmitting,
                onCancel: () => Navigator.of(context).maybePop(),
                onSave: () async {
                  await viewModel.createStockMovement();
                  if (mounted) {
                    final newState = ref.read(stockMovementProvider).value;
                    if (newState?.isValid == true && newState?.error == null) {
                      Navigator.of(context).maybePop();
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods for pickers
  void _showProductPicker(
    BuildContext context,
    StockMovementState state,
    StockMovementViewModel viewModel,
  ) {
    // Load products if not already loaded
    if (state.availableItems.isEmpty && !state.isLoadingItems) {
      viewModel.loadProducts();
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Product',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (state.isLoadingItems)
              const Center(child: CircularProgressIndicator())
            else if (state.availableItems.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('No products available'),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.availableItems.length,
                  itemBuilder: (context, index) {
                    final item = state.availableItems[index];
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text('SKU: ${item.sku}'),
                      trailing: Text(
                        '${item.totalQuantity ?? item.currentStock ?? 0.0} ${item.unit}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      onTap: () {
                        viewModel.selectItem(item);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showLocationPicker(
    BuildContext context,
    StockMovementState state,
    StockMovementViewModel viewModel,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Location',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (state.availableLocations.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('No locations available'),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                itemCount: state.availableLocations.length,
                itemBuilder: (context, index) {
                  final location = state.availableLocations[index];
                  return ListTile(
                    title: Text(location.name),
                    subtitle: location.description != null
                        ? Text(location.description!)
                        : null,
                    leading: Radio<int?>(
                      value: location.id,
                      groupValue: state.selectedLocationId,
                      onChanged: (value) {
                        viewModel.selectLocation(value);
                        Navigator.pop(context);
                      },
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

class _Header extends ConsumerWidget {
  final bool online;
  const _Header({required this.online});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeNotifier = ref.read(themeControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: Icon(
                Icons.arrow_back,
                color: isDark ? Colors.white : AppColors.deepGreen,
              ),
            ),
            const SizedBox(width: 4),
            const Expanded(
              child: Text(
                'Stock Movement',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.deepGreen,
                ),
              ),
            ),
            // Online status indicator (informational only - no sync needed for online-only app)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: online ? AppColors.successSoft : AppColors.errorSoft,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: online
                      ? AppColors.success.withOpacity(0.3)
                      : AppColors.error.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 4,
                    backgroundColor: online
                        ? AppColors.success
                        : AppColors.error,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    online ? 'Online' : 'Offline',
                    style: TextStyle(
                      color: online ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(
                isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                color: AppColors.deepGreen,
              ),
              onPressed: themeNotifier.toggle,
            ),
          ],
        ),
        // Connectivity status (informational only - app requires online connection)
        if (!online) ...[
          const SizedBox(height: 10),
          _InfoPill(
            icon: Icons.wifi_off,
            text: 'No internet connection - Please check your network',
            background: AppColors.errorSoft,
            iconColor: AppColors.error,
          ),
        ],
      ],
    );
  }
}

class _MovementToggle extends StatelessWidget {
  final StockMovementType movement;
  final ValueChanged<StockMovementType> onChanged;
  const _MovementToggle({required this.movement, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFFE9DDCC),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          _Segment(
            label: 'Stock-In',
            selected: movement == StockMovementType.stockIn,
            onTap: () => onChanged(StockMovementType.stockIn),
          ),
          _Segment(
            label: 'Stock-Out',
            selected: movement == StockMovementType.stockOut,
            onTap: () => onChanged(StockMovementType.stockOut),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            gradient: selected ? AppGradients.primary : null,
            color: selected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onTap,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: selected ? Colors.white : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final List<Widget> children;
  const _FormCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(children: children),
    );
  }
}

class _PickerField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isLoading;

  const _PickerField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: isLoading ? null : onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? AppColors.borderSubtle.withOpacity(0.3)
                      : AppColors.borderSoft,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Text(
                            value,
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.deepGreen,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                  ),
                  Icon(icon, color: AppColors.mango),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BatchField extends StatelessWidget {
  final String? value;
  final bool required;
  final VoidCallback onTap;
  final String? errorText;
  final String? helper;
  const _BatchField({
    required this.value,
    required this.required,
    required this.onTap,
    this.errorText,
    this.helper,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasError = errorText != null;
    final borderColor = hasError
        ? AppColors.error
        : isDark
        ? AppColors.borderSubtle.withOpacity(0.3)
        : AppColors.borderSoft;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Batch #',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                required ? 'Required' : 'Optional',
                style: TextStyle(
                  color: hasError ? AppColors.error : AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 1.2),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value ?? 'Select Batch',
                      style: TextStyle(
                        color: hasError
                            ? AppColors.error
                            : isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.deepGreen,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    hasError ? Icons.error_outline : Icons.expand_more_rounded,
                    color: hasError ? AppColors.error : AppColors.mango,
                  ),
                ],
              ),
            ),
          ),
          if (hasError) ...[
            const SizedBox(height: 6),
            Text(
              errorText!,
              style: const TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
          if (helper != null) ...[
            const SizedBox(height: 4),
            Text(
              helper!,
              style: const TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuantityField extends StatelessWidget {
  final int value;
  final int available;
  final bool exceeds;
  final ValueChanged<int> onChange;
  final String? errorText;

  const _QuantityField({
    required this.value,
    required this.available,
    required this.exceeds,
    required this.onChange,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = exceeds
        ? AppColors.error
        : isDark
        ? AppColors.borderSubtle.withOpacity(0.3)
        : AppColors.borderSoft;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quantity',
            style: TextStyle(
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 58,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: borderColor, width: 1.2),
            ),
            child: Row(
              children: [
                const SizedBox(width: 6),
                _CircleButton(
                  icon: Icons.remove,
                  onTap: () => onChange((value - 1).clamp(0, 9999)),
                ),
                Expanded(
                  child: Text(
                    value.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.deepGreen,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkPill : AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Text(
                    'Units',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _CircleButton(
                  icon: Icons.add,
                  fill: true,
                  onTap: () => onChange((value + 1).clamp(0, 9999)),
                ),
                const SizedBox(width: 6),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              if (exceeds)
                const Text(
                  'Exceeds available stock',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              const Spacer(),
              Text(
                'Available: $available',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InlineRow extends StatelessWidget {
  final Widget left;
  final Widget right;
  const _InlineRow({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: left),
          const SizedBox(width: 12),
          Expanded(child: right),
        ],
      ),
    );
  }
}

class _ChipField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool locked;
  final String? caption;
  const _ChipField({
    required this.label,
    required this.value,
    required this.icon,
    this.locked = false,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 54,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? AppColors.borderSubtle.withOpacity(0.3)
                  : AppColors.borderSoft,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.textMuted),
              const SizedBox(width: 10),
              Text(
                value,
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.deepGreen,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              if (locked)
                const Icon(
                  Icons.lock_outline,
                  size: 16,
                  color: AppColors.textMuted,
                ),
            ],
          ),
        ),
        if (caption != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              caption!,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
      ],
    );
  }
}

class _NotesField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  const _NotesField({
    required this.controller,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes / Reason',
          style: TextStyle(
            color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? AppColors.borderSubtle.withOpacity(0.3)
                  : AppColors.borderSoft,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, __) {
              return Column(
                children: [
                  TextField(
                    controller: controller,
                    onChanged: onChanged,
                    enabled: enabled,
                    maxLines: 5,
                    maxLength: 250,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      counterText: '',
                      hintText: 'Describe the reason for stock adjustment...',
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${value.text.length}/250',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RecentMovements extends StatelessWidget {
  final VoidCallback onTap;
  const _RecentMovements({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 18,
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            ),
            const SizedBox(width: 8),
            Text(
              'View Recent Movements',
              style: TextStyle(
                color: isDark ? AppColors.darkTextMuted : AppColors.deepGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final bool enabled;
  final bool isLoading;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  const _Footer({
    required this.enabled,
    required this.onCancel,
    required this.onSave,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Color(0xFFDDDBD7)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: (enabled && !isLoading) ? onSave : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              backgroundColor: enabled
                  ? AppColors.mango
                  : const Color(0xFFC7C6C5),
              foregroundColor: Colors.white,
              elevation: enabled ? 3 : 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Save Movement',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                SizedBox(width: 8),
                Icon(Icons.check_rounded, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color background;
  final Color? iconColor;
  const _InfoPill({
    required this.icon,
    required this.text,
    required this.background,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: isDark
                ? AppColors.darkSurface
                : Colors.white.withOpacity(0.85),
            child: Icon(
              icon,
              size: 16,
              color: iconColor ?? AppColors.deepGreen,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : AppColors.deepGreen,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool fill;
  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.fill = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fill ? AppColors.mango : Colors.transparent,
          border: fill ? null : Border.all(color: AppColors.borderSoft),
        ),
        child: Icon(
          icon,
          color: fill ? Colors.white : AppColors.deepGreen,
          size: 18,
        ),
      ),
    );
  }
}
