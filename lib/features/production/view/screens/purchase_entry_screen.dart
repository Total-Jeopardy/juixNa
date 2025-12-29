import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:juix_na/app/app_colors.dart';
import 'package:juix_na/features/production/model/production_models.dart';
import 'package:juix_na/features/production/viewmodel/purchase_entry_vm.dart';

/// Purchase Entry Screen
///
/// Screen structure:
/// 1. Header: Back button, title, subtitle, mark-as-received toggle
/// 2. Purchase Details card: Supplier, date, ref/invoice
/// 3. Items Purchased card: Item list with add/remove, save/cancel buttons
/// 4. Mark as Received section: Toggle with explanatory text
/// 5. Summary card: Total items, quantity, cost
class PurchaseEntryScreen extends ConsumerWidget {
  const PurchaseEntryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7EE), // Light cream background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header
              _Header(),

              const SizedBox(height: 20),

              // 2. Purchase Details card
              _PurchaseDetailsCard(),

              const SizedBox(height: 16),

              // 3. Items Purchased card
              _ItemsPurchasedCard(),

              const SizedBox(height: 16),

              // 4. Mark as Received section
              _MarkAsReceivedSection(),

              const SizedBox(height: 16),

              // 5. Summary card
              _SummaryCard(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// HEADER
// ============================================================================

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(purchaseEntryProvider);
    final viewModel = ref.read(purchaseEntryProvider.notifier);

    return Row(
      children: [
        // Back button
        IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
          icon: Semantics(
            label: 'Back',
            button: true,
            child: const Icon(Icons.arrow_back, color: AppColors.deepGreen),
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 16),
        // Title and subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Purchase Entry',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepGreen,
                  fontSize: 24,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Record bought supplies',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        // Mark as received toggle
        Semantics(
          label: 'Mark items as received',
          value: state.markAsReceived ? 'On' : 'Off',
          child: Switch(
            value: state.markAsReceived,
            onChanged: (value) => viewModel.toggleMarkAsReceived(),
            activeThumbColor: AppColors.mango,
            activeTrackColor: AppColors.mango.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// PURCHASE DETAILS CARD
// ============================================================================

class _PurchaseDetailsCard extends ConsumerWidget {
  const _PurchaseDetailsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(purchaseEntryProvider);
    final viewModel = ref.read(purchaseEntryProvider.notifier);

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          const Text(
            'Purchase Details',
            style: TextStyle(
              color: AppColors.deepGreen,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),

          // Supplier selector
          _SupplierField(
            supplierId: state.supplierId,
            onTap: () {
              // TODO: Open supplier picker bottom sheet
              // This will show a list of suppliers and allow selecting one
              // Should call viewModel.setSupplier(supplierId) on selection
            },
          ),

          const SizedBox(height: 12),

          // Date picker
          _DateField(
            date: state.date,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: state.date,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null && context.mounted) {
                viewModel.setDate(picked);
              }
            },
          ),

          const SizedBox(height: 12),

          // Ref/Invoice field (optional)
          _RefInvoiceField(
            value: state.refInvoice,
            onChanged: (value) => viewModel.setRefInvoice(value.isEmpty ? null : value),
          ),
        ],
      ),
    );
  }
}

class _SupplierField extends StatelessWidget {
  final int? supplierId;
  final VoidCallback onTap;

