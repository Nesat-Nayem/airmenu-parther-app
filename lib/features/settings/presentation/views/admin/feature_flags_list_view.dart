import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';

class FeatureFlagsListView extends StatelessWidget {
  const FeatureFlagsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildFeatureRow(
              'Hotel Module',
              'Enable room service for hotels',
              true,
              badge: 'All',
            ),
            _buildFeatureRow(
              'AI Recipe Extraction',
              'Auto-extract ingredients from menu items',
              true,
              badge: 'Premium',
            ),
            _buildFeatureRow(
              'Kitchen Load Balancing',
              'Auto-balance orders across stations',
              false,
              badge: 'Enterprise',
            ),
            _buildFeatureRow(
              'Predictive Inventory',
              'AI-powered stock predictions',
              false,
              badge: 'Beta',
            ),
            _buildFeatureRow(
              'Multi-branch Support',
              'Manage multiple restaurant branches',
              true,
              badge: 'Premium',
            ),
            _buildFeatureRow(
              'Custom Notification Sounds',
              'Upload custom alert sounds',
              true,
              badge: 'All',
            ),
            _buildLastFeatureRow(
              'Advanced Analytics',
              'Detailed performance analytics',
              true,
              badge: 'Premium',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(
    String title,
    String description,
    bool isEnabled, {
    String? badge,
    bool isLast = false,
  }) {
    return _buildRowContent(
      title,
      description,
      isEnabled,
      badge: badge,
      isLast: isLast,
    );
  }

  Widget _buildLastFeatureRow(
    String title,
    String description,
    bool isEnabled, {
    String? badge,
  }) {
    return _buildRowContent(
      title,
      description,
      isEnabled,
      badge: badge,
      isLast: true,
    );
  }

  Widget _buildRowContent(
    String title,
    String description,
    bool isEnabled, {
    String? badge,
    required bool isLast,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: AirMenuTextStyle.headingH4.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AirMenuColors.textPrimary,
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 12),
                      _buildBadge(badge),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AirMenuTextStyle.normal.copyWith(
                    color: AirMenuColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isEnabled,
            activeColor: const Color(0xFFDC2626),
            onChanged: (val) {
              // TODO: Wire to Bloc
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text) {
    Color bgColor;
    Color textColor;

    switch (text.toLowerCase()) {
      case 'premium':
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFF991B1B);
        break;
      case 'enterprise':
        bgColor = const Color(0xFFE0E7FF);
        textColor = const Color(0xFF3730A3);
        break;
      case 'beta':
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFF92400E);
        break;
      case 'all':
      default:
        bgColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF374151);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: AirMenuTextStyle.caption.copyWith(
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
