import 'package:flutter/material.dart';
import '../../../../utils/typography/airmenu_typography.dart';
import '../../data/models/feedback_model.dart';

class FeedbackStatsRow extends StatelessWidget {
  final FeedbackStats stats;

  const FeedbackStatsRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        if (isMobile) {
          // 2x2 Grid for mobile
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      icon: Icons.star_outline,
                      iconColor: const Color(0xFFDC2626),
                      iconBgColor: const Color(0xFFFEE2E2),
                      value: stats.avgRating.toString(),
                      label: 'Avg Rating',
                      isMobile: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.chat_bubble_outline,
                      iconColor: const Color(0xFFDC2626),
                      iconBgColor: const Color(0xFFFEE2E2),
                      value: _formatNumber(stats.totalReviews),
                      label: 'Reviews',
                      isMobile: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      icon: Icons.trending_up,
                      iconColor: const Color(0xFFDC2626),
                      iconBgColor: const Color(0xFFFEE2E2),
                      value: '+${stats.thisWeekCount}',
                      label: 'This Week',
                      badge: '↑ ${stats.weeklyChangePercent.toInt()}%',
                      isMobile: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.thumb_up_outlined,
                      iconColor: const Color(0xFFDC2626),
                      iconBgColor: const Color(0xFFFEE2E2),
                      value: '${stats.positivePercent.toInt()}%',
                      label: 'Positive',
                      isMobile: true,
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        // Desktop: horizontal row
        return Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: Icons.star_outline,
                iconColor: const Color(0xFFDC2626),
                iconBgColor: const Color(0xFFFEE2E2),
                value: stats.avgRating.toString(),
                label: 'Avg Rating',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatTile(
                icon: Icons.chat_bubble_outline,
                iconColor: const Color(0xFFDC2626),
                iconBgColor: const Color(0xFFFEE2E2),
                value: _formatNumber(stats.totalReviews),
                label: 'Reviews',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatTile(
                icon: Icons.trending_up,
                iconColor: const Color(0xFFDC2626),
                iconBgColor: const Color(0xFFFEE2E2),
                value: '+${stats.thisWeekCount}',
                label: 'This Week',
                sublabel: 'vs yesterday',
                badge: '↑ ${stats.weeklyChangePercent.toInt()}%',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatTile(
                icon: Icons.thumb_up_outlined,
                iconColor: const Color(0xFFDC2626),
                iconBgColor: const Color(0xFFFEE2E2),
                value: '${stats.positivePercent.toInt()}%',
                label: 'Positive',
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

class _StatTile extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String value;
  final String label;
  final String? sublabel;
  final String? badge;
  final bool isMobile;

  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.value,
    required this.label,
    this.sublabel,
    this.badge,
    this.isMobile = false,
  });

  @override
  State<_StatTile> createState() => _StatTileState();
}

class _StatTileState extends State<_StatTile>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(widget.isMobile ? 14 : 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isHovered
                      ? const Color(0xFFDC2626).withValues(alpha: 0.3)
                      : Colors.grey.shade200,
                ),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: const Color(0xFFDC2626).withValues(alpha: 0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: widget.isMobile ? 40 : 48,
                        height: widget.isMobile ? 40 : 48,
                        decoration: BoxDecoration(
                          color: widget.iconBgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.iconColor,
                          size: widget.isMobile ? 20 : 24,
                        ),
                      ),
                      if (widget.badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF059669,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.badge!,
                            style: AirMenuTextStyle.tiny.bold600().withColor(
                              const Color(0xFF059669),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: widget.isMobile ? 12 : 16),
                  Text(
                    widget.value,
                    style: widget.isMobile
                        ? AirMenuTextStyle.headingH2.bold700().withColor(
                            Colors.grey.shade900,
                          )
                        : AirMenuTextStyle.headingH1.bold700().withColor(
                            Colors.grey.shade900,
                          ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.label,
                    style: widget.isMobile
                        ? AirMenuTextStyle.caption.withColor(
                            Colors.grey.shade500,
                          )
                        : AirMenuTextStyle.small.withColor(
                            Colors.grey.shade500,
                          ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.sublabel != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.sublabel!,
                      style: AirMenuTextStyle.tiny.withColor(
                        Colors.grey.shade400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
