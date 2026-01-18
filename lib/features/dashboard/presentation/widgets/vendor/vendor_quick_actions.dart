import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class VendorQuickActions extends StatelessWidget {
  const VendorQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AirMenuTextStyle.headingH4.copyWith(
            fontWeight: FontWeight.bold,
            color: AirMenuColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 900;
            final isTablet = constraints.maxWidth >= 600;

            final crossAxisCount = isDesktop
                ? 4
                : isTablet
                ? 3
                : 2;

            final childAspectRatio = isDesktop ? 2.5 : 1.15;

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: childAspectRatio,
              children: const [
                _QuickActionTile(
                  icon: Icons.restaurant_menu,
                  label: 'Manage Menu',
                  color: AirMenuColors.error,
                ),
                _QuickActionTile(
                  icon: Icons.inventory_2_outlined,
                  label: 'View Inventory',
                  color: Color(0xFFF59E0B),
                ),
                _QuickActionTile(
                  icon: Icons.local_fire_department_outlined,
                  label: 'Open KDS',
                  color: Color(0xFF10B981),
                ),
                _QuickActionTile(
                  icon: Icons.people_outline,
                  label: 'Manage Staff',
                  color: Color(0xFF3B82F6),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  State<_QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<_QuickActionTile> {
  bool _isHovered = false;

  bool get _isDesktop => MediaQuery.of(context).size.width >= 900;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: _isDesktop ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: _isDesktop ? (_) => setState(() => _isHovered = true) : null,
      onExit: _isDesktop ? (_) => setState(() => _isHovered = false) : null,
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Navigate to ${widget.label}')),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          transform: _isDesktop && _isHovered
              ? Matrix4.identity().scaled(1.03)
              : Matrix4.identity(),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AirMenuColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.color.withOpacity(_isHovered ? 0.3 : 0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isHovered ? 0.08 : 0.04),
                blurRadius: _isHovered ? 12 : 8,
                offset: Offset(0, _isHovered ? 4 : 2),
              ),
            ],
          ),
          child: _isDesktop ? _desktopLayout() : _mobileTabletLayout(),
        ),
      ),
    );
  }

  /// ---------------- Desktop Layout ----------------
  Widget _desktopLayout() {
    return Row(
      children: [
        _icon(),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AirMenuTextStyle.normal.copyWith(
              fontWeight: FontWeight.w600,
              color: AirMenuColors.textPrimary,
            ),
          ),
        ),
        Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AirMenuColors.textTertiary,
        ),
      ],
    );
  }

  /// ---------------- Tablet & Mobile Layout ----------------
  Widget _mobileTabletLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _icon(),
        const SizedBox(height: 12),
        Text(
          widget.label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AirMenuTextStyle.normal.copyWith(
            fontWeight: FontWeight.w600,
            color: AirMenuColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _icon() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(widget.icon, color: widget.color, size: 24),
    );
  }
}
