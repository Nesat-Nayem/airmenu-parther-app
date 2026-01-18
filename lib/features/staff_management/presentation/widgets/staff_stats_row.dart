import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/staff_state.dart';

class StaffStatsRow extends StatelessWidget {
  final StaffStats stats;

  const StaffStatsRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.people_outline,
            iconColor: const Color(0xFFDC2626),
            iconBgColor: const Color(0xFFFEE2E2),
            count: stats.totalStaff,
            label: 'Total Staff',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatTile(
            icon: Icons.access_time,
            iconColor: const Color(0xFFDC2626),
            iconBgColor: const Color(0xFFFEE2E2),
            count: stats.activeNow,
            label: 'Active Now',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatTile(
            icon: Icons.badge_outlined,
            iconColor: const Color(0xFFDC2626),
            iconBgColor: const Color(0xFFFEE2E2),
            count: stats.rolesCount,
            label: 'Roles',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatTile(
            icon: Icons.person_off_outlined,
            iconColor: const Color(0xFFDC2626),
            iconBgColor: const Color(0xFFFEE2E2),
            count: stats.disabled,
            label: 'Disabled',
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final int count;
  final String label;

  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: 16),
          Text(
            count.toString(),
            style: GoogleFonts.sora(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.sora(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