  const _SupplierField({
    required this.supplierId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Supplier',
          style: TextStyle(
            color: AppColors.deepGreen,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Semantics(
                label: 'Select supplier',
                button: true,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.borderSubtle,
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            supplierId != null ? 'Supplier #$supplierId' : 'Select supplier',
                            style: TextStyle(
                              color: supplierId != null
                                  ? AppColors.deepGreen
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.expand_more_rounded,
                          color: AppColors.mango,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Add new supplier button
            Semantics(
              label: 'Add new supplier',
              button: true,
              child: InkWell(
                onTap: () {
                  // TODO: Navigate to add supplier screen or show dialog
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 54,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.mango,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 20),
                      SizedBox(width: 6),
                      Text(
                        '+ Add new',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;

  const _DateField({
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('MM/dd/yyyy').format(date);

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
        Semantics(
          label: 'Select purchase date',
          button: true,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.borderSubtle,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
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
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.mango,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RefInvoiceField extends StatelessWidget {
  final String? value;
  final ValueChanged<String> onChanged;

  const _RefInvoiceField({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Ref / Invoice',
              style: TextStyle(
                color: AppColors.deepGreen,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(Optional)',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Semantics(
          label: 'Reference or invoice number',
          textField: true,
          child: TextField(
            onChanged: onChanged,
            controller: TextEditingController(text: value),
            decoration: InputDecoration(
              hintText: 'Enter reference or invoice number',
              hintStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColors.borderSubtle,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColors.borderSubtle,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColors.mango,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 16,
              ),
            ),
            style: const TextStyle(
              color: AppColors.deepGreen,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// ITEMS PURCHASED CARD
// ============================================================================

class _ItemsPurchasedCard extends ConsumerWidget {
  const _ItemsPurchasedCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(purchaseEntryProvider);
    final viewModel = ref.read(purchaseEntryProvider.notifier);

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          const Text(
            'Items Purchased',
            style: TextStyle(
              color: AppColors.deepGreen,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),

          // Items list
          if (state.items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      color: AppColors.textSecondary,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No items added',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...state.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: index < state.items.length - 1 ? 12 : 0),
                child: _PurchaseItemRow(
                  item: item,
                  index: index,
                  onDelete: () => viewModel.removeItem(index),
                  onUpdate: (updatedItem) => viewModel.updateItem(index, updatedItem),
                ),
              );
            }),

          const SizedBox(height: 16),

          // Add another item button
          Semantics(
            label: 'Add another item',
            button: true,
            child: InkWell(
              onTap: () {
                // TODO: Open item picker and add item
                // This should:
                // 1. Show item picker (similar to product picker in stock movement)
                // 2. On selection, create a PurchaseItem with:
                //    - itemId, itemName from selection
                //    - quantity: 1 (default)
                //    - unit: from item or 'pcs' (default)
                //    - unitCost: 0 (user enters)
                //    - subtotal: calculated
                // 3. Call viewModel.addItem(newItem)
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.mango,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: AppColors.mango,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Add another item',
                      style: TextStyle(
                        color: AppColors.mango,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Footer buttons
          Row(
            children: [
              // Cancel button
              Expanded(
                child: Semantics(
                  label: 'Cancel purchase entry',
                  button: true,
                  child: TextButton(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      }
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Save Purchase button
              Expanded(
                flex: 2,
                child: Semantics(
                  label: 'Save purchase entry',
                  button: true,
                  child: InkWell(
                    onTap: state.isLoading
                        ? null
                        : () async {
                            final success = await viewModel.savePurchase();
                            if (!context.mounted) return;
                            
                            final currentState = ref.read(purchaseEntryProvider);
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Purchase entry saved successfully'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                              if (context.canPop()) {
                                context.pop();
                              }
                            } else if (currentState.error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(currentState.error!),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          },
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.mangoGradientStart,
                            AppColors.mangoGradientEnd,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Center(
                        child: state.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Save Purchase',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
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
  }
}

class _PurchaseItemRow extends ConsumerStatefulWidget {
  final PurchaseItem item;
  final int index;
  final VoidCallback onDelete;
  final ValueChanged<PurchaseItem> onUpdate;

  const _PurchaseItemRow({
    required this.item,
    required this.index,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  ConsumerState<_PurchaseItemRow> createState() => _PurchaseItemRowState();
}

class _PurchaseItemRowState extends ConsumerState<_PurchaseItemRow> {
  late TextEditingController _quantityController;
  late TextEditingController _unitCostController;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: widget.item.quantity.toStringAsFixed(2),
    );
    _unitCostController = TextEditingController(
      text: widget.item.unitCost.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _unitCostController.dispose();
    super.dispose();
  }

  void _updateItem() {
    final quantity = double.tryParse(_quantityController.text) ?? 0.0;
    final unitCost = double.tryParse(_unitCostController.text) ?? 0.0;
    final subtotal = PurchaseItem.calculateSubtotal(quantity, unitCost);

    widget.onUpdate(
      widget.item.copyWith(
        quantity: quantity,
        unitCost: unitCost,
        subtotal: subtotal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9F0), // Light cream
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderSubtle,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item name and delete button
          Row(
            children: [
              Expanded(
                child: Semantics(
                  label: 'Item: ${widget.item.itemName}',
                  child: Text(
                    widget.item.itemName,
                    style: const TextStyle(
                      color: AppColors.deepGreen,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              Semantics(
                label: 'Remove item',
                button: true,
                child: IconButton(
                  onPressed: widget.onDelete,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Quantity and Unit Cost row
          Row(
            children: [
              // Quantity
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Qty',
                      style: TextStyle(
                        color: AppColors.deepGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Semantics(
                      label: 'Quantity',
                      textField: true,
                      child: TextField(
                        controller: _quantityController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => _updateItem(),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.borderSubtle,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.borderSubtle,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.mango,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
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
                ),
              ),
              const SizedBox(width: 12),
              // Unit Cost
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Unit Cost',
                      style: TextStyle(
                        color: AppColors.deepGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Semantics(
                      label: 'Unit cost',
                      textField: true,
                      child: TextField(
                        controller: _unitCostController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => _updateItem(),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.borderSubtle,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.borderSubtle,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.mango,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
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
                ),
              ),
              const SizedBox(width: 12),
              // Subtotal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Subtotal',
                      style: TextStyle(
                        color: AppColors.deepGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Semantics(
                        label: 'Subtotal: ${NumberFormat.currency(symbol: '\$').format(widget.item.subtotal)}',
                        child: Text(
                          NumberFormat.currency(symbol: '\$').format(widget.item.subtotal),
                          style: const TextStyle(
                            color: AppColors.deepGreen,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// MARK AS RECEIVED SECTION
// ============================================================================

class _MarkAsReceivedSection extends ConsumerWidget {
  const _MarkAsReceivedSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(purchaseEntryProvider);
    final viewModel = ref.read(purchaseEntryProvider.notifier);

    return _Card(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mark items as received',
                  style: TextStyle(
                    color: AppColors.deepGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'If enabled, items will be automatically added to inventory',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Semantics(
            label: 'Mark items as received',
            value: state.markAsReceived ? 'On' : 'Off',
            child: Switch(
              value: state.markAsReceived,
              onChanged: (value) => viewModel.toggleMarkAsReceived(),
              activeThumbColor: AppColors.mango,
            activeTrackColor: AppColors.mango.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SUMMARY CARD
// ============================================================================

class _SummaryCard extends ConsumerWidget {
  const _SummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(purchaseEntryProvider);

    final totalItems = state.getTotalItemsCount();
    final totalQuantity = state.calculateTotalQuantity();
    final totalCost = state.calculateTotal();

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Summary',
            style: TextStyle(
              color: AppColors.deepGreen,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          // Total items
          _SummaryRow(
            label: 'Total items',
            value: totalItems.toString(),
          ),
          const SizedBox(height: 12),
          // Total quantity
          _SummaryRow(
            label: 'Total quantity',
            value: totalQuantity.toStringAsFixed(2),
          ),
          const SizedBox(height: 12),
          // Total cost
          _SummaryRow(
            label: 'Total Cost',
            value: NumberFormat.currency(symbol: '\$').format(totalCost),
            isBold: true,
            valueColor: AppColors.mango,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.deepGreen,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            fontSize: 15,
          ),
        ),
        Semantics(
          label: '$label: $value',
          child: Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.deepGreen,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// SHARED CARD WIDGET
// ============================================================================

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderSubtle,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}
