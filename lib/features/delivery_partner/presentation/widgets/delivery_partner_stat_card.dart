import 'package:flutter/material.dart';
import '../../../../utils/typography/airmenu_typography.dart';

class DeliveryPartnerStatCard extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String value;
  final String label;
  final String change;
  final bool isPositive;

  const DeliveryPartnerStatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.value,
    required this.label,
    required this.change,
    required this.isPositive,
  });

  @override
  State<DeliveryPartnerStatCard> createState() =>
      _DeliveryPartnerStatCardState();
}

class _DeliveryPartnerStatCardState extends State<DeliveryPartnerStatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 300,
        padding: const EdgeInsets.all(24),
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -4.0 : 0.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: widget.iconColor.withOpacity(0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.iconColor.withOpacity(_isHovered ? 0.15 : 0.05),
              blurRadius: _isHovered ? 24 : 20,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisSize: MainAxisSize.min, // Removed to allow Spacer
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.iconBgColor,
                    borderRadius: BorderRadius.circular(16), // Updated radius
                  ),
                  child: Icon(widget.icon, color: widget.iconColor, size: 24),
                ),
                if (widget.change.isNotEmpty &&
                    !widget.change.contains('yesterday'))
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: widget.isPositive
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.isPositive
                              ? Icons.trending_up
                              : Icons.trending_down,
                          size: 14,
                          color: widget.isPositive
                              ? const Color(0xFF166534)
                              : const Color(0xFF991B1B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.change,
                          style: AirMenuTextStyle.caption.copyWith(
                            fontWeight: FontWeight.bold,
                            color: widget.isPositive
                                ? const Color(0xFF166534)
                                : const Color(0xFF991B1B),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const Spacer(),

            const SizedBox(height: 24),

            Text(
              widget.value,
              style: AirMenuTextStyle.headingH1.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 36,
                color: const Color(0xFF111827),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              widget.label,
              style: AirMenuTextStyle.normal.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF374151),
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 4),

            if (widget.change.isNotEmpty && widget.change.contains('yesterday'))
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Text(
                  widget.change,
                  style: AirMenuTextStyle.small.copyWith(
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ),
            // Match IntegrationStatCard structure where description/subtext is at bottom
            if (widget.change.isEmpty && !widget.change.contains('yesterday'))
              // Placeholder to maintain spacing if needed, or remove
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
