import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/features/reports/data/models/report_stats_model.dart';

/// Report Stats Card - Optimized layout matching reference design
/// Shows: Icon (top-left), Trend Badge (top-right), Value + Label (bottom)
class ReportStatsCard extends StatelessWidget {
  final ReportStats stat;

  const ReportStatsCard({super.key, required this.stat});

  @override
  Widget build(BuildContext context) {
    final isHovered = ValueNotifier<bool>(false);

    // Determine trend color and icon
    final isUp = stat.trend == 'up';
    final isNeutral = stat.trend == 'neutral';
    final trendColor = isNeutral
        ? Colors.grey.shade500
        : (isUp ? const Color(0xFF10B981) : const Color(0xFFEF4444));

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: ValueListenableBuilder<bool>(
        valueListenable: isHovered,
        builder: (context, hovered, _) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            transform: Matrix4.identity()..translate(0.0, hovered ? -2.0 : 0.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hovered
                    ? AirMenuColors.primary.withValues(alpha: 0.3)
                    : Colors.grey.shade100,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: hovered
                      ? AirMenuColors.primary.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.03),
                  blurRadius: hovered ? 16 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Row: Icon + Trend Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Icon with colored background
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getIconBackgroundColor(),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: hovered
                            ? [
                                BoxShadow(
                                  color: _getIconColor().withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        _getIconForLabel(stat.label),
                        size: 22,
                        color: _getIconColor(),
                      ),
                    ),
                    // Trend badge (only if not neutral)
                    if (!isNeutral && stat.percentage.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: trendColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isUp
                                  ? Icons.trending_up_rounded
                                  : Icons.trending_down_rounded,
                              size: 14,
                              color: trendColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              stat.percentage,
                              style: AirMenuTextStyle.tiny.bold700().withColor(
                                trendColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                // Bottom: Value + Label
                Text(
                  stat.value,
                  style: AirMenuTextStyle.headingH3.bold700().withColor(
                    hovered ? AirMenuColors.primary : Colors.grey.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat.label,
                  style: AirMenuTextStyle.small.medium500().withColor(
                    Colors.grey.shade600,
                  ),
                ),
                if (stat.compareLabel.isNotEmpty &&
                    stat.compareLabel != stat.label) ...[
                  const SizedBox(height: 2),
                  Text(
                    stat.compareLabel,
                    style: AirMenuTextStyle.tiny.withColor(
                      Colors.grey.shade400,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _getIconForLabel(String label) {
    if (label.contains('Revenue')) return Icons.trending_up_rounded;
    if (label.contains('Orders')) return Icons.calendar_today_rounded;
    if (label.contains('Avg')) return Icons.show_chart_rounded;
    if (label.contains('Reports')) return Icons.description_outlined;
    return Icons.bar_chart_rounded;
  }

  Color _getIconColor() {
    if (stat.label.contains('Revenue')) return AirMenuColors.primary;
    if (stat.label.contains('Orders')) return AirMenuColors.primary;
    if (stat.label.contains('Avg')) return const Color(0xFF10B981);
    if (stat.label.contains('Reports')) return AirMenuColors.primary;
    return AirMenuColors.primary;
  }

  Color _getIconBackgroundColor() {
    if (stat.label.contains('Revenue'))
      return AirMenuColors.primary.withValues(alpha: 0.1);
    if (stat.label.contains('Orders'))
      return AirMenuColors.primary.withValues(alpha: 0.1);
    if (stat.label.contains('Avg'))
      return const Color(0xFF10B981).withValues(alpha: 0.1);
    if (stat.label.contains('Reports'))
      return AirMenuColors.primary.withValues(alpha: 0.1);
    return AirMenuColors.primary.withValues(alpha: 0.1);
  }
}
