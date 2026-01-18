import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/bloc/details/restaurant_details_state.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class InventoryHealthTab extends StatelessWidget {
  final RestaurantDetailsLoaded state;

  const InventoryHealthTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header Cards
        _buildHealthCards(context),
        const SizedBox(height: 24),

        // Alerts List
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
                    'Inventory Alerts',
                    style: AirMenuTextStyle.headingH4.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('View Full Inventory'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      foregroundColor: const Color(0xFF374151),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildAlertsList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHealthCards(BuildContext context) {
    final health = state.inventoryHealth;
    final items = [
      {
        'label': 'Overall Health',
        'value': health['overallHealth'],
        'icon': Icons.health_and_safety_outlined,
        'color': const Color(0xFF22C55E),
      },
      {
        'label': 'Low Stock Items',
        'value': health['lowStockItems'],
        'icon': Icons.warning_amber_rounded,
        'color': const Color(0xFFF59E0B),
      },
      {
        'label': 'Near Expiry',
        'value': health['nearExpiry'],
        'icon': Icons.access_time,
        'color': const Color(0xFFEF4444),
      },
      {
        'label': 'Fast Moving',
        'value': health['fastMoving'],
        'icon': Icons.trending_up,
        'color': const Color(0xFFC52031),
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 4
            : (constraints.maxWidth > 600 ? 2 : 1);
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
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  item['icon'] as IconData,
                                  size: 18,
                                  color: item['color'] as Color,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  item['label'] as String,
                                  style: AirMenuTextStyle.small.copyWith(
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item['value'] as String,
                              style: AirMenuTextStyle.headingH3.copyWith(
                                fontWeight: FontWeight.bold,
                                color: item['color'] as Color,
                              ),
                            ),
                          ],
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

  Widget _buildAlertsList() {
    final alerts = state.inventoryHealth['alerts'] as List;

    return Column(
      children: [
        // List Header
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'ITEM',
                  style: AirMenuTextStyle.tiny.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'CURRENT STOCK',
                  style: AirMenuTextStyle.tiny.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'THRESHOLD / EXPIRY',
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
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),

        ...alerts.map(
          (alert) => Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    alert['item'],
                    style: AirMenuTextStyle.small.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    alert['stock'],
                    style: AirMenuTextStyle.small.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    alert['threshold'],
                    style: AirMenuTextStyle.small.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
                Expanded(flex: 2, child: _buildStatusTag(alert['status'])),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTag(String status) {
    Color bg;
    Color text;
    if (status == 'Critical' || status == 'Expiring') {
      bg = const Color(0xFFFEE2E2);
      text = const Color(0xFFDC2626);
    } else {
      bg = const Color(0xFFFEF3C7);
      text = const Color(0xFFD97706);
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: text, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              status,
              style: AirMenuTextStyle.tiny.copyWith(
                color: text,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
