import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/features/reports/presentation/widgets/report_shared_components.dart';

/// Inventory Report Detail Page - With hover effects
class InventoryReportPage extends StatelessWidget {
  const InventoryReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ReportPageLayout(
      title: 'Inventory Report',
      subtitle: 'Stock usage, wastage, and alerts',
      child: Column(
        children: [
          _buildStatsCards(),
          const SizedBox(height: 24),
          _buildInventoryTable(),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: HoverCard(
            gradientColors: [const Color(0xFFFEE2E2), Colors.white],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Usage',
                  style: AirMenuTextStyle.small.withColor(Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹15,570',
                  style: AirMenuTextStyle.headingH3.bold700().withColor(
                    AirMenuColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: HoverCard(
            gradientColors: [const Color(0xFFD1FAE5), Colors.white],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Efficiency',
                  style: AirMenuTextStyle.small.withColor(Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  '93.4%',
                  style: AirMenuTextStyle.headingH3.bold700().withColor(
                    const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: HoverCard(
            gradientColors: [const Color(0xFFFEE2E2), Colors.white],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wastage',
                  style: AirMenuTextStyle.small.withColor(Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹980',
                  style: AirMenuTextStyle.headingH3.bold700().withColor(
                    AirMenuColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryTable() {
    final inventoryData = [
      {
        'ingredient': 'Paneer',
        'quantity': '12 kg',
        'cost': '₹3,840',
        'efficiency': 0.95,
        'color': const Color(0xFF10B981),
      },
      {
        'ingredient': 'Chicken',
        'quantity': '18 kg',
        'cost': '₹5,040',
        'efficiency': 0.92,
        'color': const Color(0xFFF59E0B),
      },
      {
        'ingredient': 'Rice',
        'quantity': '25 kg',
        'cost': '₹3,000',
        'efficiency': 0.98,
        'color': const Color(0xFF10B981),
      },
      {
        'ingredient': 'Cream',
        'quantity': '8 L',
        'cost': '₹1,440',
        'efficiency': 0.88,
        'color': AirMenuColors.primary,
      },
      {
        'ingredient': 'Cooking Oil',
        'quantity': '15 L',
        'cost': '₹2,250',
        'efficiency': 0.94,
        'color': const Color(0xFFF59E0B),
      },
    ];

    return HoverCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Ingredient',
                    style: AirMenuTextStyle.small.bold600().withColor(
                      Colors.grey.shade500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Quantity Used',
                    style: AirMenuTextStyle.small.bold600().withColor(
                      Colors.grey.shade500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Cost',
                    style: AirMenuTextStyle.small.bold600().withColor(
                      Colors.grey.shade500,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Efficiency',
                    style: AirMenuTextStyle.small.bold600().withColor(
                      Colors.grey.shade500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...inventoryData.map(
            (item) => HoverTableRow(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      item['ingredient'] as String,
                      style: AirMenuTextStyle.normal.bold600().withColor(
                        Colors.grey.shade800,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item['quantity'] as String,
                      style: AirMenuTextStyle.normal.withColor(
                        Colors.grey.shade700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item['cost'] as String,
                      style: AirMenuTextStyle.normal.withColor(
                        Colors.grey.shade700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: item['efficiency'] as double,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: item['color'] as Color,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${((item['efficiency'] as double) * 100).toInt()}%',
                          style: AirMenuTextStyle.normal.bold600().withColor(
                            Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
