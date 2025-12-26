import 'package:flutter/material.dart';
import 'package:juix_na/app/app_colors.dart';
import 'package:juix_na/features/inventory/model/inventory_models.dart';
import 'package:juix_na/features/inventory/viewmodel/reorder_alerts_state.dart';

/// Reorder Alert Card Widget
/// Displays product information, stock details, and action buttons for reorder alerts.
class ReorderAlertCard extends StatelessWidget {
  final ReorderAlert alert;
  final VoidCallback? onCreateRequest;
  final VoidCallback? onViewProduct;
  final VoidCallback? onDismiss;

  const ReorderAlertCard({
    super.key,
    required this.alert,
    this.onCreateRequest,
    this.onViewProduct,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark
        ? AppColors.darkCard
        : const Color(0xFFFDF7EE); // Light beige

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20), // Rounded corners
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
          // Product Header Section
          _ProductHeader(alert: alert),

          const SizedBox(height: 16),

          // Stock Details Section (3 columns)
          _StockDetailsSection(alert: alert),

          const SizedBox(height: 16),

          // Action Buttons Section
          _ActionButtonsSection(
            onCreateRequest: onCreateRequest,
            onViewProduct: onViewProduct,
            onDismiss: onDismiss,
          ),
        ],
      ),
    );
  }
}

/// Product Header (Image, Name, Tags)
class _ProductHeader extends StatelessWidget {
  final ReorderAlert alert;

  const _ProductHeader({required this.alert});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Image (square, rounded corners, placeholder)
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.mangoLight.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSoft, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Container(
              color: AppColors.mangoLight.withOpacity(0.1),
              child: const Icon(
                Icons.inventory_2_rounded,
                color: AppColors.mango,
                size: 40,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Product Info (Type Tag, Name, Severity Badge)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type Tag (light yellow pill) - FIRST
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4D6), // Light yellow background
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getItemKindDisplayName(alert.item.kind),
                  style: const TextStyle(
                    color: AppColors.deepGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Product Name - SECOND
              Text(
                alert.item.name,
                style: const TextStyle(
                  color: AppColors.deepGreen,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Severity Badge (CRITICAL, OUT OF STOCK, or LOW STOCK) - THIRD
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: alert.isOutOfStock
                      ? AppColors
                            .textMuted // Dark gray for OUT OF STOCK
                      : (alert.isCritical
                            ? AppColors
                                  .error // Red for CRITICAL
                            : AppColors.mango), // Orange for LOW STOCK
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (alert.isOutOfStock)
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.cancel_outlined,
                          color: Colors.white,
                          size: 12,
                        ),
                      )
                    else if (alert.isCritical)
                      Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size: 12,
                        ),
                      ),
                    if (alert.isOutOfStock || alert.isCritical)
                      const SizedBox(width: 6),
                    Text(
                      alert.isOutOfStock
                          ? 'OUT OF STOCK'
                          : (alert.isCritical ? 'CRITICAL' : 'LOW STOCK'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Stock Details Section (3 columns: STOCK, REORDER @, SUGGEST)
class _StockDetailsSection extends StatelessWidget {
  final ReorderAlert alert;

  const _StockDetailsSection({required this.alert});

  @override
  Widget build(BuildContext context) {
    final currentStock = alert.currentStock.toInt();
    final reorderLevel = alert.reorderLevel?.toInt() ?? 0;
    final suggestedQty = alert.suggestedReorderQuantity?.toInt() ?? 0;

    // Determine stock value display and color
    final stockValue = alert.isOutOfStock
        ? '0' // Show "0" for out of stock (not "00")
        : currentStock.toString().padLeft(
            2,
            '0',
          ); // Show "02", "08", etc. with padding

    // Stock color: orange for LOW STOCK, red for CRITICAL (but not out of stock), dark gray for OUT OF STOCK
    final stockColor = alert.isOutOfStock
        ? AppColors
              .textMuted // Dark gray for out of stock
        : (alert.isCritical && !alert.isOutOfStock
              ? AppColors
                    .error // Red for critical (but not out of stock)
              : AppColors.mango); // Orange for low stock

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, // White background for stock values section
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // STOCK column
          Expanded(
            child: _StockDetailColumn(
              label: 'STOCK',
              value: stockValue,
              valueColor: stockColor,
            ),
          ),
          // Divider
          Container(
            width: 1,
            height: 40,
            color: AppColors.borderSoft,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          // REORDER @ column
          Expanded(
            child: _StockDetailColumn(
              label: 'REORDER @',
              value: reorderLevel.toString(),
              valueColor: AppColors.textMuted,
            ),
          ),
          // Divider
          Container(
            width: 1,
            height: 40,
            color: AppColors.borderSoft,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          // SUGGEST column
          Expanded(
            child: _StockDetailColumn(
              label: 'SUGGEST',
              value: suggestedQty > 0 ? '+$suggestedQty' : 'N/A',
              valueColor: AppColors.mango,
            ),
          ),
        ],
      ),
    );
  }
}

/// Stock Detail Column (Label + Value)
class _StockDetailColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _StockDetailColumn({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, // Center alignment
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

/// Helper function to get display name for ItemKind
/// Maps ItemKind to user-friendly display names.
String _getItemKindDisplayName(ItemKind kind) {
  switch (kind) {
    case ItemKind.ingredient:
      return 'INGREDIENT';
    case ItemKind.finishedProduct:
      return 'FINISHED PRODUCT'; // Could be "SMOOTHIE" or "COLD PRESSED" in the future
    case ItemKind.packaging:
      return 'ADD-ONS'; // Display as "ADD-ONS" per design
  }
}

/// Action Buttons Section
class _ActionButtonsSection extends StatelessWidget {
  final VoidCallback? onCreateRequest;
  final VoidCallback? onViewProduct;
  final VoidCallback? onDismiss;

  const _ActionButtonsSection({
    this.onCreateRequest,
    this.onViewProduct,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Create Request Button (large, gradient)
        SizedBox(
          width: double.infinity,
          child: InkWell(
            onTap: onCreateRequest,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.mango,
                    Color(0xFFFFB84D), // Yellow-orange gradient end
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.mango.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Create Request',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // View Product & Dismiss Buttons (side by side)
        Row(
          children: [
            // View Product Button
            Expanded(
              child: InkWell(
                onTap: onViewProduct,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white, // White background per design
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderSoft, width: 1),
                  ),
                  child: const Center(
                    child: Text(
                      'View Product',
                      style: TextStyle(
                        color: AppColors.textMuted, // Dark gray text per design
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Dismiss Button
            Expanded(
              child: InkWell(
                onTap: onDismiss,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white, // White background per design
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderSoft, width: 1),
                  ),
                  child: const Center(
                    child: Text(
                      'Dismiss',
                      style: TextStyle(
                        color: AppColors.textMuted, // Dark gray text per design
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
