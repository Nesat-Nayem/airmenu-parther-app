import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/marketing/data/models/campaign_model.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class CampaignAnalyticsDialog extends StatelessWidget {
  final CampaignModel campaign;

  const CampaignAnalyticsDialog({super.key, required this.campaign});

  static Future<void> show(BuildContext context, CampaignModel campaign) {
    return showDialog(
      context: context,
      builder: (context) => CampaignAnalyticsDialog(campaign: campaign),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: 800,
        height: 600,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Performance Overview',
                      style: AirMenuTextStyle.subheadingH5.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStatsGrid(),
                    const SizedBox(height: 32),
                    Text(
                      'Revenue Trend',
                      style: AirMenuTextStyle.subheadingH5.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPlaceholderChart(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analytics: ${campaign.name}',
                  style: AirMenuTextStyle.headingH4.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  campaign.dateRangeDisplay,
                  style: AirMenuTextStyle.small.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      childAspectRatio: 1.25,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          'Total Reach',
          campaign.formattedReach,
          Icons.visibility_outlined,
          Colors.blue,
        ),
        _buildStatCard(
          'Clicks',
          campaign.clicks.toString(),
          Icons.touch_app_outlined,
          Colors.purple,
        ),
        _buildStatCard(
          'Orders',
          campaign.orders.toString(),
          Icons.shopping_bag_outlined,
          Colors.orange,
        ),
        _buildStatCard(
          'Revenue',
          campaign.formattedRevenue,
          Icons.attach_money,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const Spacer(),
              // Trend indicator could go here
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AirMenuTextStyle.headingH4.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1C1C1C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AirMenuTextStyle.small.copyWith(
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderChart() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart_rounded, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Chart visualization coming soon',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
