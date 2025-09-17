import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom app bar widget implementing Industrial Trust design system
/// Provides consistent navigation and branding across the application
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The title to display in the app bar
  final String title;

  /// Whether to show the back button (defaults to true when there's a previous route)
  final bool showBackButton;

  /// Custom leading widget (overrides back button if provided)
  final Widget? leading;

  /// List of action widgets to display on the right side
  final List<Widget>? actions;

  /// Whether to center the title (defaults to true on iOS, false on Android)
  final bool? centerTitle;

  /// Background color override (uses theme color if not provided)
  final Color? backgroundColor;

  /// Foreground color override (uses theme color if not provided)
  final Color? foregroundColor;

  /// Elevation override (uses theme elevation if not provided)
  final double? elevation;

  /// Whether to show a bottom border
  final bool showBottomBorder;

  /// App bar variant for different contexts
  final CustomAppBarVariant variant;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.leading,
    this.actions,
    this.centerTitle,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.showBottomBorder = false,
    this.variant = CustomAppBarVariant.standard,
  });

  /// Factory constructor for home screen app bar
  factory CustomAppBar.home({
    Key? key,
    required String title,
    List<Widget>? actions,
  }) {
    return CustomAppBar(
      key: key,
      title: title,
      showBackButton: false,
      actions: actions ??
          [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => Navigator.pushNamed(context, '/settings'),
                tooltip: 'Settings',
              ),
            ),
          ],
      variant: CustomAppBarVariant.home,
    );
  }

  /// Factory constructor for detail screen app bar
  factory CustomAppBar.detail({
    Key? key,
    required String title,
    List<Widget>? actions,
  }) {
    return CustomAppBar(
      key: key,
      title: title,
      actions: actions,
      variant: CustomAppBarVariant.detail,
      showBottomBorder: true,
    );
  }

  /// Factory constructor for form screen app bar
  factory CustomAppBar.form({
    Key? key,
    required String title,
    VoidCallback? onSave,
  }) {
    return CustomAppBar(
      key: key,
      title: title,
      actions: onSave != null
          ? [
              Builder(
                builder: (context) => TextButton(
                  onPressed: onSave,
                  child: Text(
                    'Save',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ]
          : null,
      variant: CustomAppBarVariant.form,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appBarTheme = theme.appBarTheme;

    // Determine colors based on variant and theme
    final effectiveBackgroundColor =
        backgroundColor ?? _getBackgroundColor(variant, colorScheme);
    final effectiveForegroundColor =
        foregroundColor ?? _getForegroundColor(variant, colorScheme);
    final effectiveElevation = elevation ?? _getElevation(variant);

    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: _getTitleFontSize(variant),
          fontWeight: _getTitleFontWeight(variant),
          color: effectiveForegroundColor,
          letterSpacing: -0.02,
        ),
      ),
      centerTitle: centerTitle ?? _shouldCenterTitle(variant),
      backgroundColor: effectiveBackgroundColor,
      foregroundColor: effectiveForegroundColor,
      elevation: effectiveElevation,
      surfaceTintColor: Colors.transparent,
      shadowColor: colorScheme.shadow,
      leading: _buildLeading(context, effectiveForegroundColor),
      actions: _buildActions(context, effectiveForegroundColor),
      bottom: showBottomBorder
          ? PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: Container(
                height: 1.0,
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            )
          : null,
      iconTheme: IconThemeData(
        color: effectiveForegroundColor,
        size: 24,
      ),
      actionsIconTheme: IconThemeData(
        color: effectiveForegroundColor,
        size: 24,
      ),
    );
  }

  Widget? _buildLeading(BuildContext context, Color foregroundColor) {
    if (leading != null) return leading;

    if (!showBackButton) return null;

    final canPop = Navigator.of(context).canPop();
    if (!canPop) return null;

    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => Navigator.of(context).pop(),
      tooltip: 'Back',
      color: foregroundColor,
    );
  }

  List<Widget>? _buildActions(BuildContext context, Color foregroundColor) {
    if (actions != null) return actions;

    // Default actions based on variant
    switch (variant) {
      case CustomAppBarVariant.home:
        return [
          IconButton(
            icon: const Icon(Icons.search_outlined),
            onPressed: () {
              // Implement search functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Search functionality coming soon')),
              );
            },
            tooltip: 'Search',
            color: foregroundColor,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            tooltip: 'Settings',
            color: foregroundColor,
          ),
        ];
      case CustomAppBarVariant.detail:
        return [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              // Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Share functionality coming soon')),
              );
            },
            tooltip: 'Share',
            color: foregroundColor,
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: foregroundColor),
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  // Navigate to edit screen
                  break;
                case 'delete':
                  // Show delete confirmation
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined),
                    SizedBox(width: 12),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline),
                    SizedBox(width: 12),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        ];
      default:
        return null;
    }
  }

  Color _getBackgroundColor(
      CustomAppBarVariant variant, ColorScheme colorScheme) {
    switch (variant) {
      case CustomAppBarVariant.home:
      case CustomAppBarVariant.standard:
      case CustomAppBarVariant.detail:
      case CustomAppBarVariant.form:
        return colorScheme.surface;
    }
  }

  Color _getForegroundColor(
      CustomAppBarVariant variant, ColorScheme colorScheme) {
    switch (variant) {
      case CustomAppBarVariant.home:
      case CustomAppBarVariant.standard:
      case CustomAppBarVariant.detail:
      case CustomAppBarVariant.form:
        return colorScheme.onSurface;
    }
  }

  double _getElevation(CustomAppBarVariant variant) {
    switch (variant) {
      case CustomAppBarVariant.home:
        return 0.0;
      case CustomAppBarVariant.standard:
      case CustomAppBarVariant.detail:
        return 1.0;
      case CustomAppBarVariant.form:
        return 2.0;
    }
  }

  double _getTitleFontSize(CustomAppBarVariant variant) {
    switch (variant) {
      case CustomAppBarVariant.home:
        return 20;
      case CustomAppBarVariant.standard:
      case CustomAppBarVariant.detail:
      case CustomAppBarVariant.form:
        return 18;
    }
  }

  FontWeight _getTitleFontWeight(CustomAppBarVariant variant) {
    switch (variant) {
      case CustomAppBarVariant.home:
        return FontWeight.w700;
      case CustomAppBarVariant.standard:
      case CustomAppBarVariant.detail:
      case CustomAppBarVariant.form:
        return FontWeight.w600;
    }
  }

  bool _shouldCenterTitle(CustomAppBarVariant variant) {
    switch (variant) {
      case CustomAppBarVariant.home:
        return false;
      case CustomAppBarVariant.standard:
      case CustomAppBarVariant.detail:
      case CustomAppBarVariant.form:
        return true;
    }
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (showBottomBorder ? 1.0 : 0.0),
      );
}

/// Enum defining different app bar variants for various contexts
enum CustomAppBarVariant {
  /// Standard app bar for most screens
  standard,

  /// Home screen app bar with search and settings
  home,

  /// Detail screen app bar with share and menu options
  detail,

  /// Form screen app bar with save action
  form,
}
