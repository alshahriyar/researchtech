import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A premium, reusable Logo widget for ResearchTech.
///
/// Designed with a high-IQ, minimalist aesthetic:
/// 1. Uses the 'RT' ligature symbol asset.
/// 2. Combines with elegant typography (Medium Weight 'Research', Bold 'Tech').
/// 3. Ensures brand consistency across App and Web.
class Logo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? color;
  final double spacing;

  const Logo({
    super.key,
    this.size = 32,
    this.showText = true,
    this.color,
    this.spacing = 10,
  });

  @override
  Widget build(BuildContext context) {
    final logoColor = color ?? AppTheme.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Logo Symbol
        Image.asset(
          'assets/images/logo.png',
          width: size,
          height: size,
          color: logoColor,
          fit: BoxFit.contain,
        ),
        if (showText) ...[
          SizedBox(width: spacing),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: size * 0.75, // Proportional scaling
                color: AppTheme.textPrimary,
                letterSpacing: -0.5,
              ),
              children: [
                TextSpan(
                  text: 'Research',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                TextSpan(
                  text: 'Tech',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: logoColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
