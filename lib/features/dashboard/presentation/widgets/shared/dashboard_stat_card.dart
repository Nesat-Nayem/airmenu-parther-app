import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/dashboard/data/models/shared/dashboard_models.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

/// Enhanced stat card widget for dashboard
class DashboardStatCard extends StatelessWidget {
  final StatCardData stat;
  final int index;
  final Widget? trailing;

  const DashboardStatCard({
    super.key,
    required this.stat,
    this.index = 0,
    this.trailing,
  });

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
              trailing: trailing,
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
  final Widget? trailing;

  const _HoverableStatCard({
    required this.stat,
    required this.animationValue,
    this.trailing,
  });

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
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: widget.stat.color.withOpacity(0.15), // Theme-based border
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.stat.color.withOpacity(
                _isHovered ? 0.15 : 0.05,
              ), // Theme-based colored shadow
              blurRadius: _isHovered ? 24 : 20,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Row: Icon and Label
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: widget.stat.color,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: widget.stat.color.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.stat.icon,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Flexible(
                        child: Text(
                          widget.stat.label,
                          style: AirMenuTextStyle.headingH4.copyWith(
                            color: const Color(0xFF1F2937),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Bottom Row: Value and Trend
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _formatAnimatedValue(
                              _extractNumericValue(widget.stat.value) *
                                  widget.animationValue,
                              widget.stat.value,
                            ),
                            style: AirMenuTextStyle.headingH1.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 36,
                              color: const Color(0xFF111827),
                              height: 1.0,
                              letterSpacing: -1.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (widget.stat.isPositive
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFEF4444))
                                  .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.stat.isPositive
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              size: 14,
                              color: widget.stat.isPositive
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444),
                            ),
                            const SizedBox(width: 2),
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: 1,
                              ), // Optical alignment
                              child: Text(
                                widget.stat.change,
                                style: AirMenuTextStyle.small.copyWith(
                                  color: widget.stat.isPositive
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFEF4444),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (widget.trailing != null) ...[
              const SizedBox(width: 16),
              widget.trailing!,
            ],
          ],
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
