import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// App bar variant types
enum CustomAppBarVariant {
  /// Standard app bar with title and actions
  standard,

  /// Collapsible app bar with large title (SliverAppBar)
  collapsible,

  /// Centered title variant
  centered,

  /// Transparent app bar for overlays
  transparent,
}

/// Custom app bar widget for the personal finance application
/// Implements Material 3 design with financial app specific features
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Title text to display
  final String title;

  /// Optional subtitle for additional context
  final String? subtitle;

  /// Leading widget (typically back button or menu)
  final Widget? leading;

  /// Action widgets displayed on the right
  final List<Widget>? actions;

  /// App bar variant
  final CustomAppBarVariant variant;

  /// Whether to show the back button
  final bool showBackButton;

  /// Custom background color
  final Color? backgroundColor;

  /// Custom elevation
  final double? elevation;

  /// Whether to show bottom border
  final bool showBottomBorder;

  /// Callback when back button is pressed
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.variant = CustomAppBarVariant.standard,
    this.showBackButton = false,
    this.backgroundColor,
    this.elevation,
    this.showBottomBorder = false,
    this.onBackPressed,
  });

  @override
  Size get preferredSize {
    // Standard height for app bar
    double height = 56.0;

    // Add extra height for subtitle
    if (subtitle != null) {
      height += 20.0;
    }

    return Size.fromHeight(height);
  }

  /// Handle back button press with haptic feedback
  void _handleBackPress(BuildContext context) {
    HapticFeedback.lightImpact();

    if (onBackPressed != null) {
      onBackPressed!();
    } else {
      Navigator.of(context).pop();
    }
  }

  /// Build leading widget
  Widget? _buildLeading(BuildContext context, ThemeData theme) {
    if (leading != null) {
      return leading;
    }

    if (showBackButton) {
      return IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => _handleBackPress(context),
        tooltip: 'Volver',
        color: theme.colorScheme.onSurface,
      );
    }

    return null;
  }

  /// Build title widget
  Widget _buildTitle(ThemeData theme) {
    if (subtitle != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: variant == CustomAppBarVariant.centered
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2),
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine background color
    final bgColor =
        backgroundColor ??
        (variant == CustomAppBarVariant.transparent
            ? Colors.transparent
            : colorScheme.surface);

    // Determine elevation
    final appBarElevation =
        elevation ?? (variant == CustomAppBarVariant.transparent ? 0.0 : 0.0);

    return Container(
      decoration: showBottomBorder
          ? BoxDecoration(
              color: bgColor,
              border: Border(
                bottom: BorderSide(color: colorScheme.outline, width: 1),
              ),
            )
          : BoxDecoration(color: bgColor),
      child: AppBar(
        title: _buildTitle(theme),
        leading: _buildLeading(context, theme),
        actions: actions,
        centerTitle: variant == CustomAppBarVariant.centered,
        backgroundColor: Colors.transparent,
        elevation: appBarElevation,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: theme.brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
          statusBarBrightness: theme.brightness,
        ),
      ),
    );
  }
}

/// Collapsible app bar for scrollable content
/// Use this with CustomScrollView and SliverList
class CustomSliverAppBar extends StatelessWidget {
  /// Title text to display
  final String title;

  /// Optional subtitle for additional context
  final String? subtitle;

  /// Leading widget (typically back button or menu)
  final Widget? leading;

  /// Action widgets displayed on the right
  final List<Widget>? actions;

  /// Whether to show the back button
  final bool showBackButton;

  /// Custom background color
  final Color? backgroundColor;

  /// Expanded height when not collapsed
  final double expandedHeight;

  /// Whether the app bar should float
  final bool floating;

  /// Whether the app bar should pin when scrolled
  final bool pinned;

  /// Whether the app bar should snap
  final bool snap;

  /// Flexible space widget (shown when expanded)
  final Widget? flexibleSpace;

  /// Callback when back button is pressed
  final VoidCallback? onBackPressed;

  const CustomSliverAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.showBackButton = false,
    this.backgroundColor,
    this.expandedHeight = 120.0,
    this.floating = false,
    this.pinned = true,
    this.snap = false,
    this.flexibleSpace,
    this.onBackPressed,
  });

  /// Handle back button press with haptic feedback
  void _handleBackPress(BuildContext context) {
    HapticFeedback.lightImpact();

    if (onBackPressed != null) {
      onBackPressed!();
    } else {
      Navigator.of(context).pop();
    }
  }

  /// Build leading widget
  Widget? _buildLeading(BuildContext context, ThemeData theme) {
    if (leading != null) {
      return leading;
    }

    if (showBackButton) {
      return IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => _handleBackPress(context),
        tooltip: 'Volver',
        color: theme.colorScheme.onSurface,
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SliverAppBar(
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: _buildLeading(context, theme),
      actions: actions,
      backgroundColor: backgroundColor ?? colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 2,
      expandedHeight: expandedHeight,
      floating: floating,
      pinned: pinned,
      snap: snap,
      flexibleSpace:
          flexibleSpace ??
          FlexibleSpaceBar(
            title: subtitle != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  )
                : null,
            titlePadding: EdgeInsets.only(left: 16, bottom: 16),
            expandedTitleScale: 1.3,
          ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        statusBarBrightness: theme.brightness,
      ),
    );
  }
}
