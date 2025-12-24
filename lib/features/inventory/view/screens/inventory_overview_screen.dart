import 'package:flutter/material.dart';
import 'package:juix_na/app/app_colors.dart';
import 'package:juix_na/app/theme_controller.dart';
import 'package:juix_na/features/inventory/widgets/inventory_stock_card.dart';
import 'package:juix_na/features/inventory/widgets/stat_chip.dart';
import 'package:provider/provider.dart';

class InventoryOverviewScreen extends StatefulWidget {
  const InventoryOverviewScreen({super.key});

  @override
  State<InventoryOverviewScreen> createState() =>
      _InventoryOverviewScreenState();
}

class _InventoryOverviewScreenState extends State<InventoryOverviewScreen> {
  String _activeFilter = 'All Items';
  String _selectedItemId = '';

  final List<StockItem> _items = const [
    StockItem(
      id: 'orange',
      name: 'Orange',
      code: '#B2023',
      location: 'Shelf A2',
      reorderNote: '',
      unit: 'units',
      open: 50,
      inCount: 20,
      outCount: -10,
      close: 60,
      totalValue: 'GBP 300.00',
      tag: 'BULK',
    ),
    StockItem(
      id: 'orange-zest',
      name: 'Orange Zest',
      code: '#OZ-101',
      location: 'Bin 4',
      reorderNote: 'LOW STOCK',
      unit: 'units',
      open: 10,
      inCount: 0,
      outCount: -5,
      close: 5,
      totalValue: 'GBP 45.50',
      tag: 'RAW',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: cs.background,
        elevation: 0,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 40,
              width: 40,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: Icon(Icons.arrow_back,
                  color: isDark ? Colors.white : AppColors.deepGreen),
            ),
          ),
        ),
        titleSpacing: 0,
        title: Text(
          'Inventory Overview',
          style: theme.textTheme.titleLarge?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        actions: [
          Consumer<ThemeController>(
            builder: (context, controller, _) {
              return IconButton(
                tooltip: 'Toggle theme',
                icon: Icon(
                  controller.isDark
                      ? Icons.wb_sunny_rounded
                      : Icons.nightlight_round,
                  color: controller.isDark ? Colors.white : AppColors.deepGreen,
                ),
                onPressed: controller.toggle,
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.mangoGradientStart,
                    AppColors.mangoGradientEnd,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(26),
              ),
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.sync, size: 20, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Sync',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.mango,
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              const _StatusContent(),
              const SizedBox(height: 18),
              _FilterChipsBar(
                activeFilter: _activeFilter,
                onFilterSelected: (label) =>
                    setState(() => _activeFilter = label),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: _StockListView(
                  items: _items,
                  selectedId: _selectedItemId,
                  onSelect: (id) => setState(() => _selectedItemId = id),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusContent extends StatelessWidget {
  const _StatusContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        SizedBox(height: 12),
        Wrap(
          spacing: 20,
          runSpacing: 15,
          children: [_LocationChip(), _OnlineChip()],
        ),
        SizedBox(height: 16),
        _SearchField(),
        SizedBox(height: 16),
        _StatsChips(),
      ],
    );
  }
}

class _FilterChipsBar extends StatelessWidget {
  final String activeFilter;
  final ValueChanged<String> onFilterSelected;

  const _FilterChipsBar({
    required this.activeFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cs = theme.colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChipPill(
            label: 'All Items',
            isSelected: activeFilter == 'All Items',
            onTap: () => onFilterSelected('All Items'),
            isDark: isDark,
            colorScheme: cs,
          ),
          const SizedBox(width: 8),
          _FilterChipPill(
            label: 'Category',
            isSelected: activeFilter == 'Category',
            onTap: () => onFilterSelected('Category'),
            isDark: isDark,
            colorScheme: cs,
          ),
          const SizedBox(width: 8),
          _FilterChipPill(
            label: 'Location',
            isSelected: activeFilter == 'Location',
            onTap: () => onFilterSelected('Location'),
            isDark: isDark,
            colorScheme: cs,
          ),
          const SizedBox(width: 8),
          _FilterChipPill(
            label: 'Brand',
            isSelected: activeFilter == 'Brand',
            onTap: () => onFilterSelected('Brand'),
            isDark: isDark,
            colorScheme: cs,
          ),
        ],
      ),
    );
  }
}

class _FilterChipPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;
  final ColorScheme colorScheme;

  const _FilterChipPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isSelected
        ? AppColors.deepGreen
        : (isDark ? AppColors.darkPill : colorScheme.background);
    final textColor =
        isSelected ? Colors.white : (isDark ? AppColors.darkTextPrimary : AppColors.deepGreen);
    final borderColor =
        isSelected ? Colors.transparent : (isDark ? AppColors.borderSubtle.withOpacity(0.3) : AppColors.borderSoft);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (!isSelected) ...const [
                SizedBox(width: 6),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: AppColors.mango,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StockListView extends StatelessWidget {
  final List<StockItem> items;
  final String selectedId;
  final ValueChanged<String> onSelect;

  const _StockListView({
    required this.items,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: items.length,
      separatorBuilder: (context, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        final selected = item.id == selectedId;
        return InventoryStockCard(
          item: item,
          isSelected: selected,
          onTap: () => onSelect(item.id),
        );
      },
    );
  }
}

class _LocationChip extends StatelessWidget {
  const _LocationChip();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? AppColors.darkPill
        : AppColors.mangoLight.withOpacity(0.1);
    final borderColor =
        isDark ? AppColors.borderSubtle.withOpacity(0.3) : AppColors.mangoLight;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.kitchen, color: AppColors.mango),
            const SizedBox(width: 8),
            Text(
              'Main Freezer',
              style: TextStyle(
                color:
                    isDark ? AppColors.darkTextPrimary : AppColors.deepGreen,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_drop_down, color: AppColors.mango),
          ],
        ),
      ),
    );
  }
}

