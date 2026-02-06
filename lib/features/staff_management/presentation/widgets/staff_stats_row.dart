import 'package:flutter/material.dart';
import '../../../../utils/typography/airmenu_typography.dart';
import '../bloc/staff_state.dart';

class StaffStatsRow extends StatelessWidget {
  final StaffStats stats;

  const StaffStatsRow({super.key, required this.stats});

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
                      icon: Icons.people_outline,
                      iconColor: const Color(0xFFDC2626),
                      iconBgColor: const Color(0xFFFEE2E2),
                      count: stats.totalStaff,
                      label: 'Total Staff',
                      isMobile: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.access_time,
                      iconColor: const Color(0xFFDC2626),
                      iconBgColor: const Color(0xFFFEE2E2),
                      count: stats.activeNow,
                      label: 'Active Now',
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
                      icon: Icons.badge_outlined,
                      iconColor: const Color(0xFFDC2626),
                      iconBgColor: const Color(0xFFFEE2E2),
                      count: stats.rolesCount,
                      label: 'Roles',
                      isMobile: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.person_off_outlined,
                      iconColor: const Color(0xFFDC2626),
                      iconBgColor: const Color(0xFFFEE2E2),
                      count: stats.disabled,
                      label: 'Disabled',
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
                icon: Icons.people_outline,
                iconColor: const Color(0xFFDC2626),
                iconBgColor: const Color(0xFFFEE2E2),
                count: stats.totalStaff,
                label: 'Total Staff',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatTile(
                icon: Icons.access_time,
                iconColor: const Color(0xFFDC2626),
                iconBgColor: const Color(0xFFFEE2E2),
                count: stats.activeNow,
                label: 'Active Now',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatTile(
                icon: Icons.badge_outlined,
                iconColor: const Color(0xFFDC2626),
                iconBgColor: const Color(0xFFFEE2E2),
                count: stats.rolesCount,
                label: 'Roles',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatTile(
                icon: Icons.person_off_outlined,
                iconColor: const Color(0xFFDC2626),
                iconBgColor: const Color(0xFFFEE2E2),
                count: stats.disabled,
                label: 'Disabled',
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatTile extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final int count;
  final String label;
  final bool isMobile;

  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.count,
    required this.label,
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
                  SizedBox(height: widget.isMobile ? 12 : 16),
                  Text(
                    widget.count.toString(),
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
