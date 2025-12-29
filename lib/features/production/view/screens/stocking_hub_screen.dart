import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:juix_na/app/app_colors.dart';
import 'package:juix_na/features/production/viewmodel/stocking_hub_vm.dart';
import 'package:juix_na/features/production/model/production_models.dart';
import 'package:intl/intl.dart';

/// Stocking Hub Screen - UI only
///
/// Screen structure based on design:
/// 1. Header with back button, "Stocking" title, subtitle, and help icon
/// 2. Informational message with orange icon
/// 3. Three action cards:
///    - "Buy / Receive Supplies" (orange border, truck icon, "Start Receiving" button)
///    - "Produce Drinks" (green border, blender icon, "Start Production" button)
///    - "Quick Stock Adjustment" (smaller card with right arrow)
/// 4. Recent Activity section with title, "View All" link, and activity items
class StockingHubScreen extends ConsumerStatefulWidget {
  const StockingHubScreen({super.key});

  @override
  ConsumerState<StockingHubScreen> createState() => _StockingHubScreenState();
}

class _StockingHubScreenState extends ConsumerState<StockingHubScreen> {
  @override
  Widget build(BuildContext context) {
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

              const SizedBox(height: 16),

              // 2. Informational message
              _InfoMessage(),

              const SizedBox(height: 20),

              // 3. Action Cards
              _BuyReceiveSuppliesCard(),

              const SizedBox(height: 16),

              _ProduceDrinksCard(),

              const SizedBox(height: 16),

              _QuickStockAdjustmentCard(),

              const SizedBox(height: 24),

              // 4. Recent Activity Section
              _RecentActivitySection(),
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

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
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
        // Title and subtitle (centered)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Stocking',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepGreen,
                  fontSize: 24, // Smaller (was 28)
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2), // Reduced spacing (was 4)
              Text(
                'Add items to your inventory',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        // Help icon button (smaller and moved up)
        Transform.translate(
          offset: const Offset(0, -4), // Move up a bit
          child: IconButton(
            onPressed: () => _showHelpDialog(context),
            icon: Semantics(
              label: 'Help',
              button: true,
              child: Container(
                width: 36, // Smaller (was 40)
                height: 36, // Smaller (was 40)
                decoration: const BoxDecoration(
                  color: AppColors.deepGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.help_outline,
                  color: Colors.white,
                  size: 18, // Smaller (was 20)
                ),
              ),
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// INFO MESSAGE
// ============================================================================

class _InfoMessage extends StatelessWidget {
  const _InfoMessage();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppColors.mango,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.info_outline, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Start by receiving supplies or recording your first batch.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// ACTION CARDS
// ============================================================================

class _BuyReceiveSuppliesCard extends StatelessWidget {
  const _BuyReceiveSuppliesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDF7EE), // Light cream background
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: AppColors.mango, width: 4)),
      ),
      padding: const EdgeInsets.all(16), // Reduced from 20 (20% smaller)
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 45, // Reduced from 56 (20% smaller)
            height: 45, // Reduced from 56 (20% smaller)
            decoration: BoxDecoration(
              color: const Color(0xFFFFE5D6), // Light orange circle
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_shipping,
              color: AppColors.mango,
              size: 22, // Reduced from 28 (20% smaller)
            ),
          ),
          const SizedBox(height: 12), // Reduced from 16
          // Title
          Text(
            'Buy / Receive Supplies',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.deepGreen,
              fontSize: 16, // Reduced from 18
            ),
          ),
          const SizedBox(height: 6), // Reduced from 8
          // Description
          Text(
            'Add bottles, labels, ingredients, and other supplies to the warehouse.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13, // Reduced from 14
            ),
          ),
          const SizedBox(height: 16), // Reduced from 20
          // Button
          SizedBox(
            width: double.infinity,
            child: Semantics(
              label: 'Start Receiving Supplies',
              button: true,
              child: InkWell(
                onTap: () {
                  context.push('/production/purchase-entry');
                },
                borderRadius: BorderRadius.circular(18), // More rounded
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 11,
                  ), // Reduced from 14
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.mangoGradientStart,
                        AppColors.mangoGradientEnd,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(
                      18,
                    ), // More rounded (was 12)
                  ),
                  child: const Center(
                    child: Text(
                      'Start Receiving',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15, // Reduced from 16
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
    );
  }
}