class _OnlineChip extends StatelessWidget {
  const _OnlineChip();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF123522) : AppColors.successSoft;
    final borderColor =
        isDark ? Colors.transparent : AppColors.success.withOpacity(0.35);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(radius: 5, backgroundColor: AppColors.success),
            const SizedBox(width: 8),
            Text(
              'Online â€¢ 10:42 AM',
              style: TextStyle(
                color:
                    isDark ? AppColors.darkTextPrimary : AppColors.deepGreen,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search products, materials...',
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 12, right: 8),
          child: Icon(Icons.search, color: AppColors.mango, size: 25),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 40),
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : AppColors.background,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(
            color: isDark
                ? AppColors.borderSubtle.withOpacity(0.3)
                : Colors.transparent,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppColors.mangoLight),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: TextStyle(
          color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
          fontSize: 17,
        ),
      ),
    );
  }
}

class _StatsChips extends StatelessWidget {
  const _StatsChips();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          StatChip(
            title: 'CURRENT STOCK',
            value: '1,240',
            suffix: 'units',
            background: isDark ? AppColors.darkPill : AppColors.surface,
            borderColor:
                isDark ? AppColors.borderSubtle.withOpacity(0.2) : AppColors.borderSoft,
            titleColor: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            valueColor:
                isDark ? AppColors.darkTextPrimary : AppColors.deepGreen,
            suffixColor: AppColors.mango,
          ),
          const SizedBox(width: 12),
          const StatChip(
            title: 'INVENTORY VALUE',
            value: 'GBP 12,450',
            backgroundGradient: AppGradients.primary,
            titleColor: Colors.white,
            valueColor: Colors.white,
          ),
          const SizedBox(width: 12),
          StatChip(
            title: 'LOW STOCK',
            value: '3',
            background:
                isDark ? AppColors.darkPill : AppColors.errorSoft,
            borderColor: isDark
                ? AppColors.borderSubtle.withOpacity(0.2)
                : AppColors.error.withOpacity(0.4),
            titleColor: isDark ? AppColors.mango : AppColors.error,
            valueColor: isDark ? AppColors.darkTextPrimary : AppColors.error,
          ),
        ],
      ),
    );
  }
}
