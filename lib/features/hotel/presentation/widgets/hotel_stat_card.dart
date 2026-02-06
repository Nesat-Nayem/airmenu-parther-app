import 'package:flutter/material.dart';
import '../../../../utils/typography/airmenu_typography.dart';
import '../../data/models/hotel_models.dart';

class HotelStatCard extends StatefulWidget {
  final HotelStat stat;

  const HotelStatCard({super.key, required this.stat});

  @override
  State<HotelStatCard> createState() => _HotelStatCardState();
}

class _HotelStatCardState extends State<HotelStatCard> {
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
            color: widget.stat.iconColor.withOpacity(0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.stat.iconColor.withOpacity(
                _isHovered ? 0.15 : 0.05,
              ),
              blurRadius: _isHovered ? 24 : 20,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.stat.iconBgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    widget.stat.icon,
                    color: widget.stat.iconColor,
                    size: 24,
                  ),
                ),
                if (widget.stat.trend != 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: widget.stat.trend > 0
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.stat.trend > 0
                              ? Icons.trending_up
                              : Icons.trending_down,
                          size: 14,
                          color: widget.stat.trend > 0
                              ? const Color(0xFF166534)
                              : const Color(0xFF991B1B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.stat.trend.abs()}%',
                          style: AirMenuTextStyle.caption.copyWith(
                            fontWeight: FontWeight.bold,
                            color: widget.stat.trend > 0
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
            Text(
              widget.stat.value,
              style: AirMenuTextStyle.headingH1.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 36,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.stat.label,
              style: AirMenuTextStyle.normal.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF374151),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.stat.subtext,
              style: AirMenuTextStyle.small.copyWith(
                color: const Color(0xFF6B7280),
              ),
            ),
            if (widget.stat.comparisonText.isNotEmpty)
              Text(
                widget.stat.comparisonText,
                style: AirMenuTextStyle.small.copyWith(
                  color: const Color(0xFF9CA3AF),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