class _ProduceDrinksCard extends StatelessWidget {
  const _ProduceDrinksCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDF7EE), // Light cream background
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: AppColors.deepGreen, width: 4)),
      ),
      padding: const EdgeInsets.all(16), // Reduced from 20 (20% smaller)
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 45, // Reduced from 56 (20% smaller)
            height: 45, // Reduced from 56 (20% smaller)
            decoration: BoxDecoration(
              color: AppColors.successSoft, // Light green circle
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.blender,
              color: AppColors.success,
              size: 22, // Reduced from 28 (20% smaller)
            ),
          ),
          const SizedBox(height: 12), // Reduced from 16
          // Title
          Text(
            'Produce Drinks',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.deepGreen,
              fontSize: 16, // Reduced from 18
            ),
          ),
          const SizedBox(height: 6), // Reduced from 8
          // Description
          Text(
            'Record juice batches and add finished drinks to inventory.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13, // Reduced from 14
            ),
          ),
          const SizedBox(height: 16), // Reduced from 20
          // Button
          SizedBox(
            width: double.infinity,
            child: Semantics(
              label: 'Start Production',
              button: true,
              child: InkWell(
                onTap: () {
                  // TODO: Navigate to New Batch screen
                  // Route: /production/new-batch or similar
                },
                borderRadius: BorderRadius.circular(18), // More rounded
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 11,
                  ), // Reduced from 14
                  decoration: BoxDecoration(
                    color: AppColors.deepGreen,
                    borderRadius: BorderRadius.circular(
                      18,
                    ), // More rounded (was 12)
                  ),
                  child: const Center(
                    child: Text(
                      'Start Production',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15, // Reduced from 16
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
    );
  }
}

class _QuickStockAdjustmentCard extends StatelessWidget {
  const _QuickStockAdjustmentCard();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Quick Stock Adjustment',
      button: true,
      child: InkWell(
        onTap: () {
          // Navigate to Stock Movement screen (can be used for quick adjustments)
          context.push('/inventory/movement');
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ), // Shorter (reduced vertical padding)
          decoration: BoxDecoration(
            color: Colors.white, // White background
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderSubtle, width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowSoft,
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.tune,
                color: AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Title and description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Stock Adjustment',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.deepGreen,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manual quantity adjustments (wastage, corrections).',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow icon
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// RECENT ACTIVITY SECTION
// ============================================================================

class _RecentActivitySection extends ConsumerWidget {
  const _RecentActivitySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityState = ref.watch(stockingHubProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.deepGreen,
                fontSize: 18,
              ),
            ),
            Semantics(
              label: 'View All Activity',
              button: true,
              child: InkWell(
                onTap: () {
                  // TODO: Navigate to full activity view
                  // Route: /production/activity or similar
                  // This screen doesn't exist yet - navigation will be added when implemented
                },
                child: Text(
                  'View All',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.mango,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Activity items - wired to ViewModel
        activityState.when(
          data: (state) {
            if (state.isLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(color: AppColors.mango),
                ),
              );
            }

            if (state.hasError) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.error ?? 'Failed to load activity',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        ref.read(stockingHubProvider.notifier).refreshActivity();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state.recentActivity.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      color: AppColors.textSecondary,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No recent activity',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Display activity items (limit to 5 most recent)
            final displayActivities = state.recentActivity.take(5).toList();
            return Column(
              children: [
                for (int i = 0; i < displayActivities.length; i++)
                  ...[
                    _ActivityItem.fromActivityItem(activity: displayActivities[i]),
                    if (i < displayActivities.length - 1)
                      const SizedBox(height: 12),
                  ],
              ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(color: AppColors.mango),
            ),
          ),
          error: (error, stackTrace) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'Failed to load activity: ${error.toString()}',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    ref.invalidate(stockingHubProvider);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String description;
  final String change;
  final Color changeColor;
  final String timeAgo;

  const _ActivityItem({
    this.imageUrl,
    required this.title,
    required this.description,
    required this.change,
    required this.changeColor,
    required this.timeAgo,
  });

  /// Create from ActivityItem model
  factory _ActivityItem.fromActivityItem({required ActivityItem activity}) {
    // Format quantity change
    final sign = activity.isPositive ? '+' : '-';
    final changeText = '$sign${activity.quantityChange.toStringAsFixed(0)}';
    
    // Determine color based on activity type
    final changeColor = activity.type == ActivityType.production
        ? AppColors.mango
        : activity.isPositive
            ? AppColors.success
            : AppColors.error;

    // Format time ago
    final now = DateTime.now();
    final difference = now.difference(activity.timestamp);
    String timeAgo;
    if (difference.inMinutes < 60) {
      timeAgo = '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      timeAgo = '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      timeAgo = '${difference.inDays}d ago';
    } else {
      timeAgo = DateFormat('MMM d').format(activity.timestamp);
    }

    return _ActivityItem(
      imageUrl: activity.itemImage,
      title: activity.itemName,
      description: activity.activityType,
      change: changeText,
      changeColor: changeColor,
      timeAgo: timeAgo,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title - $description',
      button: true,
      child: InkWell(
        onTap: () {
          // TODO: Handle activity item tap - navigate to item details
          // This will open detail view when activity items are wired to data
        },
        borderRadius: BorderRadius.circular(20), // More rounded
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20), // More rounded
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white, // White background like alert cards
              borderRadius: BorderRadius.circular(20), // More rounded (was 16)
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowSoft,
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Left edge colored border (using changeColor)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: changeColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                ),
              ),
              // Card content
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    // Icon/image in circular background
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        shape: BoxShape.circle,
                      ),
                      child: imageUrl != null
                          ? ClipOval(
                              child: Image.network(
                                imageUrl!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              Icons.inventory_2,
                              color: AppColors.textSecondary,
                              size: 22,
                            ),
                    ),
                    const SizedBox(width: 12),
                    // Title and description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.deepGreen,
                              fontSize: 15,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2), // Reduced gap (was 4)
                          Text(
                            description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Change badge, time ago and arrow on the right
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10, // Smaller (was 12)
                            vertical: 1, // Shorter by 3 pixels (was 4)
                          ),
                          decoration: BoxDecoration(
                            // Use lighter, almost-transparent colors
                            color: changeColor == AppColors.success
                                ? AppColors.success.withOpacity(
                                    0.25,
                                  ) // Light, almost-transparent green
                                : changeColor == AppColors.mango
                                ? AppColors.mango.withOpacity(
                                    0.25,
                                  ) // Light, almost-transparent orange
                                : changeColor.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            change,
                            style: TextStyle(
                              // Use darker text color for better contrast on light background
                              color: changeColor == AppColors.success
                                  ? AppColors.success
                                  : changeColor == AppColors.mango
                                  ? AppColors.mango
                                  : changeColor,
                              fontSize: 12, // Smaller (was 13)
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6), // Increased spacing (was 4)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              timeAgo,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
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
// HELP DIALOG
// ============================================================================

void _showHelpDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.deepGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.help_outline,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Stocking Hub Help',
              style: TextStyle(
                color: AppColors.deepGreen,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HelpSection(
              title: 'Buy / Receive Supplies',
              description:
                  'Record incoming supplies like bottles, labels, ingredients, and other materials. This creates stock-in entries in your inventory.',
              icon: Icons.local_shipping,
              iconColor: AppColors.mango,
            ),
            const SizedBox(height: 16),
            _HelpSection(
              title: 'Produce Drinks',
              description:
                  'Record juice batches and production runs. This converts ingredients into finished products and adds them to inventory.',
              icon: Icons.blender,
              iconColor: AppColors.deepGreen,
            ),
            const SizedBox(height: 16),
            _HelpSection(
              title: 'Quick Stock Adjustment',
              description:
                  'Make manual quantity corrections for wastage, breakage, or other adjustments. Use this for quick fixes without going through the full movement process.',
              icon: Icons.tune,
              iconColor: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            _HelpSection(
              title: 'Recent Activity',
              description:
                  'View your recent stocking activities including supplies received and batches produced. Tap "View All" to see complete history.',
              icon: Icons.history,
              iconColor: AppColors.mango,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Got it',
            style: TextStyle(
              color: AppColors.deepGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

class _HelpSection extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;

  const _HelpSection({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepGreen,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
