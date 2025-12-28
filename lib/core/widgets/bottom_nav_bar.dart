import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:juix_na/app/app_colors.dart';

/// Custom bottom navigation bar matching design specifications.
/// Features:
/// - Light beige/off-white rounded rectangular panel
/// - Home, Stock, QR Scanner (central), Alerts, Menu items
/// - Active items show orange icon with light orange pill background
/// - Inactive items show gray icons and text
/// - Central QR scanner is a prominent circular orange button with shadow
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // White background
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24), // More rounded
          topRight: Radius.circular(24), // More rounded
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Home
              _NavItem(
                icon: Icons.grid_view_rounded,
                label: 'Home',
                isActive: currentIndex == 0,
                onTap: () {
                  if (currentIndex != 0) {
                    context.go('/dashboard');
                  }
                },
              ),
              // Stock
              _NavItem(
                icon: Icons.inventory_2_outlined,
                label: 'Stock',
                isActive: currentIndex == 1,
                onTap: () {
                  if (currentIndex != 1) {
                    context.go('/inventory');
                  }
                },
              ),
              // Central QR Scanner Button (positioned higher)
              Transform.translate(
                offset: const Offset(0, -8), // Move up by 12 pixels
                child: _QRScannerButton(
                  onTap: () {
                    // TODO: Navigate to QR scanner screen
                    debugPrint('QR Scanner tapped');
                  },
                ),
              ),
              // Alerts
              _NavItem(
                icon: Icons.notifications_outlined,
                label: 'Alerts',
                isActive: currentIndex == 3,
                onTap: () {
                  // TODO: Navigate to alerts screen
                  debugPrint('Alerts tapped');
                },
              ),
              // Menu
              _NavItem(
                icon: Icons.menu_rounded,
                label: 'Menu',
                isActive: currentIndex == 4,
                onTap: () {
                  // TODO: Navigate to menu/settings screen
                  debugPrint('Menu tapped');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Navigation item for Home, Stock, Alerts, Menu
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon with optional background pill
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.mangoLight.withOpacity(0.3) // Light orange pill
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 24,
              color: isActive ? AppColors.mango : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          // Label text
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive ? AppColors.mango : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Central QR Scanner button - prominent circular orange button with shadow
class _QRScannerButton extends StatelessWidget {
  final VoidCallback onTap;

  const _QRScannerButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.mango,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.mango.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.qr_code_scanner_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
