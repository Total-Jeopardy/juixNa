import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:juix_na/app/app_colors.dart';
import 'package:juix_na/app/theme_controller.dart';
import 'package:provider/provider.dart';

enum _MovementType { stockIn, stockOut }

class ProductOption {
  final String id;
  final String name;
  final double unitCost;
  final bool batchTracked;
  final int availableStock;

  const ProductOption({
    required this.id,
    required this.name,
    required this.unitCost,
    required this.batchTracked,
    required this.availableStock,
  });
}

class LocationOption {
  final String id;
  final String name;
  const LocationOption(this.id, this.name);
}

class StockMovementScreen extends StatefulWidget {
  const StockMovementScreen({super.key});

  @override
  State<StockMovementScreen> createState() => _StockMovementScreenState();
}

class _StockMovementScreenState extends State<StockMovementScreen> {
  _MovementType _movementType = _MovementType.stockOut;
  DateTime _date = DateTime.now();
  final _notesController = TextEditingController();
  final _quantityController = TextEditingController(text: '120');
  String? _selectedProductId = 'mango';
  String? _selectedBatchId;
  String? _selectedLocationId = 'main';

  final _products = const [
    ProductOption(
      id: 'mango',
      name: 'Mango Tango Juice (500ml)',
      unitCost: 4.50,
      batchTracked: true,
      availableStock: 60,
    ),
    ProductOption(
      id: 'orange',
      name: 'Orange Zest Concentrate',
      unitCost: 3.10,
      batchTracked: false,
      availableStock: 120,
    ),
  ];

  final _locations = const [
    LocationOption('main', 'Main Store (Primary)'),
    LocationOption('cold', 'Cold Room A'),
    LocationOption('dry', 'Dry Storage'),
  ];

  final _batches = const [
    'Batch 2023-10-01',
    'Batch 2023-09-15',
    'Batch 2023-09-01',
  ];

  bool _pendingSync = true;
  bool _online = true;

