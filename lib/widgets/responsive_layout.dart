import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Responsive Layout Wrapper
/// Provides a centered, max-width constrained layout for larger screens.
class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final bool centerOnWideScreen;
  final EdgeInsets? padding;

  const ResponsiveLayout({
    super.key,
    required this.child,
    this.maxWidth = 1200,
    this.centerOnWideScreen = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 600;

        if (!isWideScreen) {
          return padding != null
              ? Padding(padding: padding!, child: child)
              : child;
        }

        return Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            padding:
                padding ??
                const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingXl,
                  vertical: AppTheme.spacingLg,
                ),
            child: child,
          ),
        );
      },
    );
  }
}

/// Responsive Grid for department cards
/// Adjusts column count based on screen width.
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double mobileColumns;
  final double tabletColumns;
  final double desktopColumns;
  final double spacing;
  final double? childAspectRatio;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 2,
    this.tabletColumns = 3,
    this.desktopColumns = 4,
    this.spacing = AppTheme.spacingMd,
    this.childAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int columns;
        double aspectRatio;

        if (width >= 1200) {
          columns = desktopColumns.toInt();
          aspectRatio = childAspectRatio ?? 1.3;
        } else if (width >= 600) {
          columns = tabletColumns.toInt();
          aspectRatio = childAspectRatio ?? 1.2;
        } else {
          columns = mobileColumns.toInt();
          aspectRatio = childAspectRatio ?? 1.0;
        }

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: columns,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          childAspectRatio: aspectRatio,
          children: children,
        );
      },
    );
  }
}

/// Responsive Card Layout for lists
/// Shows cards in a grid on wide screens, list on mobile.
class ResponsiveCardLayout extends StatelessWidget {
  final List<Widget> children;
  final double maxCardWidth;
  final double spacing;

  const ResponsiveCardLayout({
    super.key,
    required this.children,
    this.maxCardWidth = 500,
    this.spacing = AppTheme.spacingMd,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 900;

        if (!isWideScreen) {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: children.length,
            separatorBuilder: (context, index) => SizedBox(height: spacing),
            itemBuilder: (_, index) => children[index],
          );
        }

        // Grid layout for wide screens
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children.map((child) {
            return SizedBox(width: maxCardWidth, child: child);
          }).toList(),
        );
      },
    );
  }
}
