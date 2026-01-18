import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/dashboard/data/models/shared/dashboard_models.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

/// Enhanced stat card widget for dashboard
class DashboardStatCard extends StatelessWidget {
  final StatCardData stat;
  final int index;

  const DashboardStatCard({super.key, required this.stat, this.index = 0});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, animationValue, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animationValue)),
          child: Opacity(
            opacity: animationValue,
            child: _HoverableStatCard(
              stat: stat,
              animationValue: animationValue,
            ),
          ),
        );
      },
    );
  }
}

/// Stateful widget for hover effects (UI state only)
class _HoverableStatCard extends StatefulWidget {
  final StatCardData stat;
  final double animationValue;

  const _HoverableStatCard({required this.stat, required this.animationValue});

  @override
  State<_HoverableStatCard> createState() => _HoverableStatCardState();
}

class _HoverableStatCardState extends State<_HoverableStatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -4.0 : 0.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? widget.stat.color.withOpacity(0.3)
                : const Color(0xFFF3F4F6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.08 : 0.04),
              blurRadius: _isHovered ? 15 : 12,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate responsive sizes based on available space
            final availableHeight = constraints.maxHeight;
            final availableWidth = constraints.maxWidth;
            final isCompact = availableHeight < 150 || availableWidth < 160;

            final padding = isCompact ? 10.0 : 16.0;
            final iconSize = isCompact ? 18.0 : 22.0;
            final iconPadding = isCompact ? 6.0 : 10.0;

            return Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon and percentage row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Icon container
                      Container(
                        padding: EdgeInsets.all(iconPadding),
                        decoration: BoxDecoration(
                          color: widget.stat.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          widget.stat.icon,
                          color: widget.stat.color,
                          size: iconSize,
                        ),
                      ),
                      // Percentage change badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isCompact ? 4 : 6,
                          vertical: isCompact ? 2 : 3,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (widget.stat.isPositive
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFEF4444))
                                  .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.stat.isPositive
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              size: isCompact ? 8 : 10,
                              color: widget.stat.isPositive
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444),
                            ),
                            SizedBox(width: isCompact ? 1 : 2),
                            Text(
                              widget.stat.change,
                              style: TextStyle(
                                color: widget.stat.isPositive
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                                fontWeight: FontWeight.w600,
                                fontSize: isCompact ? 9 : 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Flexible spacer
                  const Spacer(flex: 1),
                  // Value - uses FittedBox to prevent overflow
                  Flexible(
                    flex: 2,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(
                          begin: 0.0,
                          end: _extractNumericValue(widget.stat.value),
                        ),
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeOutCubic,
                        builder: (context, animatedValue, child) {
                          return Text(
                            _formatAnimatedValue(
                              animatedValue,
                              widget.stat.value,
                            ),
                            style: AirMenuTextStyle.headingH2.copyWith(
                              fontWeight: FontWeight.bold,
                              color: widget.stat.color,
                              fontSize: 26,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: isCompact ? 2 : 4),
                  // Label - uses FittedBox to prevent overflow
                  Flexible(
                    flex: 1,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.stat.label,
                        style: AirMenuTextStyle.small.copyWith(
                          color: const Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Extract numeric value from string for animation
  double _extractNumericValue(String value) {
    final numericString = value.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(numericString) ?? 0.0;
  }

  /// Format animated value to match original format
  String _formatAnimatedValue(double animatedValue, String originalValue) {
    if (originalValue.contains('₹')) {
      if (originalValue.contains('L')) {
        return '₹${animatedValue.toStringAsFixed(1)}L';
      }
      return '₹${animatedValue.toInt().toString()}';
    } else if (originalValue.contains('%')) {
      return '${animatedValue.toStringAsFixed(1)}%';
    } else if (originalValue.contains('m')) {
      return '${animatedValue.toStringAsFixed(1)}m';
    } else if (originalValue.contains(',')) {
      return animatedValue.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    }
    return animatedValue.toInt().toString();
  }
}