  @override
  void dispose() {
    _notesController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  ProductOption get _selectedProduct =>
      _products.firstWhere((p) => p.id == _selectedProductId);

  int get _availableStock => _selectedProduct.availableStock;

  bool get _batchRequired => _selectedProduct.batchTracked;

  bool get _quantityExceeds {
    final qty = int.tryParse(_quantityController.text) ?? 0;
    return qty > _availableStock;
  }

  bool get _hasErrors {
    if (_selectedProductId == null) return true;
    if (_batchRequired && (_selectedBatchId == null || _selectedBatchId!.isEmpty)) {
      return true;
    }
    if ((_quantityController.text).isEmpty) return true;
    if ((_quantityController.text) == '0') return true;
    if (_quantityExceeds) return true;
    return false;
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  void _changeQty(int delta) {
    final current = int.tryParse(_quantityController.text) ?? 0;
    final next = (current + delta).clamp(0, 9999);
    setState(() => _quantityController.text = next.toString());
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cs = theme.colorScheme;
    final dateLabel = DateFormat('MMM d, yyyy').format(_date);

    return Scaffold(
      backgroundColor: cs.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadowSoft,
                      blurRadius: 18,
                      offset: Offset(0, 6),
                    ),
                  ],
                  border: Border.all(
                    color: isDark
                        ? AppColors.borderSubtle.withOpacity(0.3)
                        : Colors.transparent,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Header(
                      onBack: () => Navigator.of(context).maybePop(),
                      pendingSync: _pendingSync,
                      online: _online,
                    ),
                    const SizedBox(height: 12),
                    _MovementToggle(
                      movementType: _movementType,
                      onChanged: (type) => setState(() => _movementType = type),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: _FormCard(
                        child: Column(
                          children: [
                            _PickerField(
                              label: 'Date',
                              value: dateLabel,
                              onTap: _pickDate,
                              icon: Icons.calendar_today_outlined,
                            ),
                            _PickerField(
                              label: 'Product',
                              value: _selectedProduct.name,
                              onTap: () => _showProductPicker(context),
                              icon: Icons.expand_more_rounded,
                            ),
                            _BatchField(
                              required: _batchRequired,
                              selectedBatch: _selectedBatchId,
                              batches: _batches,
                              onSelect: (batch) => setState(() {
                                _selectedBatchId = batch;
                              }),
                            ),
                            _QuantityField(
                              controller: _quantityController,
                              exceeds: _quantityExceeds,
                              available: _availableStock,
                              onChange: (val) =>
                                  setState(() => _quantityController.text = val),
                              onAdd: () => _changeQty(1),
                              onRemove: () => _changeQty(-1),
                            ),
                            _InlineRow(
                              left: _ChipField(
                                label: 'Unit Cost',
                                value:
                                    '£${_selectedProduct.unitCost.toStringAsFixed(2)}',
                                leading: Icons.local_offer_outlined,
                                locked: true,
                              ),
                              right: _PickerField(
                                label: 'Location',
                                value: _locations
                                    .firstWhere(
                                        (l) => l.id == _selectedLocationId)
                                    .name,
                                onTap: () => _showLocationPicker(context),
                                icon: Icons.expand_more_rounded,
                              ),
                            ),
                            _NotesField(controller: _notesController),
                            const SizedBox(height: 12),
                            _RecentMovementsLink(onTap: () {}),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _FooterActions(
                enabled: !_hasErrors,
                onCancel: () => Navigator.of(context).maybePop(),
                onSave: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> _showProductPicker(BuildContext context) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            shrinkWrap: true,
            children: _products
                .map(
                  (p) => ListTile(
                    title: Text(p.name),
                    subtitle: Text(
                      '${p.availableStock} available',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.textMuted,
                      ),
                    ),
                    onTap: () => Navigator.of(context).pop(p.id),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
    if (choice != null) {
      setState(() {
        _selectedProductId = choice;
        _selectedBatchId = null;
      });
    }
  }

  Future<void> _showLocationPicker(BuildContext context) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            shrinkWrap: true,
            children: _locations
                .map(
                  (l) => ListTile(
                    title: Text(l.name),
                    onTap: () => Navigator.of(context).pop(l.id),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
    if (choice != null) {
      setState(() => _selectedLocationId = choice);
    }
  }
}
class _Header extends StatelessWidget {
  final VoidCallback onBack;
  final bool pendingSync;
  final bool online;

  const _Header({
    required this.onBack,
    required this.pendingSync,
    required this.online,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeController = context.read<ThemeController>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back,
                    color: isDark ? Colors.white : AppColors.deepGreen),
                onPressed: onBack,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Stock Movement',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.deepGreen,
                      ),
                ),
              ),
              Row(
                children: [
                  Text(
                    'Sync',
                    style: TextStyle(
                      color: AppColors.mango,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppGradients.primary,
                    ),
                    padding: const EdgeInsets.all(5),
                  child: const Icon(
                    Icons.bolt_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
                  IconButton(
                    icon: Icon(
                      isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                      color:
                          isDark ? AppColors.darkTextPrimary : AppColors.deepGreen,
                    ),
                    onPressed: themeController.toggle,
                  ),
                  IconButton(
                    icon: Icon(Icons.more_horiz,
                        color:
                            isDark ? AppColors.darkTextPrimary : AppColors.deepGreen),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          _InfoPill(
            icon: Icons.offline_bolt,
            text: pendingSync
                ? 'Pending Sync. Tap Sync to send now.'
                : 'Saved offline. Will sync when online.',
            background: isDark
                ? AppColors.darkPill
                : AppColors.mangoLight.withOpacity(0.12),
          ),
          const SizedBox(height: 8),
          _InfoPill(
            icon: online ? Icons.wifi : Icons.wifi_off,
            text: online ? 'ONLINE • LAST SYNC: 10:42 AM' : 'OFFLINE',
            background: isDark
                ? AppColors.darkPill
                : AppColors.successSoft.withOpacity(0.6),
          ),
        ],
      ),
    );
  }
}
class _MovementToggle extends StatelessWidget {
  final _MovementType movementType;
  final ValueChanged<_MovementType> onChanged;

  const _MovementToggle({
    required this.movementType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkPill : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(28),
        ),
        height: 48,
        child: Row(
          children: [
            _SegmentButton(
              label: 'Stock-In',
              selected: movementType == _MovementType.stockIn,
              onTap: () => onChanged(_MovementType.stockIn),
            ),
            _SegmentButton(
              label: 'Stock-Out',
              selected: movementType == _MovementType.stockOut,
              onTap: () => onChanged(_MovementType.stockOut),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentButton({
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
            borderRadius: BorderRadius.circular(24),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: onTap,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.textMuted,
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
  final Widget child;
  const _FormCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.background,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: isDark
              ? AppColors.borderSubtle.withOpacity(0.2)
              : Colors.transparent,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: child,
    );
  }
}

class _PickerField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final IconData icon;

  const _PickerField({
    required this.label,
    required this.value,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.deepGreen;
    final borderColor =
        isDark ? AppColors.borderSubtle.withOpacity(0.3) : AppColors.borderSoft;

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
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
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
  final bool required;
  final String? selectedBatch;
  final List<String> batches;
  final ValueChanged<String> onSelect;

  const _BatchField({
    required this.required,
    required this.selectedBatch,
    required this.batches,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasError = required && (selectedBatch == null || selectedBatch!.isEmpty);
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
                  color: required ? AppColors.error : AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              final choice = await showModalBottomSheet<String>(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) {
                  final modalDark =
                      Theme.of(context).brightness == Brightness.dark;
                  return Container(
                    decoration: BoxDecoration(
                      color: modalDark
                          ? AppColors.darkSurface
                          : AppColors.surface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: ListView(
                      shrinkWrap: true,
                      children: batches
                          .map(
                            (b) => ListTile(
                              title: Text(b),
                              onTap: () => Navigator.of(context).pop(b),
                            ),
                          )
                          .toList(),
                    ),
                  );
                },
              );
              if (choice != null) onSelect(choice);
            },
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedBatch ?? 'Select Batch',
                      style: TextStyle(
                        color: selectedBatch == null
                            ? AppColors.textMuted
                            : (isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.deepGreen),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
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
            const Text(
              'Batch selection is required. This product is batch-tracked.',
              style: TextStyle(
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
  final TextEditingController controller;
  final bool exceeds;
  final int available;
  final ValueChanged<String> onChange;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _QuantityField({
    required this.controller,
    required this.exceeds,
    required this.available,
    required this.onChange,
    required this.onAdd,
    required this.onRemove,
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
            height: 56,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.background,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: borderColor, width: 1.2),
            ),
            child: Row(
              children: [
                const SizedBox(width: 6),
                _CircleIconButton(
                  icon: Icons.remove,
                  onTap: onRemove,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChange,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isCollapsed: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.deepGreen,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkPill : AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Units',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                _CircleIconButton(
                  icon: Icons.add,
                  onTap: onAdd,
                  fill: true,
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
  final IconData leading;
  final bool locked;

  const _ChipField({
    required this.label,
    required this.value,
    required this.leading,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor =
        isDark ? AppColors.borderSubtle.withOpacity(0.3) : AppColors.borderSoft;

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
          height: 52,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(leading, color: AppColors.textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.deepGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (locked)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkPill
                        : AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Manager only',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
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
class _NotesField extends StatelessWidget {
  final TextEditingController controller;
  const _NotesField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
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
              color: isDark ? AppColors.darkSurface : AppColors.background,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? AppColors.borderSubtle.withOpacity(0.3)
                    : AppColors.borderSoft,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextField(
                  controller: controller,
                  maxLines: 4,
                  maxLength: 250,
                  decoration: const InputDecoration(
                    hintText: 'Describe the reason for stock adjustment...',
                    border: InputBorder.none,
                    isCollapsed: true,
                    counterText: '',
                  ),
                ),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (context, value, _) {
                    return Text(
                      '${value.text.length}/250',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentMovementsLink extends StatelessWidget {
  final VoidCallback onTap;
  const _RecentMovementsLink({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history,
                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
            const SizedBox(width: 8),
            Text(
              'View Recent Movements',
              style: TextStyle(
                color:
                    isDark ? AppColors.darkTextMuted : AppColors.deepGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color background;

  const _InfoPill({
    required this.icon,
    required this.text,
    required this.background,
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
                : Colors.white.withOpacity(0.8),
            child: Icon(icon, size: 16, color: AppColors.deepGreen),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color:
                    isDark ? AppColors.darkTextPrimary : AppColors.deepGreen,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool fill;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.fill = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fill ? AppColors.mango : Colors.transparent,
          border: fill
              ? null
              : Border.all(color: AppColors.borderSoft, width: 1.1),
        ),
        padding: const EdgeInsets.all(10),
        child: Icon(
          icon,
          size: 18,
          color: fill ? Colors.white : AppColors.deepGreen,
        ),
      ),
    );
  }
}

class _FooterActions extends StatelessWidget {
  final bool enabled;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const _FooterActions({
    required this.enabled,
    required this.onCancel,
    required this.onSave,
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
              side: const BorderSide(color: AppColors.borderSoft),
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
            onPressed: enabled ? onSave : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              backgroundColor:
                  enabled ? AppColors.mango : AppColors.borderSubtle,
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

