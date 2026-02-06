import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class SubscriptionPlanCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const SubscriptionPlanCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    const badgeColor = Color(0xFFFECACA);
    const badgeTextColor = Color(0xFFB91C1C);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Current Plan',
                  style: AirMenuTextStyle.caption.copyWith(
                    color: badgeTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade800,
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Upgrade'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            data['planName'] ?? 'Premium',
            style: AirMenuTextStyle.headingH3.copyWith(
              fontWeight: FontWeight.bold,
              color: AirMenuColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${data['price'] ?? '₹2,999/month'} • Renews ${data['renewalDate'] ?? 'Dec 15, 2024'}',
            style: AirMenuTextStyle.normal.copyWith(
              color: AirMenuColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2), // Very light red background
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFeatureItem('Unlimited Orders'),
                _buildFeatureItem('Multi-branch Support'),
                _buildFeatureItem('Advanced Analytics'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Row(
      children: [
        const Icon(
          Icons.check,
          size: 16,
          color: Color(0xFF10B981),
        ), // Green check
        const SizedBox(width: 8),
        Text(
          text,
          style: AirMenuTextStyle.small.copyWith(
            color: AirMenuColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class PaymentMethodCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const PaymentMethodCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(
                0xFFEA4335,
              ), // Mastercard/Card color approximation
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '•••• •••• •••• ${data['last4'] ?? '4532'}',
                  style: AirMenuTextStyle.normal.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AirMenuColors.textPrimary,
                  ),
                ),
                Text(
                  'Expires ${data['expiry'] ?? '12/26'}',
                  style: AirMenuTextStyle.small.copyWith(
                    color: AirMenuColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade800,
              side: BorderSide(color: Colors.grey.shade300),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }
}

class BillingHistoryList extends StatelessWidget {
  final List<dynamic> history;

  const BillingHistoryList({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: history.map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.credit_card,
                size: 20,
                color: AirMenuColors.textSecondary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  item['date'] ?? '',
                  style: AirMenuTextStyle.normal.copyWith(
                    color: AirMenuColors.textPrimary,
                  ),
                ),
              ),
              Text(
                item['amount'] ?? '',
                style: AirMenuTextStyle.normal.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AirMenuColors.textPrimary,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Paid',
                  style: AirMenuTextStyle.caption.copyWith(
                    color: const Color(0xFF065F46),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Text(
                'Download',
                style: AirMenuTextStyle.small.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AirMenuColors.textPrimary, // Or dark grey
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
