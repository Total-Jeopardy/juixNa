import 'package:flutter/material.dart';
import 'package:juix_na/app/app_colors.dart';

class StockItem {
  final String id;
  final String name;
  final String code;
  final String location;
  final String reorderNote;
  final String unit;
  final int open;
  final int inCount;
  final int outCount;
  final int close;
  final String totalValue;
  final String tag;

  const StockItem({
    required this.id,
    required this.name,
    required this.code,
    required this.location,
    required this.reorderNote,
    required this.unit,
    required this.open,
    required this.inCount,
    required this.outCount,
    required this.close,
    required this.totalValue,
    required this.tag,
  });
}

class InventoryStockCard extends StatelessWidget {
  final StockItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const InventoryStockCard({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : AppColors.background;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.mango : Colors.transparent,
                width: isSelected ? 1.6 : 0,
              ),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadowSoft,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.mangoLight.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(10),
                      child: const Icon(
                        Icons.inventory_2_rounded,
                        color: AppColors.mango,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkPill
                                      : AppColors.backgroundAlt,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  item.tag,
                                  style: const TextStyle(
                                    color: AppColors.mango,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                item.code,
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.darkTextMuted
                                      : AppColors.textMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.chair,
                                size: 14,
                                color: isDark
                                    ? AppColors.darkTextMuted
                                    : AppColors.textMuted,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                item.location,
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.darkTextMuted
                                      : AppColors.textMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          if (item.reorderNote.isNotEmpty)
                            Text(
                              item.reorderNote,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkPill : AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _MetricColumn(
                        label: 'OPEN',
                        value: '${item.open}',
                        unit: item.unit,
                        color: theme.colorScheme.onSurface,
                      ),
                      _MetricColumn(
                        label: 'IN',
                        value: item.inCount == 0
                            ? '-'
                            : '${item.inCount > 0 ? '+' : ''}${item.inCount}',
                        unit: item.inCount == 0 ? '' : item.unit,
                        color: AppColors.success,
                      ),
                      _MetricColumn(
                        label: 'OUT',
                        value: item.outCount == 0 ? '-' : '${item.outCount}',
                        unit: item.outCount == 0 ? '' : item.unit,
                        color: AppColors.error,
                      ),
                      _MetricColumn(
                        label: 'CLOSE',
                        value: '${item.close}',
                        unit: item.unit,
                        color: AppColors.mango,
                        highlight: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Divider(
                  color: isDark
                      ? AppColors.borderSubtle.withOpacity(0.2)
                      : AppColors.borderSoft,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Value: ${item.totalValue}',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    Icon(
                      Icons.more_horiz,
                      color:
                          isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricColumn extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;
  final bool highlight;

  const _MetricColumn({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayUnit = value == '-' ? '' : unit;
    final labelColor =
        highlight ? AppColors.mango : (isDark ? AppColors.darkTextMuted : AppColors.textMuted);
    final unitColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (displayUnit.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                displayUnit,
                style: TextStyle(
                  color: unitColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
