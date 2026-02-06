import 'package:flutter/material.dart';
import '../../../../utils/typography/airmenu_typography.dart';

class DeliveryPartnerEmptyState extends StatelessWidget {
  final String message;

  const DeliveryPartnerEmptyState({
    super.key,
    this.message = 'No delivery partners found',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              size: 64,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: AirMenuTextStyle.headingH4.copyWith(
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a delivery partner to get started',
            style: AirMenuTextStyle.normal.copyWith(
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}
