import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'hoverable_card.dart';

class PaymentBottomCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final String? trend;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  const PaymentBottomCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.trend,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return HoverableCard(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AirMenuTextStyle.small.copyWith(
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AirMenuTextStyle.headingH3.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111827),
                fontSize: 24,
              ),
            ),
            if (trend != null || subtitle != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (trend != null) ...[
                    Icon(Icons.north_east, size: 14, color: iconColor),
                    const SizedBox(width: 4),
                    Text(
                      trend!,
                      style: AirMenuTextStyle.tiny.copyWith(
                        color: iconColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (subtitle != null && trend == null)
                    Text(
                      subtitle!,
                      style: AirMenuTextStyle.tiny.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
