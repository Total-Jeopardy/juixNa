import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:juix_na/app/app_colors.dart';
import 'package:juix_na/app/theme_controller.dart';
import 'package:juix_na/features/auth/viewmodel/auth_vm.dart';
import 'package:juix_na/features/inventory/model/inventory_models.dart';
import 'package:juix_na/features/inventory/viewmodel/inventory_filters.dart';
import 'package:juix_na/features/inventory/viewmodel/inventory_overview_state.dart';
import 'package:juix_na/features/inventory/viewmodel/inventory_overview_vm.dart';
import 'package:juix_na/features/inventory/widgets/inventory_stock_card.dart';
import 'package:juix_na/features/inventory/widgets/stat_chip.dart';

class InventoryOverviewScreen extends ConsumerStatefulWidget {
  const InventoryOverviewScreen({super.key});

  @override
  ConsumerState<InventoryOverviewScreen> createState() =>
      _InventoryOverviewScreenState();
}

class _InventoryOverviewScreenState
    extends ConsumerState<InventoryOverviewScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _activeFilter = 'All Items';
  int? _selectedItemId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    // Watch ViewModel state
    final overviewState = ref.watch(inventoryOverviewProvider);
    final viewModel = ref.read(inventoryOverviewProvider.notifier);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: cs.surface,
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
              child: Icon(
                Icons.arrow_back,
                color: isDark ? Colors.white : AppColors.deepGreen,
              ),
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
          // Logout button
          Consumer(
            builder: (context, ref, _) {
              return IconButton(
                tooltip: 'Logout',
                icon: const Icon(Icons.logout_rounded),
                color: isDark ? Colors.white : AppColors.deepGreen,
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true && mounted) {
                    await ref.read(authViewModelProvider.notifier).logout();
                    // Navigation handled by AuthGuard
                  }
                },
              );
            },
          ),
          // Theme toggle
          Consumer(
            builder: (context, ref, _) {
              final themeMode = ref.watch(themeControllerProvider);
              final themeNotifier = ref.read(themeControllerProvider.notifier);
              final isDarkMode = themeMode == ThemeMode.dark;
              
              return IconButton(
                tooltip: 'Toggle theme',
                icon: Icon(
                  isDarkMode
                      ? Icons.wb_sunny_rounded
                      : Icons.nightlight_round,
                  color: isDarkMode ? Colors.white : AppColors.deepGreen,
                ),
                onPressed: themeNotifier.toggle,
              );
            },
          ),
          // Refresh button (will reload data from API when implemented)
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
                onPressed: overviewState.isLoading
                    ? null
                    : () => viewModel.refreshInventory(),
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
                    Icon(Icons.refresh_rounded, size: 20, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Refresh',
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
        child: overviewState.when(
          data: (state) => RefreshIndicator(
            onRefresh: () => viewModel.refreshInventory(),
            child: _buildContent(context, state, viewModel, isDark),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  'Error loading inventory',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => viewModel.refreshInventory(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    InventoryOverviewState state,
    InventoryOverviewViewModel viewModel,
    bool isDark,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          _StatusContent(
            state: state,
            viewModel: viewModel,
            searchController: _searchController,
          ),
          const SizedBox(height: 18),
          _FilterChipsBar(
            activeFilter: _activeFilter,
            onFilterSelected: (label) {
              setState(() => _activeFilter = label);
              _applyFilterByLabel(label, state, viewModel);
            },
          ),
          const SizedBox(height: 15),
          if (state.isAnyLoading && state.items.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (state.items.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        size: 64, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    Text(
                      'No items found',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
            )
          else
            _StockListView(
              items: state.items,
              selectedId: _selectedItemId,
              onSelect: (id) => setState(() => _selectedItemId = id),
            ),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  /// Apply filter based on label selection.
  void _applyFilterByLabel(
    String label,
    InventoryOverviewState state,
    InventoryOverviewViewModel viewModel,
  ) {

    switch (label) {
      case 'All Items':
        // Clear all filters
        viewModel.applyFilters(const InventoryFilters());
        break;
      case 'Category':
        // Category filter - show kind picker (maps to ItemKind)
        _showKindPicker(context, state, viewModel);
        break;
      case 'Location':
        // Location is already handled by the location selector chip
        // This filter chip is redundant, but we can keep it for UI consistency
        // Do nothing - location filtering is handled by _LocationChip
        break;
      case 'Brand':
        // Brand filter not yet supported by API
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Brand filtering is not yet available'),
            duration: Duration(seconds: 2),
          ),
        );
        break;
    }
  }

  /// Show kind picker for Category filter.
  void _showKindPicker(
    BuildContext context,
    InventoryOverviewState state,
    InventoryOverviewViewModel viewModel,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filter by Type',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('All Types'),
              leading: Radio<ItemKind?>(
                value: null,
                groupValue: state.filters.kind,
                onChanged: (value) {
                  final newFilters = state.filters.copyWith(clearKind: true);
                  viewModel.applyFilters(newFilters);
                  Navigator.pop(context);
                },
              ),
            ),
            ...ItemKind.values.map((kind) => ListTile(
                  title: Text(kind.value.replaceAll('_', ' ')),
                  leading: Radio<ItemKind?>(
                    value: kind,
                    groupValue: state.filters.kind,
                    onChanged: (value) {
                      final newFilters = state.filters.copyWith(kind: value);
                      viewModel.applyFilters(newFilters);
                      Navigator.pop(context);
                    },
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _StatusContent extends ConsumerWidget {
  final InventoryOverviewState state;
  final InventoryOverviewViewModel viewModel;
  final TextEditingController searchController;

  const _StatusContent({
    required this.state,
    required this.viewModel,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Wrap(
          spacing: 20,
          runSpacing: 15,
          children: [
            _LocationChip(
              locations: state.locations,
              selectedLocationId: state.selectedLocationId,
              onLocationSelected: (locationId) =>
                  viewModel.selectLocation(locationId),
            ),
            const _OnlineChip(),
          ],
        ),
        const SizedBox(height: 16),
        _SearchField(
          controller: searchController,
          onSearchChanged: (query) {
            // Debounce search - apply filter after user stops typing
            // For now, apply immediately (can add debounce later)
            final filters = state.filters.copyWith(search: query.isEmpty ? null : query);
            viewModel.applyFilters(filters);
          },
        ),
        const SizedBox(height: 16),
        _StatsChips(kpis: state.kpis),
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
        : (isDark ? AppColors.darkPill : colorScheme.surface);
    final textColor = isSelected
        ? Colors.white
        : (isDark ? AppColors.darkTextPrimary : AppColors.deepGreen);
    final borderColor = isSelected
        ? Colors.transparent
        : (isDark
              ? AppColors.borderSubtle.withOpacity(0.3)
              : AppColors.borderSoft);

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
                style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
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
  final List<InventoryItem> items;
  final int? selectedId;
  final ValueChanged<int> onSelect;

  const _StockListView({
    required this.items,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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
  final List<Location> locations;
  final int? selectedLocationId;
  final ValueChanged<int?> onLocationSelected;

  const _LocationChip({
    required this.locations,
    required this.selectedLocationId,
    required this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? AppColors.darkPill
        : AppColors.mangoLight.withOpacity(0.1);
    final borderColor = isDark
        ? AppColors.borderSubtle.withOpacity(0.3)
        : AppColors.mangoLight;

    final selectedLocation = locations.firstWhere(
      (loc) => loc.id == selectedLocationId,
      orElse: () => locations.firstOrNull ?? Location(
        id: -1,
        name: 'All Locations',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    final displayName = selectedLocationId == null
        ? 'All Locations'
        : selectedLocation.name;

    return InkWell(
      onTap: () => _showLocationPicker(context),
      borderRadius: BorderRadius.circular(18),
      child: DecoratedBox(
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
                displayName,
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.deepGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_drop_down, color: AppColors.mango),
            ],
          ),
        ),
      ),
    );
  }

  void _showLocationPicker(BuildContext context) {
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
            ListTile(
              title: const Text('All Locations'),
              leading: Radio<int?>(
                value: null,
                groupValue: selectedLocationId,
                onChanged: (value) {
                  onLocationSelected(value);
                  Navigator.pop(context);
                },
              ),
            ),
            ...locations.map((location) => ListTile(
                  title: Text(location.name),
                  subtitle: location.description != null
                      ? Text(location.description!)
                      : null,
                  leading: Radio<int?>(
                    value: location.id,
                    groupValue: selectedLocationId,
                    onChanged: (value) {
                      onLocationSelected(value);
                      Navigator.pop(context);
                    },
                  ),
                )),
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
    final borderColor = isDark
        ? Colors.transparent
        : AppColors.success.withOpacity(0.35);

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
              'Online \u2022 ${DateFormat('h:mm a').format(DateTime.now())}',
              style: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : AppColors.deepGreen,
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
  final TextEditingController controller;
  final ValueChanged<String> onSearchChanged;

  const _SearchField({
    required this.controller,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: controller,
      onChanged: onSearchChanged,
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
  final InventoryOverviewKPIs? kpis;

  const _StatsChips({required this.kpis});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Format numbers
    final totalQuantity = kpis?.totalQuantityAllLocations ?? 0.0;
    final formattedQuantity = totalQuantity.toStringAsFixed(0);
    final lowStockCount = kpis?.lowStockItems ?? 0;
    final totalItems = kpis?.totalItems ?? 0;
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          StatChip(
            title: 'CURRENT STOCK',
            value: formattedQuantity,
            suffix: 'units',
            background: isDark ? AppColors.darkPill : AppColors.surface,
            borderColor: isDark
                ? AppColors.borderSubtle.withOpacity(0.2)
                : AppColors.borderSoft,
            titleColor: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            valueColor: isDark
                ? AppColors.darkTextPrimary
                : AppColors.deepGreen,
            suffixColor: AppColors.mango,
          ),
          const SizedBox(width: 12),
          StatChip(
            title: 'TOTAL ITEMS',
            value: totalItems.toString(),
            backgroundGradient: AppGradients.primary,
            titleColor: Colors.white,
            valueColor: Colors.white,
          ),
          const SizedBox(width: 12),
          StatChip(
            title: 'LOW STOCK',
            value: lowStockCount.toString(),
            background: isDark ? AppColors.darkPill : AppColors.errorSoft,
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
