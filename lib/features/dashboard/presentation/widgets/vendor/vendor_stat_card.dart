import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/dashboard/data/models/vendor/vendor_dashboard_models.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class VendorStatCard extends StatefulWidget {
  final VendorStatCardData data;
  final int index;
  final Widget? footer;

  const VendorStatCard({
    super.key,
    required this.data,
    this.index = 0,
    this.footer,
  });

  @override
  State<VendorStatCard> createState() => _VendorStatCardState();
}

class _VendorStatCardState extends State<VendorStatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -4.0 : 0.0),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: widget.data.color.withOpacity(0.80),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.data.color.withOpacity(_isHovered ? 0.15 : 0.05),
              blurRadius: _isHovered ? 24 : 20,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Icon and Trend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon Circle
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFFFFEFEF), // Light pinkish border
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    widget.data.icon,
                    color: _darkenColor(
                      widget.data.color,
                    ), // Darker icon for visibility
                    size: 20,
                  ),
                ),

                // Trend Pill (Flexible to prevent overflow)
                if (widget.data.change.isNotEmpty)
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (widget.data.isPositive
                                    ? const Color(0xFF10B981) // Green
                                    : const Color(0xFFEF4444)) // Red
                                .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.data.isPositive
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            size: 14,
                            color: widget.data.isPositive
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              widget.data.change,
                              style: AirMenuTextStyle.small.copyWith(
                                color: widget.data.isPositive
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            const Spacer(),

            // Value
            Text(
              widget.data.value,
              style: AirMenuTextStyle.headingH1.copyWith(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF111827),
                height: 1.0,
              ),
            ),

            const SizedBox(height: 8),

            // Label
            Text(
              widget.data.label,
              style: AirMenuTextStyle.normal.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),

            if (widget.footer != null) ...[
              const SizedBox(height: 16),
              widget.footer!,
            ] else ...[
              Text(
                'vs yesterday',
                style: AirMenuTextStyle.small.copyWith(
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _darkenColor(Color color, [double amount = 0.2]) {
    final hsl = HSLColor.fromColor(color);
    final darker = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return darker.toColor();
  }
}
