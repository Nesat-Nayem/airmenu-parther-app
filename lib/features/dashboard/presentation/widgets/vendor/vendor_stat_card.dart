import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/dashboard/data/models/vendor/vendor_dashboard_models.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class VendorStatCard extends StatelessWidget {
  final VendorStatCardData data;
  final int index;

  const VendorStatCard({super.key, required this.data, this.index = 0});

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
            child: _HoverableVendorStatCard(
              data: data,
              animationValue: animationValue,
            ),
          ),
        );
      },
    );
  }
}

/// Stateful widget for hover effects
class _HoverableVendorStatCard extends StatefulWidget {
  final VendorStatCardData data;
  final double animationValue;

  const _HoverableVendorStatCard({
    required this.data,
    required this.animationValue,
  });

  @override
  State<_HoverableVendorStatCard> createState() =>
      _HoverableVendorStatCardState();
}

class _HoverableVendorStatCardState extends State<_HoverableVendorStatCard> {
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
        transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AirMenuColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.data.color.withOpacity(_isHovered ? 0.3 : 0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.08 : 0.04),
              blurRadius: _isHovered ? 12 : 8,
              offset: Offset(0, _isHovered ? 4 : 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.data.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.data.icon,
                    color: widget.data.iconColor,
                    size: 24,
                  ),
                ),
                const Spacer(),
                _buildChangeIndicator(),
              ],
            ),
            const SizedBox(height: 16),
            // Animated value counter
            TweenAnimationBuilder<double>(
              tween: Tween(
                begin: 0.0,
                end: _extractNumericValue(widget.data.value),
              ),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeOutCubic,
              builder: (context, animatedValue, child) {
                return Text(
                  _formatAnimatedValue(animatedValue, widget.data.value),
                  style: AirMenuTextStyle.headingH1.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AirMenuColors.textPrimary,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              widget.data.label,
              style: AirMenuTextStyle.small.copyWith(
                color: AirMenuColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.data.subtitle,
              style: AirMenuTextStyle.caption.copyWith(
                color: AirMenuColors.textTertiary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChangeIndicator() {
    final color = widget.data.isPositive
        ? AirMenuColors.success
        : AirMenuColors.error;
    final bgColor = widget.data.isPositive
        ? AirMenuColors.success.withOpacity(0.1)
        : AirMenuColors.error.withOpacity(0.1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.data.isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            widget.data.change,
            style: AirMenuTextStyle.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
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
      } else if (originalValue.contains('K')) {
        return '₹${animatedValue.toStringAsFixed(1)}K';
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
