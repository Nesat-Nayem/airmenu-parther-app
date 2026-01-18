import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';

/// Reusable page header component for page titles
/// Only contains: Title + Subtitle + Emoji (no search/profile - that's in the main shell)
///
/// Usage:
/// ```dart
/// PageHeader(
///   title: 'Live Orders',
///   subtitle: 'Real-time order management',
///   emoji: '✨',
/// )
/// ```
class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? emoji;
  final List<Widget>? actions;
  final EdgeInsets padding;

  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.emoji,
    this.actions,
    this.padding = const EdgeInsets.fromLTRB(20, 16, 20, 8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title + Subtitle + Emoji
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AirMenuTextStyle.headingH3.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF212121),
                      ),
                    ),
                    if (emoji != null) ...[
                      const SizedBox(width: 8),
                      Text(emoji!, style: const TextStyle(fontSize: 18)),
                    ],
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: AirMenuTextStyle.small.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Optional actions (buttons, etc.)
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}
