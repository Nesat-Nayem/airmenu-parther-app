import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class PlanUpgradePage extends StatelessWidget {
  const PlanUpgradePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6B7280)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Upgrade Plan',
          style: AirMenuTextStyle.headingH4.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF111827),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose the perfect plan for your restaurant',
              style: AirMenuTextStyle.normal.copyWith(
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 24),
            _buildPlanCard('Professional', '₹2,499/mo', [
              'Unlimited Orders',
              'Priority Support',
              'Advanced Analytics',
              'Custom Branding',
            ], isPopular: false),
            const SizedBox(height: 24),
            _buildPlanCard('Enterprise', 'Custom Pricing', [
              'Multi-location Support',
              'Dedicated Account Manager',
              'Custom API Access',
              'White Label Solution',
            ], isPopular: true),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    String name,
    String price,
    List<String> features, {
    bool isPopular = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPopular ? const Color(0xFFC52031) : const Color(0xFFE5E7EB),
          width: isPopular ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: AirMenuTextStyle.headingH4.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827),
                ),
              ),
              if (isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC52031),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'POPULAR',
                    style: AirMenuTextStyle.tiny.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            price,
            style: AirMenuTextStyle.headingH3.copyWith(
              color: const Color(0xFFC52031),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ...features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF22C55E),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    f,
                    style: AirMenuTextStyle.normal.copyWith(
                      color: const Color(0xFF374151),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: isPopular
                    ? const Color(0xFFC52031)
                    : Colors.white,
                foregroundColor: isPopular
                    ? Colors.white
                    : const Color(0xFFC52031),
                side: isPopular
                    ? BorderSide.none
                    : const BorderSide(color: Color(0xFFC52031), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                'Choose Plan',
                style: AirMenuTextStyle.normal.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
