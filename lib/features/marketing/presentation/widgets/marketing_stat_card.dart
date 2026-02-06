import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/marketing/data/models/marketing_stats_model.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

/// Stat card widget for marketing page top tiles
class MarketingStatCard extends StatelessWidget {
  final MarketingStatCardData stat;
  final int index;

  const MarketingStatCard({super.key, required this.stat, this.index = 0});

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
  final MarketingStatCardData stat;
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
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: widget.stat.color.withOpacity(0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.stat.color.withOpacity(_isHovered ? 0.15 : 0.05),
              blurRadius: _isHovered ? 24 : 20,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact =
                constraints.maxHeight < 150 || constraints.maxWidth < 160;
            final padding = isCompact ? 12.0 : 16.0;
            final iconSize = isCompact ? 20.0 : 24.0;
            final iconPadding = isCompact ? 8.0 : 12.0;

            return Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon and percentage row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Icon container
                      Container(
                        padding: EdgeInsets.all(iconPadding),
                        decoration: BoxDecoration(
                          color: widget.stat.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          widget.stat.icon,
                          color: widget.stat.color,
                          size: iconSize,
                        ),
                      ),
                      // Percentage change badge (if available)
                      if (widget.stat.change.isNotEmpty)
                        _buildChangeBadge(isCompact),
                    ],
                  ),
                  const Spacer(flex: 1),
                  // Value
                  Flexible(
                    flex: 2,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.stat.value,
                        style: AirMenuTextStyle.headingH2.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1C1C1C),
                          fontSize: 28,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Label
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
                  // Subtitle (vs yesterday)
                  if (widget.stat.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.stat.subtitle!,
                      style: AirMenuTextStyle.caption.copyWith(
                        color: const Color(0xFF9CA3AF),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildChangeBadge(bool isCompact) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 6 : 8,
        vertical: isCompact ? 3 : 4,
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
            widget.stat.isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            size: isCompact ? 10 : 12,
            color: widget.stat.isPositive
                ? const Color(0xFF10B981)
                : const Color(0xFFEF4444),
          ),
          const SizedBox(width: 2),
          Text(
            widget.stat.change,
            style: TextStyle(
              color: widget.stat.isPositive
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
              fontWeight: FontWeight.w600,
              fontSize: isCompact ? 10 : 11,
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton loader for stat cards
class MarketingStatCardSkeleton extends StatelessWidget {
  const MarketingStatCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_shimmerBox(44, 44, 10), _shimmerBox(50, 24, 6)],
          ),
          const Spacer(),
          _shimmerBox(80, 32, 4),
          const SizedBox(height: 8),
          _shimmerBox(100, 14, 4),
        ],
      ),
    );
  }

  Widget _shimmerBox(double width, double height, double radius) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
