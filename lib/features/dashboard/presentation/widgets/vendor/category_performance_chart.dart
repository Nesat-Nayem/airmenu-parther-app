import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/dashboard/data/models/vendor/vendor_dashboard_models.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class CategoryPerformanceChart extends StatelessWidget {
  final List<CategoryPerformanceModel> data;
  final VoidCallback? onViewAll;

  const CategoryPerformanceChart({
    super.key,
    required this.data,
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
                      'Category Performance',
                      style: AirMenuTextStyle.headingH4.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AirMenuColors.textPrimary,
                        fontSize: isMobile ? 14 : 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Orders by category',
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
          const SizedBox(height: 32),
          if (data.isEmpty)
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
            ...data.map((category) => _buildCategoryBar(category)),
        ],
      ),
    );
  }

  Widget _buildCategoryBar(CategoryPerformanceModel category) {
    // Calculate max value for scaling
    final maxValue = data.isEmpty
        ? 1
        : data.map((e) => e.orderCount).reduce((a, b) => a > b ? a : b);

    final percentage = maxValue > 0 ? category.orderCount / maxValue : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  category.categoryName,
                  style: AirMenuTextStyle.small.copyWith(
                    color: AirMenuColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: AirMenuColors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: percentage,
                      child: Container(
                        height: 32,
                        decoration: BoxDecoration(
                          color: category.barColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 12),
                        child: Text(
                          category.orderCount.toString(),
                          style: AirMenuTextStyle.small.copyWith(
                            color: AirMenuColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
