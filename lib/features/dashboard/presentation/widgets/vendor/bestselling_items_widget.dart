import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/dashboard/data/models/vendor/vendor_dashboard_models.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class BestsellingItemsWidget extends StatelessWidget {
  final List<BestsellingItemModel> items;
  final VoidCallback? onViewAll;

  const BestsellingItemsWidget({
    super.key,
    required this.items,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final padding = isMobile ? 16.0 : 24.0;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AirMenuColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AirMenuColors.borderDefault, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bestselling Items',
                      style: AirMenuTextStyle.headingH4.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AirMenuColors.textPrimary,
                        fontSize: isMobile ? 14 : 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Top 5 items by units sold',
                      style: AirMenuTextStyle.small.copyWith(
                        color: AirMenuColors.textSecondary,
                        fontSize: isMobile ? 11 : 12,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: onViewAll,
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('View All'),
                style: TextButton.styleFrom(
                  foregroundColor: AirMenuColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (items.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Text(
                  'No data available',
                  style: AirMenuTextStyle.normal.copyWith(
                    color: AirMenuColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            ...items.map((item) => _buildItemRow(item)),
        ],
      ),
    );
  }

  Widget _buildItemRow(BestsellingItemModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          _buildRankBadge(item.rank),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName,
                  style: AirMenuTextStyle.normal.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AirMenuColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.unitsSold} units sold',
                  style: AirMenuTextStyle.caption.copyWith(
                    color: AirMenuColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${item.revenue.toStringAsFixed(0)}',
                style: AirMenuTextStyle.normal.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AirMenuColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              _buildChangeIndicator(item),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    Color badgeColor;
    Color textColor;

    switch (rank) {
      case 1:
        badgeColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        break;
      case 2:
        badgeColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFF59E0B);
        break;
      case 3:
        badgeColor = const Color(0xFFFED7AA);
        textColor = const Color(0xFFEA580C);
        break;
      default:
        badgeColor = AirMenuColors.backgroundSecondary;
        textColor = AirMenuColors.textSecondary;
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        '#$rank',
        style: AirMenuTextStyle.small.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildChangeIndicator(BestsellingItemModel item) {
    final color = item.revenueChangeIsPositive
        ? AirMenuColors.success
        : AirMenuColors.error;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          item.revenueChangeIsPositive
              ? Icons.arrow_upward
              : Icons.arrow_downward,
          color: color,
          size: 12,
        ),
        const SizedBox(width: 2),
        Text(
          '${item.revenueChange.abs().toStringAsFixed(0)}%',
          style: AirMenuTextStyle.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
