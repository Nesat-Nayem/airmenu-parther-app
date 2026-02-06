import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/features/reports/presentation/widgets/report_shared_components.dart';

/// Staff Performance Report Detail Page - With hover effects
class StaffPerformancePage extends StatelessWidget {
  const StaffPerformancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ReportPageLayout(
      title: 'Staff Performance',
      subtitle: 'Orders handled and service metrics',
      child: _buildStaffTable(),
    );
  }

  Widget _buildStaffTable() {
    final staffData = [
      {'name': 'Rahul K.', 'orders': 45, 'rating': 4.8, 'tips': '₹2,400'},
      {'name': 'Priya S.', 'orders': 38, 'rating': 4.9, 'tips': '₹2,100'},
      {'name': 'Amit P.', 'orders': 32, 'rating': 4.6, 'tips': '₹1,800'},
      {'name': 'Sneha G.', 'orders': 28, 'rating': 4.7, 'tips': '₹1,500'},
      {'name': 'Vijay S.', 'orders': 25, 'rating': 4.5, 'tips': '₹1,200'},
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
                    'Staff',
                    style: AirMenuTextStyle.small.bold600().withColor(
                      Colors.grey.shade500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Orders Served',
                    style: AirMenuTextStyle.small.bold600().withColor(
                      Colors.grey.shade500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Avg Rating',
                    style: AirMenuTextStyle.small.bold600().withColor(
                      Colors.grey.shade500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Tips Earned',
                    style: AirMenuTextStyle.small.bold600().withColor(
                      Colors.grey.shade500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...staffData.map(
            (staff) => HoverTableRow(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      staff['name'] as String,
                      style: AirMenuTextStyle.normal.bold600().withColor(
                        Colors.grey.shade800,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${staff['orders']}',
                      style: AirMenuTextStyle.normal.withColor(
                        Colors.grey.shade700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: 14,
                                color: const Color(0xFFF59E0B),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${staff['rating']}',
                                style: AirMenuTextStyle.small
                                    .bold600()
                                    .withColor(const Color(0xFFF59E0B)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      staff['tips'] as String,
                      style: AirMenuTextStyle.normal.bold600().withColor(
                        Colors.grey.shade800,
                      ),
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
