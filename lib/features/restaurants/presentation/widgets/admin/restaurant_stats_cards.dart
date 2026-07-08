import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:airmenuai_partner_app/features/restaurants/data/models/admin/admin_restaurant_models.dart';

/// Lovable glass stats cards for admin restaurants overview.
class RestaurantStatsCards extends StatelessWidget {
  final RestaurantStatsModel stats;

  const RestaurantStatsCards({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final statCards = stats.toStatCards();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 640;
        if (isNarrow) {
          return Column(
            children: [
              for (var i = 0; i < statCards.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                _StatCard(data: statCards[i]),
              ],
            ],
          );
        }

        return Row(
          children: [
            for (var i = 0; i < statCards.length; i++) ...[
              if (i > 0) const SizedBox(width: 16),
              Expanded(child: _StatCard(data: statCards[i])),
            ],
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final StatCardData data;

  const _StatCard({required this.data});

  static const _idleBorder = Color(0xFFECE8E6);
  static const _muted = Color(0xFF7A8494);

  @override
  Widget build(BuildContext context) {
    final isTotal = data.label.toLowerCase().contains('total');
    final valueColor = isTotal ? const Color(0xFF2A3038) : data.color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _idleBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            data.label == 'Pending' ? 'Pending Setup' : data.label,
            style: GoogleFonts.sora(
              color: _muted,
              fontSize: 13,
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
              style: GoogleFonts.sora(
                fontSize: 28,
                fontWeight: FontWeight.w700,
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
