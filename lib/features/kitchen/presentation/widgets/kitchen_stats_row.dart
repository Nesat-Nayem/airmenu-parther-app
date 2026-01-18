import 'package:airmenuai_partner_app/features/kitchen/presentation/bloc/kitchen_state.dart';
import 'package:flutter/material.dart';

/// Stats row widget for Kitchen Panel - matches Lovable mockup design
/// Large cards with icon at top, big value, label below
class KitchenStatsRow extends StatelessWidget {
  final KitchenStats stats;

  const KitchenStatsRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.restaurant_outlined,
              iconBgColor: const Color(0xFFFEE2E2),
              iconColor: const Color(0xFFDC2626),
              value: '${stats.activeStations}',
              label: 'Active Stations',
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: _StatCard(
              icon: Icons.receipt_long_outlined,
              iconBgColor: const Color(0xFFFEE2E2),
              iconColor: const Color(0xFFDC2626),
              value: '${stats.ordersInQueue}',
              label: 'Orders in Queue',
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: _StatCard(
              icon: Icons.timer_outlined,
              iconBgColor: const Color(0xFFFEE2E2),
              iconColor: const Color(0xFFDC2626),
              value: '${stats.avgPrepTimeMinutes} min',
              label: 'Avg Prep Time',
              subtitle: 'vs yesterday',
              showBadge: true,
              badgeText: '2%',
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: _StatCard(
              icon: Icons.check_circle_outline,
              iconBgColor: const Color(0xFFDCFCE7),
              iconColor: const Color(0xFF16A34A),
              value: '${stats.readyForPickup}',
              label: 'Ready for Pickup',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String value;
  final String label;
  final String? subtitle;
  final bool showBadge;
  final String? badgeText;

  const _StatCard({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.value,
    required this.label,
    this.subtitle,
    this.showBadge = false,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon with optional badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              if (showBadge && badgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.arrow_downward,
                        size: 12,
                        color: Color(0xFF16A34A),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        badgeText??"",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Value
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Color(0xFF212121),
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          // Label
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
          // Subtitle if provided
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                subtitle??"",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
        ],
      ),
    );
  }
}
