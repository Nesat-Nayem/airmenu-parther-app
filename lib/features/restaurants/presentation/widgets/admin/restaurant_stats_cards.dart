import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/restaurants/data/models/admin/admin_restaurant_models.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

/// Stats cards widget for admin restaurants page
class RestaurantStatsCards extends StatelessWidget {
  final RestaurantStatsModel stats;

  const RestaurantStatsCards({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final statCards = stats.toStatCards();

    return Row(
      children: statCards.map((card) {
        final isLast = card == statCards.last;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 16),
            child: _StatCard(data: card),
          ),
        );
      }).toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final StatCardData data;

  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    // Determine color based on label if not explicitly clear from data
    // Or we can rely on data.color which is already set in the model.
    // Total Restaurants usually stays black/dark.
    final isTotal = data.label.contains('Total');
    final valueColor = isTotal ? const Color(0xFF111827) : data.color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        // Subtle border as per screenshot style seems very light or none with shadow
        border: Border.all(color: Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            data.label,
            style: AirMenuTextStyle.normal.copyWith(
              color: const Color(0xFF6B7280),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              data.value,
              style: AirMenuTextStyle.headingH2.copyWith(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: valueColor,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
