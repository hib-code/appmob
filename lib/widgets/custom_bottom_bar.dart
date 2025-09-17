import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom bottom navigation bar implementing Industrial Trust design system
/// Provides main navigation for field service professionals
class CustomBottomBar extends StatelessWidget {
  /// Current selected index
  final int currentIndex;

  /// Callback when a tab is tapped
  final ValueChanged<int> onTap;

  /// Bottom bar variant for different contexts
  final CustomBottomBarVariant variant;

  /// Whether to show labels (defaults to true)
  final bool showLabels;

  /// Custom background color override
  final Color? backgroundColor;

  /// Custom selected item color override
  final Color? selectedItemColor;

  /// Custom unselected item color override
  final Color? unselectedItemColor;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.variant = CustomBottomBarVariant.standard,
    this.showLabels = true,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
  });

  /// Factory constructor for main navigation
  factory CustomBottomBar.main({
    Key? key,
    required int currentIndex,
    required ValueChanged<int> onTap,
  }) {
    return CustomBottomBar(
      key: key,
      currentIndex: currentIndex,
      onTap: onTap,
      variant: CustomBottomBarVariant.main,
    );
  }

  /// Factory constructor for compact navigation (icons only)
  factory CustomBottomBar.compact({
    Key? key,
    required int currentIndex,
    required ValueChanged<int> onTap,
  }) {
    return CustomBottomBar(
      key: key,
      currentIndex: currentIndex,
      onTap: onTap,
      variant: CustomBottomBarVariant.compact,
      showLabels: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveBackgroundColor = backgroundColor ?? colorScheme.surface;
    final effectiveSelectedColor = selectedItemColor ?? colorScheme.primary;
    final effectiveUnselectedColor =
        unselectedItemColor ?? colorScheme.onSurfaceVariant;

    return Container(
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            offset: const Offset(0, -2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: _getBarHeight(),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildNavigationItems(
              context,
              effectiveSelectedColor,
              effectiveUnselectedColor,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNavigationItems(
    BuildContext context,
    Color selectedColor,
    Color unselectedColor,
  ) {
    final items = _getNavigationItems();

    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isSelected = index == currentIndex;

      return Expanded(
        child: _NavigationItem(
          icon: item.icon,
          selectedIcon: item.selectedIcon,
          label: item.label,
          isSelected: isSelected,
          showLabel: showLabels,
          selectedColor: selectedColor,
          unselectedColor: unselectedColor,
          onTap: () => _handleTap(context, index, item.route),
          variant: variant,
        ),
      );
    }).toList();
  }

  void _handleTap(BuildContext context, int index, String route) {
    onTap(index);

    // Navigate to the corresponding route
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute != route) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        route,
        (route) => false,
      );
    }
  }

  List<_NavigationItemData> _getNavigationItems() {
    switch (variant) {
      case CustomBottomBarVariant.main:
      case CustomBottomBarVariant.standard:
        return [
          _NavigationItemData(
            icon: Icons.add_business_outlined,
            selectedIcon: Icons.add_business,
            label: 'Add Client',
            route: '/add-client',
          ),
          _NavigationItemData(
            icon: Icons.build_outlined,
            selectedIcon: Icons.build,
            label: 'Add Service',
            route: '/add-service',
          ),
          _NavigationItemData(
            icon: Icons.photo_library_outlined,
            selectedIcon: Icons.photo_library,
            label: 'Photos',
            route: '/photo-gallery',
          ),
          _NavigationItemData(
            icon: Icons.description_outlined,
            selectedIcon: Icons.description,
            label: 'Reports',
            route: '/generate-report',
          ),
        ];
      case CustomBottomBarVariant.compact:
        return [
          _NavigationItemData(
            icon: Icons.add_business_outlined,
            selectedIcon: Icons.add_business,
            label: 'Clients',
            route: '/add-client',
          ),
          _NavigationItemData(
            icon: Icons.build_outlined,
            selectedIcon: Icons.build,
            label: 'Services',
            route: '/add-service',
          ),
          _NavigationItemData(
            icon: Icons.photo_library_outlined,
            selectedIcon: Icons.photo_library,
            label: 'Photos',
            route: '/photo-gallery',
          ),
          _NavigationItemData(
            icon: Icons.description_outlined,
            selectedIcon: Icons.description,
            label: 'Reports',
            route: '/generate-report',
          ),
          _NavigationItemData(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
            label: 'Settings',
            route: '/settings',
          ),
        ];
    }
  }

  double _getBarHeight() {
    switch (variant) {
      case CustomBottomBarVariant.main:
      case CustomBottomBarVariant.standard:
        return showLabels ? 72 : 56;
      case CustomBottomBarVariant.compact:
        return showLabels ? 64 : 48;
    }
  }
}

/// Individual navigation item widget
class _NavigationItem extends StatelessWidget {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final bool isSelected;
  final bool showLabel;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;
  final CustomBottomBarVariant variant;

  const _NavigationItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.showLabel,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
    required this.variant,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isSelected ? selectedColor : unselectedColor;
    final effectiveIcon =
        isSelected && selectedIcon != null ? selectedIcon! : icon;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with selection indicator
              Container(
                padding: const EdgeInsets.all(8),
                decoration: isSelected
                    ? BoxDecoration(
                        color: selectedColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      )
                    : null,
                child: Icon(
                  effectiveIcon,
                  size: _getIconSize(),
                  color: effectiveColor,
                ),
              ),

              // Label (if enabled)
              if (showLabel) ...[
                const SizedBox(height: 4),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: _getLabelFontSize(),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: effectiveColor,
                    letterSpacing: 0.1,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  double _getIconSize() {
    switch (variant) {
      case CustomBottomBarVariant.main:
      case CustomBottomBarVariant.standard:
        return 24;
      case CustomBottomBarVariant.compact:
        return 22;
    }
  }

  double _getLabelFontSize() {
    switch (variant) {
      case CustomBottomBarVariant.main:
      case CustomBottomBarVariant.standard:
        return 12;
      case CustomBottomBarVariant.compact:
        return 11;
    }
  }
}

/// Data class for navigation items
class _NavigationItemData {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final String route;

  const _NavigationItemData({
    required this.icon,
    this.selectedIcon,
    required this.label,
    required this.route,
  });
}

/// Enum defining different bottom bar variants
enum CustomBottomBarVariant {
  /// Standard bottom bar with 4 main navigation items
  standard,

  /// Main navigation variant (same as standard)
  main,

  /// Compact variant with 5 items including settings
  compact,
}
