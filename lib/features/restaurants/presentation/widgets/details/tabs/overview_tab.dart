import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/bloc/details/restaurant_details_state.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class OverviewTab extends StatelessWidget {
  final RestaurantDetailsLoaded state;

  const OverviewTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats
        _buildStatsGrid(context),
        const SizedBox(height: 24),

        // Legal Info
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Legal Information',
                style: AirMenuTextStyle.headingH4.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GSTIN',
                          style: AirMenuTextStyle.tiny.copyWith(
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '29ABCDE1234F1ZH',
                          style: AirMenuTextStyle.normal.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FSSAI LICENSE',
                          style: AirMenuTextStyle.tiny.copyWith(
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '12345678901234',
                          style: AirMenuTextStyle.normal.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Branches
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Branches',
                    style: AirMenuTextStyle.headingH4.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      'Add Branch',
                      style: AirMenuTextStyle.small.copyWith(
                        color: const Color(0xFF111827),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildBranchesList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final stats = state.overviewStats;
    final items = [
      {
        'label': 'Orders Today',
        'value': stats['ordersToday'],
        'icon': Icons.shopping_bag_outlined,
      },
      {
        'label': 'GMV Today',
        'value': stats['gmvToday'],
        'icon': Icons.trending_up,
      },
      {
        'label': 'Avg Prep Time',
        'value': stats['avgPrepTime'],
        'icon': Icons.schedule,
      },
      {
        'label': 'Kitchen Health',
        'value': stats['kitchenHealth'],
        'icon': Icons.soup_kitchen_outlined,
        'color': const Color(0xFF22C55E),
      },
      {
        'label': 'Inventory Risk',
        'value': stats['inventoryRisk'],
        'icon': Icons.inventory_2_outlined,
        'color': const Color(0xFFF97316),
      },
      {
        'label': 'SLA Score',
        'value': stats['slaScore'],
        'icon': Icons.check_circle_outline,
        'color': const Color(0xFF22C55E),
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 6
            : (constraints.maxWidth > 600 ? 3 : 2);
        final width =
            (constraints.maxWidth - (24 * (crossAxisCount - 1))) /
            crossAxisCount;

        return Wrap(
          spacing: 24,
          runSpacing: 24,
          children: items
              .map(
                (item) => Container(
                  width: width,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            size: 16,
                            color: const Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item['label'] as String,
                            style: AirMenuTextStyle.tiny.copyWith(
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item['value'] as String,
                        style: AirMenuTextStyle.headingH4.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              item['color'] as Color? ??
                              const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildBranchesList() {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'BRANCH NAME',
                  style: AirMenuTextStyle.tiny.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'CITY',
                  style: AirMenuTextStyle.tiny.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'STATUS',
                  style: AirMenuTextStyle.tiny.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'LAST SYNC',
                  style: AirMenuTextStyle.tiny.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ),
              const SizedBox(width: 40), // Action placeholder
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),
        ...state.branches
            .map(
              (branch) => Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        branch['name'],
                        style: AirMenuTextStyle.small.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        branch['city'],
                        style: AirMenuTextStyle.small.copyWith(
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    Expanded(flex: 2, child: _buildStatusTag(branch['status'])),
                    Expanded(
                      flex: 2,
                      child: Text(
                        branch['lastSync'],
                        style: AirMenuTextStyle.small.copyWith(
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.visibility_outlined,
                        size: 20,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _buildStatusTag(String status) {
    final isActive = status == 'Active';
    final bgColor = isActive
        ? const Color(0xFFDCFCE7)
        : const Color(0xFFF3F4F6); // Green or Grey
    final textColor = isActive
        ? const Color(0xFF15803D)
        : const Color(0xFF4B5563);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: textColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              status,
              style: AirMenuTextStyle.tiny.copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
